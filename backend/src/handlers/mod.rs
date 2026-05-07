use salvo::prelude::*;
use salvo::affix_state;
use sqlx::PgPool;
use crate::models::{ApiResponse, ApiError};

pub mod auth;
pub mod course;
pub mod challenge;
pub mod user;

#[handler]
pub async fn health_check() -> Json<ApiResponse<serde_json::Value>> {
    Json(ApiResponse::new(serde_json::json!({
        "status": "healthy",
        "service": "learning-app-backend",
        "version": env!("CARGO_PKG_VERSION"),
    })))
}

#[handler]
pub async fn not_found() -> StatusError {
    StatusError::not_found()
}
