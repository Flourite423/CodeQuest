use salvo::prelude::*;
use sqlx::PgPool;

use crate::handlers::auth;
use crate::models::{ApiResponse, LearnerBadge, XpLedger};

#[handler]
pub async fn get_xp_ledger(depot: &mut Depot) -> Result<Json<ApiResponse<Vec<XpLedger>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let learner_id = auth::get_current_account_id(depot)?;
    let records = sqlx::query_as::<_, XpLedger>(
        "SELECT * FROM xp_ledger WHERE learner_id = $1 ORDER BY created_at DESC"
    )
    .bind(learner_id)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    Ok(Json(ApiResponse::new(records)))
}

#[handler]
pub async fn get_learner_badges(depot: &mut Depot) -> Result<Json<ApiResponse<Vec<LearnerBadge>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let learner_id = auth::get_current_account_id(depot)?;
    let badges = sqlx::query_as::<_, LearnerBadge>(
        "SELECT * FROM learner_badges WHERE learner_id = $1 ORDER BY awarded_at DESC"
    )
    .bind(learner_id)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    Ok(Json(ApiResponse::new(badges)))
}

#[handler]
pub async fn get_rewards(depot: &mut Depot) -> Result<Json<ApiResponse<serde_json::Value>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let learner_id = auth::get_current_account_id(depot)?;
    
    let total_xp: (i64,) = sqlx::query_as(
        "SELECT COALESCE(SUM(delta_xp), 0) FROM xp_ledger WHERE learner_id = $1"
    )
    .bind(learner_id)
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    let badges = sqlx::query_as::<_, LearnerBadge>(
        "SELECT * FROM learner_badges WHERE learner_id = $1 ORDER BY awarded_at DESC"
    )
    .bind(learner_id)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    let xp_records = sqlx::query_as::<_, XpLedger>(
        "SELECT * FROM xp_ledger WHERE learner_id = $1 ORDER BY created_at DESC LIMIT 10"
    )
    .bind(learner_id)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    let total = badges.len() as i64;
    let meta = crate::models::ListMeta::new(1, total.max(1), total);

    Ok(Json(ApiResponse::new(serde_json::json!({
        "summary": {
            "total_xp": total_xp.0,
            "badge_count": badges.len() as i64
        },
        "badges": badges,
        "xp_ledger": xp_records,
        "meta": meta
    }))))
}
