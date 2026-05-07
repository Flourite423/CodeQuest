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
    let mut result = Vec::with_capacity(entries.len());
    
    for entry in entries {
        let profile = sqlx::query_as::<_, (Option<String>, Option<String>)>(
            "SELECT nickname, avatar_url FROM user_profiles WHERE account_id = $1"
        )
        .bind(entry.learner_id)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
        
        let (nickname, avatar_url) = profile
            .map(|(n, a)| (n.unwrap_or_else(|| "Anonymous".to_string()), a))
            .unwrap_or_else(|| ("Anonymous".to_string(), None));
        
        result.push(LeaderboardEntry {
            rank: entry.rank_position,
            learner_id: entry.learner_id.to_string(),
            nickname,
            score: entry.score,
            avatar_url,
        });
    }
    
    Ok(result)
}

#[handler]
pub async fn get_global_leaderboard(depot: &mut Depot) -> Result<Json<ApiResponse<Vec<LeaderboardEntry>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let period_key = chrono::Utc::now().format("%Y-%m").to_string();
    
    let entries = sqlx::query_as::<_, LeaderboardSnapshot>(
        "SELECT * FROM leaderboard_snapshots 
         WHERE board_type = 'total' AND period_key = $1 
         ORDER BY rank_position LIMIT 100"
    )
    .bind(&period_key)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    let result = map_leaderboard_entries(entries, pool).await?;
    
    Ok(Json(ApiResponse::new(result)))
}

#[handler]
pub async fn get_friends_leaderboard(depot: &mut Depot) -> Result<Json<ApiResponse<Vec<LeaderboardEntry>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let period_key = chrono::Utc::now().format("%Y-%m").to_string();
    let learner_id = auth::get_current_account_id(depot)?;
    
    let entries = sqlx::query_as::<_, LeaderboardSnapshot>(
        "SELECT * FROM leaderboard_snapshots 
         WHERE board_type = 'total' AND period_key = $1 AND learner_id = $2
         ORDER BY rank_position LIMIT 50"
    )
    .bind(&period_key)
    .bind(learner_id)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    let result = map_leaderboard_entries(entries, pool).await?;
    
    Ok(Json(ApiResponse::new(result)))
}

#[handler]
pub async fn get_course_leaderboard(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<Vec<LeaderboardEntry>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let course_id = req.param::<String>("course_id")
        .ok_or_else(StatusError::bad_request)?;
    
    let entries = sqlx::query_as::<_, LeaderboardSnapshot>(
        "SELECT * FROM leaderboard_snapshots 
         WHERE board_type = 'total' AND period_key = $1 
         ORDER BY rank_position LIMIT 100"
    )
    .bind(&course_id)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    let result = map_leaderboard_entries(entries, pool).await?;
    
    Ok(Json(ApiResponse::new(result)))
}
