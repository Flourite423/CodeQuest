use salvo::prelude::*;
use sqlx::PgPool;
use crate::handlers::auth;
use crate::models::{ApiResponse, DailyChallenge, DailyChallengeRecord};
use uuid::Uuid;
use serde::Deserialize;
use chrono::Utc;

#[derive(Debug, Deserialize)]
pub struct CreateDailyChallengeRequest {
    pub title: String,
    pub exercise_id: String,
    pub difficulty: String,
    pub time_limit_seconds: i32,
    pub reward_xp: i32,
}

#[derive(Debug, Deserialize)]
pub struct AttemptDailyChallengeRequest {
    pub score: i32,
    pub elapsed_seconds: Option<i32>,
}

#[handler]
pub async fn get_today_challenge(depot: &mut Depot) -> Result<Json<ApiResponse<DailyChallenge>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let today = Utc::now().date_naive();
    
    let challenge = sqlx::query_as::<_, DailyChallenge>(
        "SELECT * FROM daily_challenges WHERE challenge_date = $1 AND status = 'published'"
    )
    .bind(today)
    .fetch_optional(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?
    .ok_or_else(StatusError::not_found)?;
    
    Ok(Json(ApiResponse::new(challenge)))
}

#[handler]
pub async fn list_daily_challenges(depot: &mut Depot) -> Result<Json<ApiResponse<Vec<DailyChallenge>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let challenges = sqlx::query_as::<_, DailyChallenge>(
        "SELECT * FROM daily_challenges WHERE status = 'published' ORDER BY challenge_date DESC LIMIT 30"
    )
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(Json(ApiResponse::new(challenges)))
}

#[handler]
pub async fn create_daily_challenge(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let body: CreateDailyChallengeRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let id = Uuid::new_v4();
    let exercise_id = Uuid::parse_str(&body.exercise_id)
        .map_err(|_| StatusError::bad_request().brief("Invalid exercise_id"))?;
    let today = Utc::now().date_naive();
    
    sqlx::query(
        "INSERT INTO daily_challenges (id, challenge_date, title, exercise_id, difficulty, 
         time_limit_seconds, reward_xp, status) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, 'draft')"
    )
    .bind(id)
    .bind(today)
    .bind(&body.title)
    .bind(exercise_id)
    .bind(&body.difficulty)
    .bind(body.time_limit_seconds)
    .bind(body.reward_xp)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::CREATED)
}

#[handler]
pub async fn attempt_daily_challenge(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let challenge_id = req.param::<String>("id")
        .ok_or_else(StatusError::bad_request)?;
    
    let body: AttemptDailyChallengeRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let id = Uuid::new_v4();
    let learner_id = auth::get_current_account_id(depot)?;
    let challenge_uuid = Uuid::parse_str(&challenge_id)
        .map_err(|_| StatusError::bad_request().brief("Invalid challenge_id"))?;
    
    sqlx::query(
        "INSERT INTO daily_challenge_records (id, daily_challenge_id, learner_id, status, 
         score, elapsed_seconds, streak_after_completion) 
         VALUES ($1, $2, $3, 'completed', $4, $5, 1)"
    )
    .bind(id)
    .bind(challenge_uuid)
    .bind(learner_id)
    .bind(body.score)
    .bind(body.elapsed_seconds)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::CREATED)
}

#[handler]
pub async fn get_daily_challenge_records(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<Vec<DailyChallengeRecord>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let challenge_id = req.param::<String>("id")
        .ok_or_else(StatusError::bad_request)?;
    
    let learner_id = auth::get_current_account_id(depot)?;
    let challenge_uuid = Uuid::parse_str(&challenge_id)
        .map_err(|_| StatusError::bad_request().brief("Invalid challenge_id"))?;
    
    let records = sqlx::query_as::<_, DailyChallengeRecord>(
        "SELECT * FROM daily_challenge_records WHERE daily_challenge_id = $1 AND learner_id = $2 ORDER BY created_at DESC"
    )
    .bind(challenge_uuid)
    .bind(learner_id)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(Json(ApiResponse::new(records)))
}

#[derive(Debug, Deserialize)]
pub struct UpdateDailyChallengeRequest {
    pub title: Option<String>,
    pub difficulty: Option<String>,
    pub time_limit_seconds: Option<i32>,
    pub reward_xp: Option<i32>,
    pub status: Option<String>,
}

#[handler]
pub async fn get_daily_challenge(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<DailyChallenge>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let challenge_id = req.param::<String>("daily_challenge_id")
        .ok_or_else(StatusError::bad_request)?;
    
    let challenge_uuid = Uuid::parse_str(&challenge_id)
        .map_err(|_| StatusError::bad_request().brief("Invalid challenge_id"))?;
    
    let challenge = sqlx::query_as::<_, DailyChallenge>("SELECT * FROM daily_challenges WHERE id = $1")
        .bind(challenge_uuid)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;
    
    Ok(Json(ApiResponse::new(challenge)))
}

#[handler]
pub async fn update_daily_challenge(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let challenge_id = req.param::<String>("daily_challenge_id")
        .ok_or_else(StatusError::bad_request)?;
    
    let body: UpdateDailyChallengeRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let challenge_uuid = Uuid::parse_str(&challenge_id)
        .map_err(|_| StatusError::bad_request().brief("Invalid challenge_id"))?;
    
    sqlx::query(
        "UPDATE daily_challenges SET 
         title = COALESCE($2, title),
         difficulty = COALESCE($3, difficulty),
         time_limit_seconds = COALESCE($4, time_limit_seconds),
         reward_xp = COALESCE($5, reward_xp),
         status = COALESCE($6, status),
         updated_at = NOW()
         WHERE id = $1"
    )
    .bind(challenge_uuid)
    .bind(&body.title)
    .bind(&body.difficulty)
    .bind(body.time_limit_seconds)
    .bind(body.reward_xp)
    .bind(&body.status)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::OK)
}

#[handler]
pub async fn delete_daily_challenge(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let challenge_id = req.param::<String>("daily_challenge_id")
        .ok_or_else(StatusError::bad_request)?;
    
    let challenge_uuid = Uuid::parse_str(&challenge_id)
        .map_err(|_| StatusError::bad_request().brief("Invalid challenge_id"))?;
    
    sqlx::query("DELETE FROM daily_challenges WHERE id = $1")
        .bind(challenge_uuid)
        .execute(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::NO_CONTENT)
}

#[derive(Debug, Deserialize)]
pub struct SubmitDailyChallengeRequest {
    pub score: i32,
    pub elapsed_seconds: Option<i32>,
}

#[handler]
pub async fn submit_daily_challenge(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let challenge_id = req.param::<String>("daily_challenge_id")
        .ok_or_else(StatusError::bad_request)?;
    
    let body: SubmitDailyChallengeRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let id = Uuid::new_v4();
    let learner_id = auth::get_current_account_id(depot)?;
    let challenge_uuid = Uuid::parse_str(&challenge_id)
        .map_err(|_| StatusError::bad_request().brief("Invalid challenge_id"))?;
    
    sqlx::query(
        "INSERT INTO daily_challenge_records (id, daily_challenge_id, learner_id, status, 
         score, elapsed_seconds, streak_after_completion) 
         VALUES ($1, $2, $3, 'completed', $4, $5, 1)"
    )
    .bind(id)
    .bind(challenge_uuid)
    .bind(learner_id)
    .bind(body.score)
    .bind(body.elapsed_seconds)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::CREATED)
}
