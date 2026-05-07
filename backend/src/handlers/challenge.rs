use salvo::prelude::*;
use sqlx::PgPool;
use crate::models::{ApiResponse, Challenge};

#[handler]
pub async fn list_challenges(depot: &mut Depot) -> Result<Json<ApiResponse<Vec<Challenge>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let challenges = sqlx::query_as::<_, Challenge>("SELECT * FROM challenges WHERE status = 'active'")
        .fetch_all(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(Json(ApiResponse::new(challenges)))
}

#[handler]
pub async fn get_challenge(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<Challenge>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("id")
        .ok_or_else(StatusError::bad_request)?;
    
    let challenge = sqlx::query_as::<_, Challenge>("SELECT * FROM challenges WHERE id = $1")
        .bind(&id)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;
    
    Ok(Json(ApiResponse::new(challenge)))
}

#[handler]
pub async fn create_challenge(depot: &mut Depot) -> Result<StatusCode, StatusError> {
    Ok(StatusCode::CREATED)
}

#[handler]
pub async fn update_challenge(depot: &mut Depot) -> Result<StatusCode, StatusError> {
    Ok(StatusCode::OK)
}

#[handler]
pub async fn delete_challenge(depot: &mut Depot) -> Result<StatusCode, StatusError> {
    Ok(StatusCode::NO_CONTENT)
}
