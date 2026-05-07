use salvo::prelude::*;
use sqlx::PgPool;
use crate::handlers::auth;
use crate::models::{ApiResponse, Account};
use serde::Deserialize;
use uuid::Uuid;

#[derive(Debug, Deserialize)]
#[allow(dead_code)]
pub struct UpdateUserRequest {
    pub email: Option<String>,
    pub default_role: Option<String>,
    pub account_status: Option<String>,
}

#[handler]
pub async fn list_users(depot: &mut Depot) -> Result<Json<ApiResponse<Vec<Account>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let users = sqlx::query_as::<_, Account>("SELECT * FROM accounts WHERE default_role = 'learner' ORDER BY created_at DESC")
        .fetch_all(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(Json(ApiResponse::new(users)))
}

#[handler]
pub async fn get_user(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<Account>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("id")
        .ok_or_else(StatusError::bad_request)?;
    
    let user = sqlx::query_as::<_, Account>("SELECT * FROM accounts WHERE id = $1")
        .bind(&id)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;
    
    Ok(Json(ApiResponse::new(user)))
}

#[handler]
pub async fn update_user(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("id")
        .ok_or_else(StatusError::bad_request)?;
    
    let body: UpdateUserRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    sqlx::query(
        "UPDATE accounts SET 
         email = COALESCE($2, email),
         default_role = COALESCE($3, default_role),
         account_status = COALESCE($4, account_status),
         updated_at = NOW()
         WHERE id = $1"
    )
    .bind(&id)
    .bind(&body.email)
    .bind(&body.default_role)
    .bind(&body.account_status)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::OK)
}

#[handler]
pub async fn delete_user(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("user_id")
        .ok_or_else(StatusError::bad_request)?;
    
    let id = Uuid::parse_str(&id)
        .map_err(|_| StatusError::bad_request().brief("Invalid user ID"))?;
    
    sqlx::query("DELETE FROM accounts WHERE id = $1")
        .bind(&id)
        .execute(pool)
        .await
        .map_err(|e| {
            eprintln!("Database error deleting user: {:?}", e);
            StatusError::internal_server_error()
        })?;
    
    Ok(StatusCode::NO_CONTENT)
}

#[derive(Debug, Deserialize)]
pub struct UpdateProfileRequest {
    pub nickname: Option<String>,
    pub avatar_url: Option<String>,
    pub bio: Option<String>,
}

#[handler]
pub async fn get_profile(depot: &mut Depot) -> Result<Json<ApiResponse<serde_json::Value>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let account_id = auth::get_current_account_id(depot)?;
    
    let profile = sqlx::query_as::<_, (Option<String>, Option<String>, Option<String>)>(
        "SELECT nickname, avatar_url, bio FROM user_profiles WHERE account_id = $1"
    )
    .bind(account_id)
    .fetch_optional(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    let (nickname, avatar_url, bio) = profile.unwrap_or((None, None, None));
    
    Ok(Json(ApiResponse::new(serde_json::json!({
        "nickname": nickname,
        "avatar_url": avatar_url,
        "bio": bio
    }))))
}

#[handler]
pub async fn update_profile(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let account_id = auth::get_current_account_id(depot)?;
    
    let body: UpdateProfileRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    sqlx::query(
        "INSERT INTO user_profiles (account_id, nickname, avatar_url, bio) 
         VALUES ($1, $2, $3, $4)
         ON CONFLICT (account_id) 
         DO UPDATE SET 
            nickname = COALESCE($2, user_profiles.nickname),
            avatar_url = COALESCE($3, user_profiles.avatar_url),
            bio = COALESCE($4, user_profiles.bio),
            updated_at = NOW()"
    )
    .bind(account_id)
    .bind(&body.nickname)
    .bind(&body.avatar_url)
    .bind(&body.bio)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::OK)
}

#[handler]
pub async fn get_personal_stats(depot: &mut Depot) -> Result<Json<ApiResponse<serde_json::Value>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let account_id = auth::get_current_account_id(depot)?;
    
    let completed_courses: (i64,) = sqlx::query_as(
        "SELECT COUNT(*) FROM course_progress WHERE learner_id = $1 AND status = 'completed'"
    )
    .bind(account_id)
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    let total_submissions: (i64,) = sqlx::query_as(
        "SELECT COUNT(*) FROM submissions WHERE learner_id = $1"
    )
    .bind(account_id)
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(Json(ApiResponse::new(serde_json::json!({
        "completed_courses": completed_courses.0,
        "total_submissions": total_submissions.0
    }))))
}
