use salvo::prelude::*;
use sqlx::PgPool;
use uuid::Uuid;
use crate::handlers::auth;
use crate::models::{ApiResponse, ListResponse};
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct LeaderboardEntry {
    pub rank: i64,
    pub learner_id: Uuid,
    pub nickname: String,
    pub score: i32,
    pub level: i32,
    pub avatar_url: Option<String>,
}

#[handler]
pub async fn get_global_leaderboard(
    req: &mut Request,
    depot: &mut Depot,
) -> Result<Json<ApiResponse<ListResponse<LeaderboardEntry>>>, StatusError> {
    let pool = depot
        .obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let page_size = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * page_size;

    // 先查总数
    let total: (i64,) = sqlx::query_as(
        "SELECT COUNT(*)
         FROM learner_profiles lp
         INNER JOIN accounts a ON lp.account_id = a.id
         WHERE a.account_status = 'active'",
    )
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    let entries = sqlx::query_as::<_, LeaderboardEntry>(
        "SELECT
            lp.account_id as learner_id,
            lp.nickname,
            lp.total_xp as score,
            lp.current_level as level,
            lp.avatar_url,
            RANK() OVER (ORDER BY lp.total_xp DESC) as rank
         FROM learner_profiles lp
         INNER JOIN accounts a ON lp.account_id = a.id
         WHERE a.account_status = 'active'
         ORDER BY lp.total_xp DESC
         LIMIT $1 OFFSET $2",
    )
    .bind(page_size)
    .bind(offset)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    let response = ListResponse {
        items: entries,
        meta: crate::models::ListMeta::new(page, page_size, total.0),
    };

    Ok(Json(ApiResponse::new(response)))
}

#[handler]
pub async fn get_friends_leaderboard(
    req: &mut Request,
    depot: &mut Depot,
) -> Result<Json<ApiResponse<ListResponse<LeaderboardEntry>>>, StatusError> {
    let pool = depot
        .obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let learner_id = auth::get_current_account_id(depot)?;

    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let page_size = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * page_size;

    // 先查好友总数
    let total: (i64,) = sqlx::query_as(
        "SELECT COUNT(*)
         FROM learner_profiles lp
         INNER JOIN accounts a ON lp.account_id = a.id
         INNER JOIN friend_relations f ON (
             (f.requester_id = $1 AND f.addressee_id = lp.account_id)
             OR (f.addressee_id = $1 AND f.requester_id = lp.account_id)
         )
         WHERE f.status = 'accepted' AND a.account_status = 'active'",
    )
    .bind(learner_id)
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    let entries = sqlx::query_as::<_, LeaderboardEntry>(
        "SELECT
            lp.account_id as learner_id,
            lp.nickname,
            lp.total_xp as score,
            lp.current_level as level,
            lp.avatar_url,
            RANK() OVER (ORDER BY lp.total_xp DESC) as rank
         FROM learner_profiles lp
         INNER JOIN accounts a ON lp.account_id = a.id
         INNER JOIN friend_relations f ON (
             (f.requester_id = $1 AND f.addressee_id = lp.account_id)
             OR (f.addressee_id = $1 AND f.requester_id = lp.account_id)
         )
         WHERE f.status = 'accepted' AND a.account_status = 'active'
         ORDER BY lp.total_xp DESC
         LIMIT $2 OFFSET $3",
    )
    .bind(learner_id)
    .bind(page_size)
    .bind(offset)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    let response = ListResponse {
        items: entries,
        meta: crate::models::ListMeta::new(page, page_size, total.0),
    };

    Ok(Json(ApiResponse::new(response)))
}

#[handler]
pub async fn get_course_leaderboard(
    req: &mut Request,
    depot: &mut Depot,
) -> Result<Json<ApiResponse<ListResponse<LeaderboardEntry>>>, StatusError> {
    let pool = depot
        .obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let course_id_str = req
        .param::<String>("course_id")
        .ok_or_else(StatusError::bad_request)?;

    let course_id = Uuid::parse_str(&course_id_str)
        .map_err(|_| StatusError::bad_request().brief("Invalid course_id"))?;

    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let page_size = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * page_size;

    // 查询在该课程有学习进度的用户
    let total: (i64,) = sqlx::query_as(
        "SELECT COUNT(*)
         FROM learner_profiles lp
         INNER JOIN accounts a ON lp.account_id = a.id
         WHERE a.account_status = 'active'
           AND EXISTS (
               SELECT 1 FROM course_progress cp
               WHERE cp.learner_id = lp.account_id AND cp.course_id = $1
           )",
    )
    .bind(course_id)
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    let entries = sqlx::query_as::<_, LeaderboardEntry>(
        "SELECT
            lp.account_id as learner_id,
            lp.nickname,
            lp.total_xp as score,
            lp.current_level as level,
            lp.avatar_url,
            RANK() OVER (ORDER BY lp.total_xp DESC) as rank
         FROM learner_profiles lp
         INNER JOIN accounts a ON lp.account_id = a.id
         WHERE a.account_status = 'active'
           AND EXISTS (
               SELECT 1 FROM course_progress cp
               WHERE cp.learner_id = lp.account_id AND cp.course_id = $1
           )
         ORDER BY lp.total_xp DESC
         LIMIT $2 OFFSET $3",
    )
    .bind(course_id)
    .bind(page_size)
    .bind(offset)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    let response = ListResponse {
        items: entries,
        meta: crate::models::ListMeta::new(page, page_size, total.0),
    };

    Ok(Json(ApiResponse::new(response)))
}
