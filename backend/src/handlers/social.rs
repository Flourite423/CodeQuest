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
pub async fn list_friends(depot: &mut Depot) -> Result<Json<ApiResponse<Vec<FriendRelation>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let learner_id = auth::get_current_account_id(depot)?;
    let friends = sqlx::query_as::<_, FriendRelation>(
        "SELECT * FROM friend_relations WHERE requester_id = $1 OR addressee_id = $1 ORDER BY created_at DESC"
    )
    .bind(learner_id)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    Ok(Json(ApiResponse::new(friends)))
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
pub async fn list_social_activities(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<Vec<SocialActivity>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let learner_id = auth::get_current_account_id(depot)?;
    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let per_page = req.query::<i64>("per_page").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * per_page;
    
    let activities = sqlx::query_as::<_, SocialActivity>(
        "SELECT * FROM social_activities WHERE learner_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3"
    )
    .bind(learner_id)
    .bind(per_page)
    .bind(offset)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    Ok(Json(ApiResponse::new(activities)))
}

#[handler]
pub async fn list_friend_requests(depot: &mut Depot) -> Result<Json<ApiResponse<Vec<FriendRelation>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let learner_id = auth::get_current_account_id(depot)?;
    let requests = sqlx::query_as::<_, FriendRelation>(
        "SELECT * FROM friend_relations WHERE addressee_id = $1 AND status = 'pending' ORDER BY created_at DESC"
    )
    .bind(learner_id)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    Ok(Json(ApiResponse::new(requests)))
}

#[derive(Debug, Deserialize)]
pub struct UpdateFriendRequest {
    pub status: String,
}

#[handler]
pub async fn update_friend_request(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
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

    Ok(StatusCode::OK)
}
