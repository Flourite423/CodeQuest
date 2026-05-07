use salvo::prelude::*;
use sqlx::PgPool;
use crate::handlers::auth;
use crate::models::{ApiResponse, Course};
use crate::services::course_service;
use uuid::Uuid;
use serde::Deserialize;

#[derive(Debug, Deserialize)]
#[allow(dead_code)]
pub struct CreateCourseRequest {
    pub course_code: String,
    pub title: String,
    pub summary: String,
    pub description: Option<String>,
    pub cover_image_url: Option<String>,
    pub difficulty: String,
    pub estimated_minutes: i32,
}

#[derive(Debug, Deserialize)]
#[allow(dead_code)]
pub struct UpdateCourseRequest {
    pub title: Option<String>,
    pub summary: Option<String>,
    pub description: Option<String>,
    pub cover_image_url: Option<String>,
    pub difficulty: Option<String>,
    pub estimated_minutes: Option<i32>,
    pub status: Option<String>,
}

#[handler]
pub async fn list_courses(depot: &mut Depot) -> Result<Json<ApiResponse<Vec<Course>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let courses = course_service::list_published_courses(pool)
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
    let id = Uuid::parse_str(&id)
        .map_err(|_| StatusError::bad_request().brief("Invalid course ID"))?;
    
    let course = course_service::find_course_by_id(pool, id)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;
    
    Ok(Json(ApiResponse::new(course)))
}

#[handler]
pub async fn create_course(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let body: CreateCourseRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let created_by = auth::get_current_account_id(depot)?;
    course_service::create_course(pool, &body.course_code, &body.title, &body.summary, created_by)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::CREATED)
}

#[handler]
pub async fn update_course(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("id")
        .ok_or_else(StatusError::bad_request)?;
    let id = Uuid::parse_str(&id)
        .map_err(|_| StatusError::bad_request().brief("Invalid course ID"))?;
    
    let body: UpdateCourseRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    course_service::update_course(
        pool, 
        id,
        body.title.as_deref(),
        body.summary.as_deref(),
        body.status.as_deref(),
    )
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::OK)
}

#[handler]
pub async fn delete_course(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("id")
        .ok_or_else(StatusError::bad_request)?;
    let id = Uuid::parse_str(&id)
        .map_err(|_| StatusError::bad_request().brief("Invalid course ID"))?;
    
    course_service::delete_course(pool, id)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::NO_CONTENT)
}
