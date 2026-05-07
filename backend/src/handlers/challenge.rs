use salvo::prelude::*;
use sqlx::PgPool;
use crate::handlers::auth;
use crate::models::{ApiResponse, Challenge};
use uuid::Uuid;
use serde::Deserialize;

#[derive(Debug, Deserialize)]
#[allow(dead_code)]
pub struct CreateChallengeRequest {
    pub challenge_code: String,
    pub title: String,
    pub summary: String,
    pub related_course_id: Option<String>,
    pub difficulty: String,
    pub reward_xp: i32,
}

#[derive(Debug, Deserialize)]
#[allow(dead_code)]
pub struct UpdateChallengeRequest {
    pub title: Option<String>,
    pub summary: Option<String>,
    pub difficulty: Option<String>,
    pub reward_xp: Option<i32>,
    pub status: Option<String>,
}

#[handler]
pub async fn list_challenges(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<Vec<Challenge>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let per_page = req.query::<i64>("per_page").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * per_page;
    
    let challenges = sqlx::query_as::<_, Challenge>(
        "SELECT * FROM challenges WHERE status = 'published' ORDER BY sort_order LIMIT $1 OFFSET $2"
    )
    .bind(per_page)
    .bind(offset)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(Json(ApiResponse::new(challenges)))
}

#[handler]
pub async fn get_challenge(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<Challenge>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("id")
        .ok_or_else(StatusError::bad_request)?;
    
    let challenge = sqlx::query_as::<_, Challenge>("SELECT * FROM challenges WHERE id = $1")
        .bind(&id)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;
    
    Ok(Json(ApiResponse::new(challenge)))
}

#[handler]
pub async fn create_challenge(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let body: CreateChallengeRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let id = Uuid::new_v4();
    let related_course_id = body.related_course_id.as_ref()
        .and_then(|s| Uuid::parse_str(s).ok());
    
    sqlx::query(
        "INSERT INTO challenges (id, challenge_code, title, summary, related_course_id, 
         difficulty, reward_xp, status, sort_order, content_version) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, 'draft', 0, 1)"
    )
    .bind(id)
    .bind(&body.challenge_code)
    .bind(&body.title)
    .bind(&body.summary)
    .bind(related_course_id)
    .bind(&body.difficulty)
    .bind(body.reward_xp)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::CREATED)
}

#[handler]
pub async fn update_challenge(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("id")
        .ok_or_else(StatusError::bad_request)?;
    
    let body: UpdateChallengeRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    sqlx::query(
        "UPDATE challenges SET 
         title = COALESCE($2, title),
         summary = COALESCE($3, summary),
         difficulty = COALESCE($4, difficulty),
         reward_xp = COALESCE($5, reward_xp),
         status = COALESCE($6, status),
         updated_at = NOW()
         WHERE id = $1"
    )
    .bind(&id)
    .bind(&body.title)
    .bind(&body.summary)
    .bind(&body.difficulty)
    .bind(body.reward_xp)
    .bind(&body.status)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::OK)
}

#[handler]
pub async fn delete_challenge(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("id")
        .ok_or_else(StatusError::bad_request)?;
    
    sqlx::query("DELETE FROM challenges WHERE id = $1")
        .bind(&id)
        .execute(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::NO_CONTENT)
}

#[derive(Debug, Deserialize)]
pub struct AttemptChallengeRequest {
    pub score: i32,
}

#[handler]
pub async fn attempt_challenge(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let challenge_id = req.param::<String>("challenge_id")
        .ok_or_else(StatusError::bad_request)?;
    
    let body: AttemptChallengeRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let learner_id = auth::get_current_account_id(depot)?;
    let challenge_uuid = Uuid::parse_str(&challenge_id)
        .map_err(|_| StatusError::bad_request().brief("Invalid challenge_id"))?;
    
    sqlx::query(
        "INSERT INTO challenge_attempts (id, challenge_id, learner_id, status, score, attempt_no) 
         VALUES ($1, $2, $3, 'completed', $4, 1)"
    )
    .bind(Uuid::new_v4())
    .bind(challenge_uuid)
    .bind(learner_id)
    .bind(body.score)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::CREATED)
}
