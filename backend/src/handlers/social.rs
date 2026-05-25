use salvo::prelude::*;
use serde::Deserialize;
use sqlx::PgPool;
use uuid::Uuid;

use crate::handlers::auth;
use crate::models::{ApiResponse, FriendRelation, SocialActivity};

#[derive(Debug, Deserialize)]
pub struct CreateFriendRequest {
    pub addressee_id: String,
}

#[handler]
pub async fn list_friends(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<crate::models::ListResponse<FriendRelation>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let learner_id = auth::get_current_account_id(depot)?;
    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let page_size = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * page_size;

    let q = req.query::<String>("q").unwrap_or_default().trim().to_lowercase();
    
    let friends = if q.is_empty() {
        sqlx::query_as::<_, FriendRelation>(
            "SELECT id, requester_id, addressee_id, status::text AS status, created_at, responded_at FROM friend_relations WHERE requester_id = $1 OR addressee_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3"
        )
        .bind(learner_id)
        .bind(page_size)
        .bind(offset)
        .fetch_all(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
    } else {
        sqlx::query_as::<_, FriendRelation>(
            "SELECT fr.id, fr.requester_id, fr.addressee_id, fr.status::text AS status, fr.created_at, fr.responded_at 
             FROM friend_relations fr
             INNER JOIN learner_profiles lp ON (
                 (fr.requester_id = $1 AND fr.addressee_id = lp.account_id) OR
                 (fr.addressee_id = $1 AND fr.requester_id = lp.account_id)
             )
             WHERE (fr.requester_id = $1 OR fr.addressee_id = $1)
               AND LOWER(lp.nickname) LIKE $4
             ORDER BY fr.created_at DESC LIMIT $2 OFFSET $3"
        )
        .bind(learner_id)
        .bind(page_size)
        .bind(offset)
        .bind(format!("%{}%", q))
        .fetch_all(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
    };
    
    let total: (i64,) = if q.is_empty() {
        sqlx::query_as(
            "SELECT COUNT(*) FROM friend_relations WHERE requester_id = $1 OR addressee_id = $1"
        )
        .bind(learner_id)
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
    } else {
        sqlx::query_as(
            "SELECT COUNT(*) 
             FROM friend_relations fr
             INNER JOIN learner_profiles lp ON (
                 (fr.requester_id = $1 AND fr.addressee_id = lp.account_id) OR
                 (fr.addressee_id = $1 AND fr.requester_id = lp.account_id)
             )
             WHERE (fr.requester_id = $1 OR fr.addressee_id = $1)
               AND LOWER(lp.nickname) LIKE $2"
        )
        .bind(learner_id)
        .bind(format!("%{}%", q))
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
    };

    let response = crate::models::ListResponse {
        items: friends,
        meta: crate::models::ListMeta::new(page, page_size, total.0),
    };

    Ok(Json(ApiResponse::new(response)))
}

#[handler]
pub async fn create_friend_request(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let body: CreateFriendRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;

    let id = Uuid::new_v4();
    let requester_id = auth::get_current_account_id(depot)?;
    let addressee_id = Uuid::parse_str(&body.addressee_id)
        .map_err(|_| StatusError::bad_request().brief("Invalid addressee_id"))?;

    sqlx::query(
        "INSERT INTO friend_relations (id, requester_id, addressee_id, status) VALUES ($1, $2, $3, 'pending')"
    )
    .bind(id)
    .bind(requester_id)
    .bind(addressee_id)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    Ok(StatusCode::CREATED)
}

#[handler]
pub async fn list_social_activities(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<crate::models::ListResponse<SocialActivity>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let learner_id = auth::get_current_account_id(depot)?;
    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let page_size = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * page_size;
    
    let activities = sqlx::query_as::<_, SocialActivity>(
        "SELECT id, learner_id, activity_type::text AS activity_type, visibility::text AS visibility, payload_json, created_at FROM social_activities WHERE learner_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3"
    )
    .bind(learner_id)
    .bind(page_size)
    .bind(offset)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    let total: (i64,) = sqlx::query_as(
        "SELECT COUNT(*) FROM social_activities WHERE learner_id = $1"
    )
    .bind(learner_id)
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    let response = crate::models::ListResponse {
        items: activities,
        meta: crate::models::ListMeta::new(page, page_size, total.0),
    };

    Ok(Json(ApiResponse::new(response)))
}

#[handler]
pub async fn list_friend_requests(depot: &mut Depot) -> Result<Json<ApiResponse<Vec<FriendRelation>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let learner_id = auth::get_current_account_id(depot)?;
    let requests = sqlx::query_as::<_, FriendRelation>(
        "SELECT id, requester_id, addressee_id, status::text AS status, created_at, responded_at FROM friend_relations WHERE addressee_id = $1 AND status = 'pending' ORDER BY created_at DESC"
    )
    .bind(learner_id)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    Ok(Json(ApiResponse::new(requests)))
}

#[derive(Debug, sqlx::FromRow, serde::Serialize)]
pub struct LearnerSearchResult {
    pub account_id: Uuid,
    pub nickname: String,
    pub current_level: i32,
    pub total_xp: i32,
    pub avatar_url: Option<String>,
}

#[handler]
pub async fn search_learners(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<crate::models::ListResponse<LearnerSearchResult>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let learner_id = auth::get_current_account_id(depot)?;
    let q = req.query::<String>("q").unwrap_or_default().trim().to_lowercase();
    
    if q.is_empty() {
        return Ok(Json(ApiResponse::new(crate::models::ListResponse {
            items: vec![],
            meta: crate::models::ListMeta::new(1, 20, 0),
        })));
    }

    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let page_size = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * page_size;

    let results = sqlx::query_as::<_, LearnerSearchResult>(
        "SELECT 
            lp.account_id,
            lp.nickname,
            lp.current_level,
            lp.total_xp,
            lp.avatar_url
         FROM learner_profiles lp
         INNER JOIN accounts a ON lp.account_id = a.id
         WHERE a.account_status = 'active'
           AND lp.account_id != $1
           AND LOWER(lp.nickname) LIKE $2
           AND NOT EXISTS (
               SELECT 1 FROM friend_relations fr
               WHERE (fr.requester_id = $1 AND fr.addressee_id = lp.account_id)
                  OR (fr.addressee_id = $1 AND fr.requester_id = lp.account_id)
           )
         ORDER BY lp.total_xp DESC
         LIMIT $3 OFFSET $4"
    )
    .bind(learner_id)
    .bind(format!("%{}%", q))
    .bind(page_size)
    .bind(offset)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    let total: (i64,) = sqlx::query_as(
        "SELECT COUNT(*) 
         FROM learner_profiles lp
         INNER JOIN accounts a ON lp.account_id = a.id
         WHERE a.account_status = 'active'
           AND lp.account_id != $1
           AND LOWER(lp.nickname) LIKE $2
           AND NOT EXISTS (
               SELECT 1 FROM friend_relations fr
               WHERE (fr.requester_id = $1 AND fr.addressee_id = lp.account_id)
                  OR (fr.addressee_id = $1 AND fr.requester_id = lp.account_id)
           )"
    )
    .bind(learner_id)
    .bind(format!("%{}%", q))
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    let response = crate::models::ListResponse {
        items: results,
        meta: crate::models::ListMeta::new(page, page_size, total.0),
    };

    Ok(Json(ApiResponse::new(response)))
}

#[derive(Debug, Deserialize)]
pub struct UpdateFriendRequest {
    pub status: String,
}

#[handler]
pub async fn update_friend_request(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<FriendRelation>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let request_id = req.param::<String>("request_id")
        .ok_or_else(StatusError::bad_request)?;
    
    let body: UpdateFriendRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;

    sqlx::query(
        "UPDATE friend_relations SET status = $2, updated_at = NOW() WHERE id = $1"
    )
    .bind(&request_id)
    .bind(&body.status)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    let relation = sqlx::query_as::<_, FriendRelation>(
        "SELECT id, requester_id, addressee_id, status::text AS status, created_at, responded_at FROM friend_relations WHERE id = $1"
    )
    .bind(&request_id)
    .fetch_optional(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?
    .ok_or_else(StatusError::not_found)?;

    Ok(Json(ApiResponse::new(relation)))
}
