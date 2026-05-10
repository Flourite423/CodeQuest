use salvo::prelude::*;
use sqlx::PgPool;
use crate::handlers::auth;
use crate::models::{Account, ApiResponse, LearnerProfile};
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
pub async fn list_users(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<Vec<Account>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let per_page = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * per_page;
    
    let users = sqlx::query_as::<_, Account>(
        "SELECT * FROM accounts WHERE default_role = 'learner' ORDER BY created_at DESC LIMIT $1 OFFSET $2"
    )
    .bind(per_page)
    .bind(offset)
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
        .bind(id)
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
    pub theme_mode: Option<String>,
    pub daily_goal_minutes: Option<i32>,
}

#[handler]
pub async fn get_profile(depot: &mut Depot) -> Result<Json<ApiResponse<LearnerProfile>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let account_id = auth::get_current_account_id(depot)?;
    
    let profile = sqlx::query_as::<_, LearnerProfile>(
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
         WHERE account_id = $1"
    )
    .bind(account_id)
    .fetch_optional(pool)
    .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    let profile = profile.ok_or_else(StatusError::not_found)?;
    
    Ok(Json(ApiResponse::new(profile)))
}

#[handler]
pub async fn update_profile(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<LearnerProfile>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let account_id = auth::get_current_account_id(depot)?;
    
    let body: UpdateProfileRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let theme_mode = body.theme_mode.as_deref().map(|value| match value {
        "light" => "light",
        "dark" => "dark",
        _ => "system",
    });

    sqlx::query(
        "INSERT INTO learner_profiles (account_id, nickname, avatar_url, bio, theme_mode, daily_goal_minutes)
         VALUES ($1, COALESCE($2, 'Learner'), $3, $4, COALESCE($5::theme_mode, 'system'::theme_mode), COALESCE($6, 30))
         ON CONFLICT (account_id)
         DO UPDATE SET
            nickname = COALESCE($2, learner_profiles.nickname),
            avatar_url = COALESCE($3, learner_profiles.avatar_url),
            bio = COALESCE($4, learner_profiles.bio),
            theme_mode = COALESCE($5::theme_mode, learner_profiles.theme_mode),
            daily_goal_minutes = COALESCE($6, learner_profiles.daily_goal_minutes),
            updated_at = NOW()"
    )
    .bind(account_id)
    .bind(&body.nickname)
    .bind(&body.avatar_url)
    .bind(&body.bio)
    .bind(theme_mode)
    .bind(body.daily_goal_minutes)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    let profile = sqlx::query_as::<_, LearnerProfile>(
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
         WHERE account_id = $1"
    )
    .bind(account_id)
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    Ok(Json(ApiResponse::new(profile)))
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
