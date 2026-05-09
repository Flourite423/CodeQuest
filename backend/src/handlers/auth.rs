use chrono::{DateTime, Duration, Utc};
use jsonwebtoken::{decode, encode, DecodingKey, EncodingKey, Header, Validation};
use salvo::jwt_auth::{ConstDecoder, HeaderFinder, JwtAuth, JwtAuthDepotExt};
use salvo::prelude::*;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use sqlx::PgPool;
use uuid::Uuid;

use crate::config::AppConfig;
use crate::models::{Account, AdminProfile, ApiResponse, LearnerProfile, RoleType};

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
    #[serde(deserialize_with = "validate_email")]
    pub email: String,
    #[serde(deserialize_with = "validate_password")]
    pub password: String,
    pub nickname: String,
    pub device_id: String,
    #[serde(default)]
    pub device_name: Option<String>,
    pub platform: String,
}

#[derive(Debug, Deserialize)]
pub struct LearnerLoginRequest {
    #[serde(deserialize_with = "validate_email")]
    pub email: String,
    #[serde(deserialize_with = "validate_password")]
    pub password: String,
    #[serde(default)]
    pub device_id: Option<String>,
    #[serde(default)]
    pub device_name: Option<String>,
    #[serde(default)]
    pub platform: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct AdminLoginRequest {
    #[serde(deserialize_with = "validate_email")]
    pub email: String,
    #[serde(deserialize_with = "validate_password")]
    pub password: String,
    #[serde(default)]
    pub device_id: Option<String>,
    #[serde(default)]
    pub device_name: Option<String>,
    #[serde(default)]
    pub platform: Option<String>,
}

#[derive(Debug, Deserialize)]
#[allow(dead_code)]
pub struct LoginRequest {
    pub phone: String,
    pub verification_code: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct LoginResponse {
    pub account_id: String,
    pub active_role: String,
    pub access_token: String,
    pub refresh_token: String,
    pub expires_in: i64,
    pub session_id: String,
    pub profile: Value,
    pub token_type: String,
}

#[derive(Debug, Deserialize)]
pub struct RefreshRequest {
    pub refresh_token: String,
}

#[derive(Debug, Deserialize)]
pub struct LogoutRequest {
    pub session_id: Uuid,
}

fn create_access_token(account_id: &str, role: &RoleType, secret: &str, expiration: i64) -> Result<String, jsonwebtoken::errors::Error> {
    let role_str = match role {
        RoleType::Admin => "admin",
        RoleType::Learner => "learner",
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

fn normalize_platform(role: &str, platform: Option<&str>) -> &'static str {
    match platform {
        Some("ios") => "ios",
        Some("android") => "android",
        Some("web") => "web",
        _ if role == "admin" => "web",
        _ => "ios",
    }
}

fn default_device_id(role: &str, provided: Option<&str>) -> String {
    provided
        .filter(|value| !value.trim().is_empty())
        .unwrap_or(if role == "admin" { "admin-web-device" } else { "learner-mobile-device" })
        .to_string()
}

fn default_nickname_from_email(email: &str) -> String {
    let local = email.split('@').next().unwrap_or("learner");
    let fallback = if local.len() < 2 { "learner" } else { local };
    fallback.chars().take(24).collect()
}

async fn ensure_learner_profile(
    pool: &PgPool,
    account_id: Uuid,
    nickname: &str,
) -> Result<LearnerProfile, StatusError> {
    sqlx::query(
        "INSERT INTO learner_profiles (account_id, nickname)
         VALUES ($1, $2)
         ON CONFLICT (account_id) DO NOTHING",
    )
    .bind(account_id)
    .bind(nickname)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    sqlx::query_as::<_, LearnerProfile>(
        "SELECT
            account_id,
            nickname,
            avatar_url,
            bio,
            theme_mode::text AS theme_mode,
            daily_goal_minutes,
            streak_days,
            total_xp,
            current_level,
            friend_count,
            ai_daily_limit,
            last_study_at,
            created_at,
            updated_at
         FROM learner_profiles
         WHERE account_id = $1",
    )
    .bind(account_id)
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())
}

async fn ensure_admin_profile(
    pool: &PgPool,
    account_id: Uuid,
    display_name: &str,
) -> Result<AdminProfile, StatusError> {
    sqlx::query(
        "INSERT INTO admin_profiles (account_id, display_name)
         VALUES ($1, $2)
         ON CONFLICT (account_id) DO NOTHING",
    )
    .bind(account_id)
    .bind(display_name)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    sqlx::query_as::<_, AdminProfile>(
        "SELECT
            account_id,
            display_name,
            avatar_url,
            admin_status::text AS admin_status,
            last_active_at,
            created_at,
            updated_at
         FROM admin_profiles
         WHERE account_id = $1",
    )
    .bind(account_id)
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())
}

fn normalize_admin_profile(mut profile: Value) -> Value {
    if let Some(status) = profile.get_mut("admin_status") {
        if status == "enabled" {
            *status = Value::String("active".to_string());
        }
    }
    profile
}

async fn load_profile_value(
    pool: &PgPool,
    account: &Account,
    role: &str,
    preferred_name: Option<&str>,
) -> Result<Value, StatusError> {
    if role == "admin" {
        let display_name = preferred_name.unwrap_or("Admin");
        let profile = ensure_admin_profile(pool, account.id, display_name).await?;
        let value = serde_json::to_value(profile).map_err(|_| StatusError::internal_server_error())?;
        Ok(normalize_admin_profile(value))
    } else {
        let nickname = preferred_name.unwrap_or("Learner");
        let profile = ensure_learner_profile(pool, account.id, nickname).await?;
        serde_json::to_value(profile).map_err(|_| StatusError::internal_server_error())
    }
}

async fn insert_session(
    pool: &PgPool,
    account_id: Uuid,
    role: RoleType,
    device_id: &str,
    device_name: Option<&str>,
    platform: &str,
    refresh_token_value: &str,
) -> Result<Uuid, StatusError> {
    let session_id = Uuid::new_v4();
    let refresh_expires_at = Utc::now() + Duration::days(7);

    sqlx::query(
        "INSERT INTO sessions (
            id, account_id, role, device_id, device_name, platform,
            refresh_token_hash, refresh_expires_at, last_seen_at
         ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())",
    )
    .bind(session_id)
    .bind(account_id)
    .bind(role)
    .bind(device_id)
    .bind(device_name)
    .bind(platform)
    .bind(refresh_token_value)
    .bind(refresh_expires_at)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    Ok(session_id)
}

