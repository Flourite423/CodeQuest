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
pub async fn health_check(depot: &mut Depot) -> Result<Json<ApiResponse<serde_json::Value>>, StatusError> {
    let pool = depot.obtain::<sqlx::PgPool>()
        .map_err(|_| StatusError::service_unavailable().brief("Database pool not available"))?;
    
    let db_status = match sqlx::query("SELECT 1").fetch_one(pool).await {
        Ok(_) => "connected",
        Err(_) => "disconnected",
    };
    
    let pool_status = serde_json::json!({
        "size": pool.size(),
        "max_size": 20,
        "idle": pool.num_idle(),
    });
    
    Ok(Json(ApiResponse::new(serde_json::json!({
        "status": "healthy",
        "service": "learning-app-backend",
        "version": env!("CARGO_PKG_VERSION"),
        "database": db_status,
        "pool": pool_status,
    }))))
}

#[handler]
pub async fn not_found() -> StatusError {
    StatusError::not_found()
}
