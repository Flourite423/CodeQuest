use salvo::prelude::*;
use sqlx::PgPool;
use crate::models::{ApiResponse, Course};

#[handler]
pub async fn list_courses(depot: &mut Depot) -> Result<Json<ApiResponse<Vec<Course>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let courses = sqlx::query_as::<_, Course>("SELECT * FROM courses WHERE status = 'published'")
        .fetch_all(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(Json(ApiResponse::new(courses)))
}

#[handler]
pub async fn get_course(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<Course>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("id")
        .ok_or_else(StatusError::bad_request)?;
    
    let course = sqlx::query_as::<_, Course>("SELECT * FROM courses WHERE id = $1")
        .bind(&id)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;
    
    Ok(Json(ApiResponse::new(course)))
}

#[handler]
pub async fn create_course(depot: &mut Depot) -> Result<StatusCode, StatusError> {
    Ok(StatusCode::CREATED)
}

#[handler]
pub async fn update_course(depot: &mut Depot) -> Result<StatusCode, StatusError> {
    Ok(StatusCode::OK)
}

#[handler]
pub async fn delete_course(depot: &mut Depot) -> Result<StatusCode, StatusError> {
    Ok(StatusCode::NO_CONTENT)
}
