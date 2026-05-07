use salvo::prelude::*;
use salvo::jwt_auth::{ConstDecoder, HeaderFinder, JwtAuth, JwtAuthDepotExt};
use jsonwebtoken::{encode, decode, EncodingKey, DecodingKey, Header, Validation};
use serde::{Deserialize, Serialize};
use chrono::{Utc, Duration};
use uuid::Uuid;
use sqlx::PgPool;
use crate::models::{ApiResponse, Account};
use crate::config::AppConfig;

fn hash_password(password: &str) -> Result<String, bcrypt::BcryptError> {
    bcrypt::hash(password, bcrypt::DEFAULT_COST)
}

fn verify_password(password: &str, hash: &str) -> Result<bool, bcrypt::BcryptError> {
    bcrypt::verify(password, hash)
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct JwtClaims {
    pub sub: String,
    pub account_id: String,
    pub role: String,
    pub exp: i64,
    pub iat: i64,
}

#[derive(Debug, Deserialize)]
pub struct RegisterRequest {
    pub phone: String,
    pub verification_code: String,
    pub nickname: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct LearnerLoginRequest {
    #[serde(deserialize_with = "validate_email")]
    pub email: String,
    #[serde(deserialize_with = "validate_password")]
    pub password: String,
}

#[derive(Debug, Deserialize)]
pub struct AdminLoginRequest {
    #[serde(deserialize_with = "validate_email")]
    pub email: String,
    #[serde(deserialize_with = "validate_password")]
    pub password: String,
}

#[derive(Debug, Deserialize)]
#[allow(dead_code)]
pub struct LoginRequest {
    pub phone: String,
    pub verification_code: String,
}

#[derive(Debug, Serialize)]
pub struct LoginResponse {
    pub access_token: String,
    pub refresh_token: String,
    pub expires_in: i64,
    pub token_type: String,
}

#[derive(Debug, Deserialize)]
pub struct RefreshRequest {
    pub refresh_token: String,
}

fn create_access_token(account_id: &str, role: &crate::models::RoleType, secret: &str, expiration: i64) -> Result<String, jsonwebtoken::errors::Error> {
    let role_str = match role {
        crate::models::RoleType::Admin => "admin",
        crate::models::RoleType::Learner => "learner",
    };
    let now = Utc::now();
    let claims = JwtClaims {
        sub: account_id.to_string(),
        account_id: account_id.to_string(),
        role: role_str.to_string(),
        exp: (now + Duration::seconds(expiration)).timestamp(),
        iat: now.timestamp(),
    };
    encode(
        &Header::default(),
        &claims,
        &EncodingKey::from_secret(secret.as_bytes()),
    )
}

fn validate_refresh_token(token: &str, secret: &str) -> Result<JwtClaims, jsonwebtoken::errors::Error> {
    let token_data = decode::<JwtClaims>(
        token,
        &DecodingKey::from_secret(secret.as_bytes()),
        &Validation::default(),
    )?;
    Ok(token_data.claims)
}

async fn authenticate_user(
    pool: &PgPool,
    cfg: &AppConfig,
    email_or_phone: &str,
    password: &str,
    role: &str,
) -> Result<LoginResponse, StatusError> {
    let account = sqlx::query_as::<_, Account>(
        "SELECT * FROM accounts WHERE email = $1"
    )
    .bind(email_or_phone)
    .fetch_optional(pool)
    .await
    .map_err(|e| {
        eprintln!("Database error when fetching account: {:?}", e);
        StatusError::internal_server_error()
    })?;
    
    let account = match account {
        Some(acc) => {
            if !acc.password_hash.is_empty() {
                let valid = verify_password(password, &acc.password_hash)
                    .map_err(|e| {
                        eprintln!("Password verification error: {:?}", e);
                        StatusError::internal_server_error()
                    })?;
                if !valid {
                    return Err(StatusError::unauthorized().brief("Invalid email or password"));
                }
            }
            acc
        }
        None => {
            let new_id = Uuid::new_v4();
            let role_enum = if role == "admin" {
                crate::models::RoleType::Admin
            } else {
                crate::models::RoleType::Learner
            };
            
            let password_hash = hash_password(password)
                .map_err(|e| {
                    eprintln!("Password hashing error: {:?}", e);
                    StatusError::internal_server_error()
                })?;
            
            sqlx::query(
                "INSERT INTO accounts (id, email, password_hash, default_role, account_status) 
                 VALUES ($1, $2, $3, $4, $5)"
            )
            .bind(new_id)
            .bind(email_or_phone)
            .bind(password_hash)
            .bind(role_enum)
            .bind(crate::models::AccountStatus::Active)
            .execute(pool)
            .await
            .map_err(|e| {
                eprintln!("Database error when inserting account: {:?}", e);
                StatusError::internal_server_error()
            })?;
            
            Account {
                id: new_id,
                email: email_or_phone.to_string(),
                password_hash: "".to_string(),
                default_role: crate::models::RoleType::Learner,
                account_status: crate::models::AccountStatus::Active,
                last_login_at: None,
                created_at: Utc::now(),
                updated_at: Utc::now(),
            }
        }
    };
    
    let access_token = create_access_token(
        &account.id.to_string(), 
        &account.default_role,
        &cfg.jwt_secret,
        cfg.jwt_expiration
    )
    .map_err(|_| StatusError::internal_server_error())?;
    
    let refresh_token_str = create_access_token(
        &account.id.to_string(),
        &account.default_role,
        &cfg.jwt_secret,
        cfg.jwt_expiration * 7
    )
    .map_err(|_| StatusError::internal_server_error())?;
    
    sqlx::query("UPDATE accounts SET last_login_at = NOW() WHERE id = $1")
        .bind(account.id)
        .execute(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(LoginResponse {
        access_token,
        refresh_token: refresh_token_str,
        expires_in: cfg.jwt_expiration,
        token_type: "Bearer".to_string(),
    })
}

#[handler]
pub async fn register(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<LoginResponse>>, StatusError> {
    let body: RegisterRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    if body.verification_code.len() != 6 || !body.verification_code.chars().all(|c| c.is_ascii_digit()) {
        return Err(StatusError::unauthorized().brief("Invalid verification code format"));
    }
    
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    let cfg = depot.obtain::<AppConfig>()
        .map_err(|_| StatusError::internal_server_error().brief("Config not available"))?;
    
    let response = authenticate_user(pool, cfg, &body.phone, "", "learner").await?;
    
    if let Some(nickname) = body.nickname {
        let account_id = Uuid::parse_str(
        &response.access_token)
            .map_err(|_| StatusError::internal_server_error())?;
        sqlx::query("INSERT INTO user_profiles (account_id, nickname) VALUES ($1, $2) ON CONFLICT (account_id) DO UPDATE SET nickname = $2")
            .bind(account_id)
            .bind(nickname)
            .execute(pool)
            .await
            .map_err(|_| StatusError::internal_server_error())?;
    }
    
    Ok(Json(ApiResponse::new(response)))
}

#[handler]
pub async fn learner_login(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<LoginResponse>>, StatusError> {
    let body: LearnerLoginRequest = req.parse_json().await
        .map_err(|e| {
            eprintln!("Failed to parse request body: {:?}", e);
            StatusError::bad_request().brief("Invalid request body")
        })?;
    
    let pool = depot.obtain::<PgPool>()
        .map_err(|e| {
            eprintln!("Failed to obtain pool: {:?}", e);
            StatusError::internal_server_error()
        })?;
    let cfg = depot.obtain::<AppConfig>()
        .map_err(|e| {
            eprintln!("Failed to obtain config: {:?}", e);
            StatusError::internal_server_error().brief("Config not available")
        })?;
    
    let response = authenticate_user(pool, cfg, &body.email, &body.password, "learner").await?;
    Ok(Json(ApiResponse::new(response)))
}

#[handler]
pub async fn admin_login(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<LoginResponse>>, StatusError> {
    let body: AdminLoginRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    let cfg = depot.obtain::<AppConfig>()
        .map_err(|_| StatusError::internal_server_error().brief("Config not available"))?;
    
    let response = authenticate_user(pool, cfg, &body.email, &body.password, "admin").await?;
    Ok(Json(ApiResponse::new(response)))
}

#[handler]
pub async fn login(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<LoginResponse>>, StatusError> {
    let body: LoginRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    if body.verification_code.len() != 6 || !body.verification_code.chars().all(|c| c.is_ascii_digit()) {
        return Err(StatusError::unauthorized().brief("Invalid verification code format"));
    }
    
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    let cfg = depot.obtain::<AppConfig>()
        .map_err(|_| StatusError::internal_server_error().brief("Config not available"))?;
    
    let response = authenticate_user(pool, cfg, &body.phone, "", "learner").await?;
    Ok(Json(ApiResponse::new(response)))
}

#[handler]
pub async fn logout(_req: &mut Request, _depot: &mut Depot) -> Result<StatusCode, StatusError> {
    Ok(StatusCode::OK)
}

#[handler]
pub async fn refresh_token(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<LoginResponse>>, StatusError> {
    let body: RefreshRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let cfg = depot.obtain::<AppConfig>()
        .map_err(|_| StatusError::internal_server_error().brief("Config not available"))?;
    
    let claims = validate_refresh_token(&body.refresh_token, &cfg.jwt_secret)
        .map_err(|_| StatusError::unauthorized().brief("Invalid refresh token"))?;
    
    let role_enum = match claims.role.as_str() {
        "admin" => crate::models::RoleType::Admin,
        _ => crate::models::RoleType::Learner,
    };
    let access_token = create_access_token(
        &claims.account_id, 
        &role_enum,
        &cfg.jwt_secret,
        cfg.jwt_expiration
    )
    .map_err(|_| StatusError::internal_server_error())?;
    
    let role_enum = match claims.role.as_str() {
        "admin" => crate::models::RoleType::Admin,
        _ => crate::models::RoleType::Learner,
    };
    let new_refresh_token = create_access_token(
        &claims.account_id,
        &role_enum,
        &cfg.jwt_secret,
        cfg.jwt_expiration * 7
    )
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(Json(ApiResponse::new(LoginResponse {
        access_token,
        refresh_token: new_refresh_token,
        expires_in: cfg.jwt_expiration,
        token_type: "Bearer".to_string(),
    })))
}

pub fn jwt_auth_middleware(secret: String) -> JwtAuth<JwtClaims, ConstDecoder> {
    JwtAuth::new(ConstDecoder::from_secret(secret.as_bytes()))
        .finders(vec![Box::new(HeaderFinder::new())])
}

#[handler]
pub async fn get_current_user(depot: &mut Depot) -> Result<Json<ApiResponse<Account>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let jwt_data = depot.jwt_auth_data::<JwtClaims>()
        .ok_or_else(StatusError::unauthorized)?;
    
    let account_id = Uuid::parse_str(&jwt_data.claims.account_id)
        .map_err(|_| StatusError::unauthorized())?;
    
    let account = sqlx::query_as::<_, Account>("SELECT * FROM accounts WHERE id = $1")
        .bind(account_id)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;
    
    Ok(Json(ApiResponse::new(account)))
}

pub fn get_current_account_id(depot: &Depot) -> Result<Uuid, StatusError> {
    let jwt_data = depot.jwt_auth_data::<JwtClaims>()
        .ok_or_else(StatusError::unauthorized)?;
    
    Uuid::parse_str(&jwt_data.claims.account_id)
        .map_err(|_| StatusError::unauthorized())
}

pub fn get_current_role(depot: &Depot) -> Result<String, StatusError> {
    let jwt_data = depot.jwt_auth_data::<JwtClaims>()
        .ok_or_else(StatusError::unauthorized)?;
    
    Ok(jwt_data.claims.role.clone())
}

fn validate_email<'de, D>(deserializer: D) -> Result<String, D::Error>
where
    D: serde::Deserializer<'de>,
{
    let email: String = serde::Deserialize::deserialize(deserializer)?;
    if email.contains('@') && email.len() >= 5 {
        Ok(email)
    } else {
        Err(serde::de::Error::custom("Invalid email format"))
    }
}

fn validate_password<'de, D>(deserializer: D) -> Result<String, D::Error>
where
    D: serde::Deserializer<'de>,
{
    let password: String = serde::Deserialize::deserialize(deserializer)?;
    if password.len() >= 6 {
        Ok(password)
    } else {
        Err(serde::de::Error::custom("Password must be at least 6 characters"))
    }
}
