use salvo::prelude::*;
use sqlx::PgPool;
use crate::models::{ApiResponse, CourseProgress};
use crate::handlers::auth;
use crate::services::progress_service;
use uuid::Uuid;
use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct CreateProgressRequest {
    pub course_id: String,
}

#[derive(Debug, Deserialize)]
pub struct UpdateProgressRequest {
    pub completed_chapter_count: Option<i32>,
    pub total_chapter_count: Option<i32>,
    pub completed_exercise_count: Option<i32>,
    pub progress_percent: Option<i32>,
    pub last_studied_chapter_id: Option<String>,
    pub status: Option<String>,
}

#[handler]
pub async fn list_progress(depot: &mut Depot) -> Result<Json<ApiResponse<Vec<CourseProgress>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let learner_id = auth::get_current_account_id(depot)?;
    
    let progress = progress_service::list_progress_by_learner(pool, learner_id)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(Json(ApiResponse::new(progress)))
}

#[handler]
pub async fn get_course_progress(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<CourseProgress>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let course_id = req.param::<String>("course_id")
        .ok_or_else(StatusError::bad_request)?;
    let course_id = Uuid::parse_str(&course_id)
        .map_err(|_| StatusError::bad_request().brief("Invalid course ID"))?;
    
    let learner_id = auth::get_current_account_id(depot)?;
    
    let progress = progress_service::find_progress_by_learner_and_course(pool, learner_id, course_id)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;
    
    Ok(Json(ApiResponse::new(progress)))
}

#[handler]
pub async fn create_progress(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let body: CreateProgressRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let learner_id = auth::get_current_account_id(depot)?;
    let course_id = Uuid::parse_str(&body.course_id)
        .map_err(|_| StatusError::bad_request().brief("Invalid course_id"))?;
    
    progress_service::create_progress(pool, learner_id, course_id)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::CREATED)
}

#[handler]
pub async fn update_progress(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let course_id = req.param::<String>("course_id")
        .ok_or_else(StatusError::bad_request)?;
    let course_id = Uuid::parse_str(&course_id)
        .map_err(|_| StatusError::bad_request().brief("Invalid course ID"))?;
    
    let body: UpdateProgressRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let learner_id = auth::get_current_account_id(depot)?;
    let last_chapter_id = body.last_studied_chapter_id.as_ref()
        .and_then(|s| Uuid::parse_str(s).ok());
    
    progress_service::update_progress(
        pool,
        learner_id,
        course_id,
        body.completed_chapter_count,
        body.total_chapter_count,
        body.completed_exercise_count,
        body.progress_percent,
        last_chapter_id,
        body.status.as_deref(),
    )
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::OK)
}

#[handler]
pub async fn complete_chapter(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let course_id = req.param::<String>("course_id")
        .ok_or_else(StatusError::bad_request)?;
    let course_id = Uuid::parse_str(&course_id)
        .map_err(|_| StatusError::bad_request().brief("Invalid course ID"))?;
    
    let chapter_id = req.param::<String>("chapter_id")
        .ok_or_else(StatusError::bad_request)?;
    let chapter_uuid = Uuid::parse_str(&chapter_id)
        .map_err(|_| StatusError::bad_request().brief("Invalid chapter_id"))?;
    
    let learner_id = auth::get_current_account_id(depot)?;
    
    progress_service::complete_chapter(pool, learner_id, course_id, chapter_uuid)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::OK)
}

#[handler]
pub async fn delete_progress(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let course_id = req.param::<String>("course_id")
        .ok_or_else(StatusError::bad_request)?;
    let course_id = Uuid::parse_str(&course_id)
        .map_err(|_| StatusError::bad_request().brief("Invalid course ID"))?;
    
    let learner_id = auth::get_current_account_id(depot)?;
    
    progress_service::delete_progress(pool, learner_id, course_id)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::NO_CONTENT)
}
