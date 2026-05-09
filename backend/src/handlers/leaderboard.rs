use salvo::prelude::*;
use sqlx::PgPool;
use crate::handlers::auth;
use crate::models::{ApiResponse, LeaderboardSnapshot};
use serde::Serialize;

#[derive(Debug, Serialize)]
pub struct LeaderboardEntry {
    pub rank: i32,
    pub learner_id: String,
    pub nickname: String,
    pub score: i32,
    pub avatar_url: Option<String>,
}

async fn map_leaderboard_entries(
    entries: Vec<LeaderboardSnapshot>,
    pool: &PgPool,
) -> Result<Vec<LeaderboardEntry>, StatusError> {
    if entries.is_empty() {
        return Ok(Vec::new());
    }
    
    let learner_ids: Vec<String> = entries.iter()
        .map(|e| e.learner_id.to_string())
        .collect();
    
    let profiles = sqlx::query_as::<_, (String, Option<String>, Option<String>)>(
        "SELECT account_id::text, nickname, avatar_url FROM learner_profiles WHERE account_id = ANY($1::uuid[])"
    )
    .bind(&learner_ids)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    let profile_map: std::collections::HashMap<String, (Option<String>, Option<String>)> = profiles
        .into_iter()
        .map(|(id, n, a)| (id, (n, a)))
        .collect();
    
    let result = entries.into_iter()
        .map(|entry| {
            let (nickname, avatar_url) = profile_map
                .get(&entry.learner_id.to_string())
                .cloned()
                .unwrap_or_else(|| (None, None));
            
            LeaderboardEntry {
                rank: entry.rank_position,
                learner_id: entry.learner_id.to_string(),
                nickname: nickname.unwrap_or_else(|| "Anonymous".to_string()),
                score: entry.score,
                avatar_url,
            }
        })
        .collect();
    
    Ok(result)
}

#[handler]
pub async fn get_global_leaderboard(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<crate::models::ListResponse<LeaderboardEntry>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let period_key = chrono::Utc::now().format("%Y-%m").to_string();
    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let page_size = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * page_size;
    
    let entries = sqlx::query_as::<_, LeaderboardSnapshot>(
        "SELECT * FROM leaderboard_snapshots 
         WHERE board_type = 'total' AND period_key = $1 
         ORDER BY rank_position LIMIT $2 OFFSET $3"
    )
    .bind(&period_key)
    .bind(page_size)
    .bind(offset)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    let total: (i64,) = sqlx::query_as(
        "SELECT COUNT(*) FROM leaderboard_snapshots WHERE board_type = 'total' AND period_key = $1"
    )
    .bind(&period_key)
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    let result = map_leaderboard_entries(entries, pool).await?;
    
    let response = crate::models::ListResponse {
        items: result,
        meta: crate::models::ListMeta::new(page, page_size, total.0),
    };
    
    Ok(Json(ApiResponse::new(response)))
}

#[handler]
pub async fn get_friends_leaderboard(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<crate::models::ListResponse<LeaderboardEntry>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let period_key = chrono::Utc::now().format("%Y-%m").to_string();
    let learner_id = auth::get_current_account_id(depot)?;
    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let page_size = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * page_size;
    
    let entries = sqlx::query_as::<_, LeaderboardSnapshot>(
        "SELECT * FROM leaderboard_snapshots 
         WHERE board_type = 'total' AND period_key = $1 AND learner_id = $2
         ORDER BY rank_position LIMIT $3 OFFSET $4"
    )
    .bind(&period_key)
    .bind(learner_id)
    .bind(page_size)
    .bind(offset)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    let total: (i64,) = sqlx::query_as(
        "SELECT COUNT(*) FROM leaderboard_snapshots WHERE board_type = 'total' AND period_key = $1 AND learner_id = $2"
    )
    .bind(&period_key)
    .bind(learner_id)
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    let result = map_leaderboard_entries(entries, pool).await?;
    
    let response = crate::models::ListResponse {
        items: result,
        meta: crate::models::ListMeta::new(page, page_size, total.0),
    };
    
    Ok(Json(ApiResponse::new(response)))
}

#[handler]
pub async fn get_course_leaderboard(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<crate::models::ListResponse<LeaderboardEntry>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let course_id = req.param::<String>("course_id")
        .ok_or_else(StatusError::bad_request)?;
    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let page_size = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * page_size;
    
    let entries = sqlx::query_as::<_, LeaderboardSnapshot>(
        "SELECT * FROM leaderboard_snapshots 
         WHERE board_type = 'total' AND period_key = $1 
         ORDER BY rank_position LIMIT $2 OFFSET $3"
    )
    .bind(&course_id)
    .bind(page_size)
    .bind(offset)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    let total: (i64,) = sqlx::query_as(
        "SELECT COUNT(*) FROM leaderboard_snapshots WHERE board_type = 'total' AND period_key = $1"
    )
    .bind(&course_id)
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    let result = map_leaderboard_entries(entries, pool).await?;
    
    let response = crate::models::ListResponse {
        items: result,
        meta: crate::models::ListMeta::new(page, page_size, total.0),
    };
    
    Ok(Json(ApiResponse::new(response)))
}