async fn build_login_response(
    pool: &PgPool,
    cfg: &AppConfig,
    account: Account,
    role: &str,
    preferred_name: Option<&str>,
    device_id: &str,
    device_name: Option<&str>,
    platform: &str,
) -> Result<LoginResponse, StatusError> {
    let role_enum = if role == "admin" {
        RoleType::Admin
    } else {
        RoleType::Learner
    };

    let access_token = create_access_token(
        &account.id.to_string(),
        &role_enum,
        &cfg.jwt_secret,
        cfg.jwt_expiration,
    )
    .map_err(|_| StatusError::internal_server_error())?;

    let refresh_token_value = create_access_token(
        &account.id.to_string(),
        &role_enum,
        &cfg.jwt_secret,
        cfg.jwt_expiration * 7,
    )
    .map_err(|_| StatusError::internal_server_error())?;

    let session_id = insert_session(
        pool,
        account.id,
        role_enum,
        device_id,
        device_name,
        platform,
        &refresh_token_value,
    )
    .await?;

    sqlx::query("UPDATE accounts SET last_login_at = NOW() WHERE id = $1")
        .bind(account.id)
        .execute(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;

    let profile = load_profile_value(pool, &account, role, preferred_name).await?;

    Ok(LoginResponse {
        account_id: account.id.to_string(),
        active_role: role.to_string(),
        access_token,
        refresh_token: refresh_token_value,
        expires_in: cfg.jwt_expiration,
        session_id: session_id.to_string(),
        profile,
        token_type: "Bearer".to_string(),
    })
}

async fn authenticate_user(
    pool: &PgPool,
    cfg: &AppConfig,
    email: &str,
    password: &str,
    role: &str,
    device_id: &str,
    device_name: Option<&str>,
    platform: &str,
) -> Result<LoginResponse, StatusError> {
    let account = sqlx::query_as::<_, Account>("SELECT * FROM accounts WHERE email = $1")
        .bind(email)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;

    let preferred_name = default_nickname_from_email(email);
    let account = match account {
        Some(account) => {
            let valid = verify_password(password, &account.password_hash)
                .map_err(|_| StatusError::internal_server_error())?;
            if !valid {
                return Err(StatusError::unauthorized().brief("Invalid email or password"));
            }
            if role == "admin" && !matches!(account.default_role, RoleType::Admin) {
                return Err(StatusError::forbidden().brief("Admin access required"));
            }
            account
        }
        None => {
            return Err(StatusError::unauthorized().brief("Invalid email or password"));
        }
    };

    build_login_response(
        pool,
        cfg,
        account,
        role,
        Some(&preferred_name),
        device_id,
        device_name,
        platform,
    )
    .await
}

#[handler]
pub async fn register(
    req: &mut Request,
    depot: &mut Depot,
    res: &mut Response,
) -> Result<Json<ApiResponse<LoginResponse>>, StatusError> {
    let body: RegisterRequest = req
        .parse_json()
        .await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;

    let pool = depot.obtain::<PgPool>().map_err(|_| StatusError::internal_server_error())?;
    let cfg = depot.obtain::<AppConfig>().map_err(|_| StatusError::internal_server_error())?;

    let existing: Option<(Uuid,)> = sqlx::query_as("SELECT id FROM accounts WHERE email = $1")
        .bind(&body.email)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    if existing.is_some() {
        return Err(StatusError::conflict().brief("Account already exists"));
    }

    let valid_platforms = ["ios", "android", "web"];
    if !valid_platforms.contains(&body.platform.as_str()) {
        return Err(StatusError::bad_request().brief("Invalid platform. Must be one of: ios, android, web"));
    }

    let account_id = Uuid::new_v4();
    let password_hash = hash_password(&body.password).map_err(|_| StatusError::internal_server_error())?;

    sqlx::query(
        "INSERT INTO accounts (id, email, password_hash, default_role, account_status)
         VALUES ($1, $2, $3, 'learner', 'active')",
    )
    .bind(account_id)
    .bind(&body.email)
    .bind(&password_hash)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    let _ = ensure_learner_profile(pool, account_id, &body.nickname).await?;
    let account = sqlx::query_as::<_, Account>("SELECT * FROM accounts WHERE id = $1")
        .bind(account_id)
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;

    let response = build_login_response(
        pool,
        cfg,
        account,
        "learner",
        Some(&body.nickname),
        &body.device_id,
        body.device_name.as_deref(),
        normalize_platform("learner", Some(&body.platform)),
    )
    .await?;

    res.status_code(StatusCode::CREATED);
    Ok(Json(ApiResponse::new(response)))
}

#[handler]
pub async fn learner_login(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<LoginResponse>>, StatusError> {
    let body: LearnerLoginRequest = req
        .parse_json()
        .await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;

    let pool = depot.obtain::<PgPool>().map_err(|_| StatusError::internal_server_error())?;
    let cfg = depot.obtain::<AppConfig>().map_err(|_| StatusError::internal_server_error())?;
    let device_id = default_device_id("learner", body.device_id.as_deref());
    let platform = normalize_platform("learner", body.platform.as_deref());

    let response = authenticate_user(
        pool,
        cfg,
        &body.email,
        &body.password,
        "learner",
        &device_id,
        body.device_name.as_deref(),
        platform,
    )
    .await?;

    Ok(Json(ApiResponse::new(response)))
}

#[handler]
pub async fn admin_login(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<LoginResponse>>, StatusError> {
    let body: AdminLoginRequest = req
        .parse_json()
        .await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;

    let pool = depot.obtain::<PgPool>().map_err(|_| StatusError::internal_server_error())?;
    let cfg = depot.obtain::<AppConfig>().map_err(|_| StatusError::internal_server_error())?;
    let device_id = default_device_id("admin", body.device_id.as_deref());
    let platform = normalize_platform("admin", body.platform.as_deref());

    let response = authenticate_user(
        pool,
        cfg,
        &body.email,
        &body.password,
        "admin",
        &device_id,
        body.device_name.as_deref(),
        platform,
    )
    .await?;

    Ok(Json(ApiResponse::new(response)))
}



#[handler]
pub async fn logout(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    if let Ok(body) = req.parse_json::<LogoutRequest>().await {
        if let Ok(pool) = depot.obtain::<PgPool>() {
            let _ = sqlx::query("UPDATE sessions SET revoked_at = NOW() WHERE id = $1")
                .bind(body.session_id)
                .execute(pool)
                .await;
        }
    }
    Ok(StatusCode::OK)
}

#[handler]
pub async fn refresh_token(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<LoginResponse>>, StatusError> {
    let body: RefreshRequest = req
        .parse_json()
        .await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;

    let pool = depot.obtain::<PgPool>().map_err(|_| StatusError::internal_server_error())?;
    let cfg = depot.obtain::<AppConfig>().map_err(|_| StatusError::internal_server_error())?;
    let claims = validate_refresh_token(&body.refresh_token, &cfg.jwt_secret)
        .map_err(|_| StatusError::unauthorized().brief("Invalid refresh token"))?;

    let account_id = Uuid::parse_str(&claims.account_id).map_err(|_| StatusError::unauthorized())?;
    let account = sqlx::query_as::<_, Account>("SELECT * FROM accounts WHERE id = $1")
        .bind(account_id)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;

    let session_id = sqlx::query_scalar::<_, Uuid>(
        "SELECT id FROM sessions WHERE account_id = $1 AND revoked_at IS NULL ORDER BY created_at DESC LIMIT 1",
    )
    .bind(account_id)
    .fetch_optional(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?
    .unwrap_or_else(Uuid::new_v4);

    let role_enum = if claims.role == "admin" { RoleType::Admin } else { RoleType::Learner };
    let access_token = create_access_token(&claims.account_id, &role_enum, &cfg.jwt_secret, cfg.jwt_expiration)
        .map_err(|_| StatusError::internal_server_error())?;
    let new_refresh_token = create_access_token(&claims.account_id, &role_enum, &cfg.jwt_secret, cfg.jwt_expiration * 7)
        .map_err(|_| StatusError::internal_server_error())?;
    let profile = load_profile_value(pool, &account, &claims.role, None).await?;

    Ok(Json(ApiResponse::new(LoginResponse {
        account_id: claims.account_id,
        active_role: claims.role,
        access_token,
        refresh_token: new_refresh_token,
        expires_in: cfg.jwt_expiration,
        session_id: session_id.to_string(),
        profile,
        token_type: "Bearer".to_string(),
    })))
}

pub fn jwt_auth_middleware(secret: String) -> JwtAuth<JwtClaims, ConstDecoder> {
    JwtAuth::new(ConstDecoder::from_secret(secret.as_bytes()))
        .finders(vec![Box::new(HeaderFinder::new())])
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SafeAccount {
    pub id: String,
    pub email: String,
    pub default_role: String,
    pub account_status: String,
    pub last_login_at: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[handler]
pub async fn get_current_user(depot: &mut Depot) -> Result<Json<ApiResponse<SafeAccount>>, StatusError> {
    let pool = depot.obtain::<PgPool>().map_err(|_| StatusError::internal_server_error())?;

    let jwt_data = depot.jwt_auth_data::<JwtClaims>().ok_or_else(StatusError::unauthorized)?;

    let account_id = Uuid::parse_str(&jwt_data.claims.account_id).map_err(|_| StatusError::unauthorized())?;

    let account = sqlx::query_as::<_, Account>("SELECT * FROM accounts WHERE id = $1")
        .bind(account_id)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;

    let safe_account = SafeAccount {
        id: account.id.to_string(),
        email: account.email,
        default_role: format!("{:?}", account.default_role).to_lowercase(),
        account_status: format!("{:?}", account.account_status).to_lowercase(),
        last_login_at: account.last_login_at,
        created_at: account.created_at,
        updated_at: account.updated_at,
    };

    Ok(Json(ApiResponse::new(safe_account)))
}

pub fn get_current_account_id(depot: &Depot) -> Result<Uuid, StatusError> {
    let jwt_data = depot.jwt_auth_data::<JwtClaims>().ok_or_else(StatusError::unauthorized)?;

    Uuid::parse_str(&jwt_data.claims.account_id).map_err(|_| StatusError::unauthorized())
}

pub fn get_current_role(depot: &Depot) -> Result<String, StatusError> {
    let jwt_data = depot.jwt_auth_data::<JwtClaims>().ok_or_else(StatusError::unauthorized)?;

    Ok(jwt_data.claims.role.clone())
}

fn validate_email<'de, D>(deserializer: D) -> Result<String, D::Error>
where
    D: serde::Deserializer<'de>,
{
    let email: String = serde::Deserialize::deserialize(deserializer)?;
    if email.contains('@')
        && email.len() >= 5
        && email.len() <= 254
        && !email.starts_with('@')
        && !email.ends_with('@')
    {
        Ok(email.to_lowercase())
    } else {
        Err(serde::de::Error::custom("Invalid email format"))
    }
}

fn validate_password<'de, D>(deserializer: D) -> Result<String, D::Error>
where
    D: serde::Deserializer<'de>,
{
    let password: String = serde::Deserialize::deserialize(deserializer)?;
    if password.len() >= 8
        && password.len() <= 128
        && password.chars().any(|c| c.is_ascii_uppercase())
        && password.chars().any(|c| c.is_ascii_lowercase())
        && password.chars().any(|c| c.is_ascii_digit())
    {
        Ok(password)
    } else {
        Err(serde::de::Error::custom(
            "Password must be 8-128 characters with at least one uppercase, one lowercase, and one digit",
        ))
    }
}
