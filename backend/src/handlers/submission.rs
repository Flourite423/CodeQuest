use salvo::prelude::*;
use sqlx::PgPool;
use crate::handlers::auth;
use crate::models::{ApiResponse, Submission};
use uuid::Uuid;
use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct CreateSubmissionRequest {
    pub source_code: String,
}

#[derive(Debug, Deserialize)]
#[allow(dead_code)]
pub struct UpdateSubmissionRequest {
    pub judge_status: Option<String>,
    pub score: Option<i32>,
    pub passed_case_count: Option<i32>,
    pub total_case_count: Option<i32>,
    pub error_summary: Option<String>,
    pub runtime_ms: Option<i32>,
}

#[handler]
pub async fn get_submission(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<Submission>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("submission_id")
        .or_else(|| req.param::<String>("id"))
        .ok_or_else(StatusError::bad_request)?;
    
    let submission = sqlx::query_as::<_, Submission>("SELECT * FROM submissions WHERE id = $1")
        .bind(&id)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;
    
    Ok(Json(ApiResponse::new(submission)))
}

#[handler]
pub async fn create_submission(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<Submission>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let exercise_id = req.param::<String>("exercise_id")
        .or_else(|| req.query::<String>("exercise_id"))
        .ok_or_else(StatusError::bad_request)?;
    
    let body: CreateSubmissionRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let id = Uuid::new_v4();
    let learner_id = auth::get_current_account_id(depot)?;
    
    let chapter_id: (Uuid,) = sqlx::query_as("SELECT chapter_id FROM exercises WHERE id = $1")
        .bind(&exercise_id)
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::bad_request().brief("Exercise not found"))?;
    
    let submission = sqlx::query_as::<_, Submission>(
        "INSERT INTO submissions (id, exercise_id, learner_id, chapter_id, attempt_no, source_code, 
         judge_status, score, passed_case_count, total_case_count, content_version, rule_version) 
         VALUES ($1, $2, $3, $4, 1, $5, 'pending', 0, 0, 0, 1, 1)
         RETURNING *"
    )
    .bind(id)
    .bind(&exercise_id)
    .bind(learner_id)
    .bind(chapter_id.0)
    .bind(&body.source_code)
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(Json(ApiResponse::new(submission)))
}

#[handler]
pub async fn update_submission(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("id")
        .ok_or_else(StatusError::bad_request)?;
    
    let body: UpdateSubmissionRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    sqlx::query(
        "UPDATE submissions SET 
         judge_status = COALESCE($2, judge_status),
         score = COALESCE($3, score),
         passed_case_count = COALESCE($4, passed_case_count),
         total_case_count = COALESCE($5, total_case_count),
         error_summary = COALESCE($6, error_summary),
         runtime_ms = COALESCE($7, runtime_ms),
         completed_at = CASE WHEN $2 IS NOT NULL THEN NOW() ELSE completed_at END,
         updated_at = NOW()
         WHERE id = $1"
    )
    .bind(&id)
    .bind(&body.judge_status)
    .bind(body.score)
    .bind(body.passed_case_count)
    .bind(body.total_case_count)
    .bind(&body.error_summary)
    .bind(body.runtime_ms)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::OK)
}
