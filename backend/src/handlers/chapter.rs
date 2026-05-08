use salvo::prelude::*;
use sqlx::PgPool;
use crate::models::{ApiResponse, Chapter};
use uuid::Uuid;
use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct CreateChapterRequest {
    pub chapter_code: String,
    pub title: String,
    pub summary: String,
    pub learning_content_markdown: String,
    pub sample_code: Option<String>,
    pub estimated_minutes: i32,
    pub order_index: i32,
}

#[derive(Debug, Deserialize)]
pub struct UpdateChapterRequest {
    pub title: Option<String>,
    pub summary: Option<String>,
    pub learning_content_markdown: Option<String>,
    pub sample_code: Option<String>,
    pub estimated_minutes: Option<i32>,
    pub order_index: Option<i32>,
    pub status: Option<String>,
}

#[handler]
pub async fn list_chapters(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<Vec<Chapter>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let course_id = req.param::<String>("course_id")
        .or_else(|| req.query::<String>("course_id"))
        .ok_or_else(StatusError::bad_request)?;
    
    let status_filter = req.query::<String>("status").unwrap_or_else(|| "published".to_string());
    
    let chapters = sqlx::query_as::<_, Chapter>(
        "SELECT * FROM chapters WHERE course_id = $1 AND status = $2 ORDER BY order_index"
    )
    .bind(&course_id)
    .bind(&status_filter)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(Json(ApiResponse::new(chapters)))
}

#[handler]
pub async fn get_chapter(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<Chapter>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("id")
        .ok_or_else(StatusError::bad_request)?;
    
    let chapter = sqlx::query_as::<_, Chapter>("SELECT * FROM chapters WHERE id = $1")
        .bind(&id)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;
    
    Ok(Json(ApiResponse::new(chapter)))
}

#[handler]
pub async fn create_chapter(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let course_id = req.param::<String>("course_id")
        .or_else(|| req.query::<String>("course_id"))
        .ok_or_else(StatusError::bad_request)?;
    
    let body: CreateChapterRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let id = Uuid::new_v4();
    sqlx::query(
        "INSERT INTO chapters (id, course_id, chapter_code, title, summary, learning_content_markdown, 
         sample_code, estimated_minutes, order_index, unlock_rule, status, content_version) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, 'none', 'draft', 1)"
    )
    .bind(id)
    .bind(&course_id)
    .bind(&body.chapter_code)
    .bind(&body.title)
    .bind(&body.summary)
    .bind(&body.learning_content_markdown)
    .bind(&body.sample_code)
    .bind(body.estimated_minutes)
    .bind(body.order_index)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::CREATED)
}

#[handler]
pub async fn update_chapter(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("id")
        .ok_or_else(StatusError::bad_request)?;
    
    let body: UpdateChapterRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    sqlx::query(
        "UPDATE chapters SET 
         title = COALESCE($2, title),
         summary = COALESCE($3, summary),
         learning_content_markdown = COALESCE($4, learning_content_markdown),
         sample_code = COALESCE($5, sample_code),
         estimated_minutes = COALESCE($6, estimated_minutes),
         order_index = COALESCE($7, order_index),
         status = COALESCE($8, status),
         updated_at = NOW()
         WHERE id = $1"
    )
    .bind(&id)
    .bind(&body.title)
    .bind(&body.summary)
    .bind(&body.learning_content_markdown)
    .bind(&body.sample_code)
    .bind(body.estimated_minutes)
    .bind(body.order_index)
    .bind(&body.status)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::OK)
}

#[handler]
pub async fn delete_chapter(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("id")
        .ok_or_else(StatusError::bad_request)?;
    
    sqlx::query("DELETE FROM chapters WHERE id = $1")
        .bind(&id)
        .execute(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::NO_CONTENT)
}
