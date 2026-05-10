use salvo::prelude::*;
use sqlx::PgPool;
use crate::handlers::auth;
use crate::models::ApiResponse;
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
pub async fn list_courses(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<course_service::LearnerCourseListResponse>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let per_page = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
    let sort_by = req.query::<String>("sort_by");
    let sort_order = req.query::<String>("sort_order");
    
    let courses = course_service::list_published_courses_with_meta(pool, page, per_page, sort_by.as_deref(), sort_order.as_deref())
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(Json(ApiResponse::new(courses)))
}

#[handler]
pub async fn get_course(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<serde_json::Value>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("course_id")
        .ok_or_else(StatusError::bad_request)?;
    let id = Uuid::parse_str(&id)
        .map_err(|_| StatusError::bad_request().brief("Invalid course ID"))?;
    
    let course = course_service::find_course_by_id(pool, id)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;
    
    let chapters = sqlx::query_as::<_, crate::models::Chapter>(
        "SELECT id, course_id, chapter_code, title, summary, learning_content_markdown, sample_code, estimated_minutes, order_index, unlock_rule::text AS unlock_rule, status::text AS status, content_version, created_at, updated_at FROM chapters WHERE course_id = $1 AND status = 'published' ORDER BY order_index ASC"
    )
    .bind(id)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    let mut course_value = serde_json::to_value(course).map_err(|_| StatusError::internal_server_error())?;
    if let Some(obj) = course_value.as_object_mut() {
        obj.insert("chapters".to_string(), serde_json::to_value(chapters).map_err(|_| StatusError::internal_server_error())?);
    }
    
    Ok(Json(ApiResponse::new(course_value)))
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
