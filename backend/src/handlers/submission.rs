use salvo::prelude::*;
use sqlx::PgPool;
use crate::handlers::auth;
use crate::models::{ApiResponse, Submission};
use crate::services::judge_service::JudgeService;
use crate::services::xp_service::XpService;
use uuid::Uuid;
use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct CreateSubmissionRequest {
    pub exercise_id: String,
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
    
    let submission = sqlx::query_as::<_, Submission>("SELECT id, exercise_id, learner_id, chapter_id, attempt_no, source_code, judge_status::text AS judge_status, score, passed_case_count, total_case_count, error_summary, runtime_ms, content_version, rule_version, submitted_at, completed_at FROM submissions WHERE id = $1")
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
    
    let body: CreateSubmissionRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let id = Uuid::new_v4();
    let learner_id = auth::get_current_account_id(depot)?;
    
    let chapter_id: (Uuid,) = sqlx::query_as("SELECT chapter_id FROM exercises WHERE id = $1")
        .bind(&body.exercise_id)
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::bad_request().brief("Exercise not found"))?;
    
    let submission = sqlx::query_as::<_, Submission>(
        "INSERT INTO submissions (id, exercise_id, learner_id, chapter_id, attempt_no, source_code, 
         judge_status, score, passed_case_count, total_case_count, content_version, rule_version) 
         VALUES ($1, $2, $3, $4, 1, $5, 'pending', 0, 0, 0, 1, 1)
         RETURNING id, exercise_id, learner_id, chapter_id, attempt_no, source_code, judge_status::text AS judge_status, score, passed_case_count, total_case_count, error_summary, runtime_ms, content_version, rule_version, submitted_at, completed_at"
    )
    .bind(id)
    .bind(&body.exercise_id)
    .bind(learner_id)
    .bind(chapter_id.0)
    .bind(&body.source_code)
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    // 异步触发判题，不阻塞 HTTP 响应
    let submission_id_str = submission.id.to_string();
    let pool_clone = pool.clone();
    let exercise_id_for_xp = Uuid::parse_str(&body.exercise_id).unwrap_or_default();
    tokio::spawn(async move {
        match JudgeService::judge_submission(&pool_clone, &submission_id_str).await {
            Ok(result) => {
                let _ = sqlx::query(
                    "UPDATE submissions \
                     SET judge_status = $2::judge_status, score = $3, \
                         passed_case_count = $4, total_case_count = $5, \
                         error_summary = $6, runtime_ms = $7, completed_at = NOW() \
                     WHERE id = $1",
                )
                .bind(&submission_id_str)
                .bind(result.status.as_str())
                .bind(result.score)
                .bind(result.passed_case_count)
                .bind(result.total_case_count)
                .bind(result.error_summary)
                .bind(result.runtime_ms)
                .execute(&pool_clone)
                .await;

                // 判题通过后奖励 XP
                if result.status.as_str() == "passed" {
                    let _ = XpService::reward_submission_xp(
                        &pool_clone,
                        learner_id,
                        exercise_id_for_xp,
                        result.score,
                    )
                    .await;
                }
            }
            Err(e) => {
                eprintln!("Judge error: {}", e);
                let _ = sqlx::query(
                    "UPDATE submissions SET judge_status = 'error'::judge_status, error_summary = $2 WHERE id = $1",
                )
                .bind(&submission_id_str)
                .bind(Some(e))
                .execute(&pool_clone)
                .await;
            }
        }
    });
    
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
