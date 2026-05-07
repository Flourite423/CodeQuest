use salvo::prelude::*;
use sqlx::PgPool;
use crate::models::{ApiResponse, Account};

#[handler]
pub async fn list_users(depot: &mut Depot) -> Result<Json<ApiResponse<Vec<Account>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let users = sqlx::query_as::<_, Account>("SELECT * FROM accounts WHERE role = 'learner'")
        .fetch_all(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(Json(ApiResponse::new(users)))
}

#[handler]
pub async fn get_user(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<Account>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("id")
        .ok_or_else(StatusError::bad_request)?;
    
    let user = sqlx::query_as::<_, Account>("SELECT * FROM accounts WHERE id = $1")
        .bind(&id)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;
    
    Ok(Json(ApiResponse::new(user)))
}

#[handler]
pub async fn update_user(depot: &mut Depot) -> Result<StatusCode, StatusError> {
    Ok(StatusCode::OK)
}
