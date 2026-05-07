use salvo::prelude::*;
use serde::Deserialize;
use sqlx::PgPool;
use uuid::Uuid;

use crate::config::AppConfig;
use crate::handlers::auth;
use crate::models::{AiHelpRequest, ApiResponse};

#[derive(Debug, Deserialize)]
pub struct CreateAiHelpRequest {
    pub exercise_id: Option<String>,
    pub submission_id: Option<String>,
    pub request_type: String,
    pub source_code: Option<String>,
    pub error_context_json: Option<serde_json::Value>,
}

#[handler]
pub async fn create_ai_help(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<AiHelpRequest>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let body: CreateAiHelpRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;

    let id = Uuid::new_v4();
    let learner_id = auth::get_current_account_id(depot)?;
    let exercise_id = body.exercise_id.as_deref().and_then(|value| Uuid::parse_str(value).ok());
    let submission_id = body.submission_id.as_deref().and_then(|value| Uuid::parse_str(value).ok());

    let cfg = depot.obtain::<AppConfig>()
        .map_err(|_| StatusError::internal_server_error().brief("Config not available"))?;
    
    let (response_text, response_json, provider) = if cfg.ai.provider == "mock" {
        (cfg.ai.mock_response.clone(), serde_json::json!({"message": cfg.ai.mock_response}), "mock")
    } else {
        (cfg.ai.mock_response.clone(), serde_json::json!({"message": cfg.ai.mock_response}), cfg.ai.provider.as_str())
    };
    
    let request_type = match body.request_type.as_str() {
        "error_explanation" => crate::models::AiRequestType::ErrorExplanation,
        "hint" => crate::models::AiRequestType::Hint,
        _ => crate::models::AiRequestType::Hint,
    };

    let record = sqlx::query_as::<_, AiHelpRequest>(
        "INSERT INTO ai_help_requests \
        (id, learner_id, exercise_id, submission_id, request_type, source_code, error_context_json, response_text, response_structured_json, provider_name, token_usage, latency_ms, status) \
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, 0, 0, 'succeeded') \
        RETURNING *"
    )
    .bind(id)
    .bind(learner_id)
    .bind(exercise_id)
    .bind(submission_id)
    .bind(request_type)
    .bind(&body.source_code)
    .bind(&body.error_context_json)
    .bind(Some(response_text))
    .bind(Some(response_json))
    .bind(provider)
    .fetch_one(pool)
    .await
    .map_err(|e| {
        eprintln!("Database error: {:?}", e);
        StatusError::internal_server_error()
    })?;

    Ok(Json(ApiResponse::new(record)))
}

#[handler]
pub async fn list_ai_help_history(depot: &mut Depot) -> Result<Json<ApiResponse<Vec<AiHelpRequest>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let learner_id = auth::get_current_account_id(depot)?;
    let records = sqlx::query_as::<_, AiHelpRequest>(
        "SELECT * FROM ai_help_requests WHERE learner_id = $1 ORDER BY created_at DESC"
    )
    .bind(learner_id)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    Ok(Json(ApiResponse::new(records)))
}
