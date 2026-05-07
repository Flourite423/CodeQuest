use salvo::prelude::*;
use crate::models::ApiResponse;

pub mod auth;
pub mod admin;
pub mod ai_help;
pub mod chapter;
pub mod course;
pub mod challenge;
pub mod daily_challenge;
pub mod exercise;
pub mod leaderboard;
pub mod progress;
pub mod reward;
pub mod social;
pub mod submission;
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
