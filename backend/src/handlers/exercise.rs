use salvo::prelude::*;
use sqlx::PgPool;
use crate::models::{ApiResponse, Exercise};
use uuid::Uuid;
use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct CreateExerciseRequest {
    pub exercise_code: String,
    pub title: String,
    pub prompt: String,
    pub exercise_type: String,
    pub starter_code: Option<String>,
    pub language: String,
    pub difficulty: String,
    pub pass_score: i32,
    pub max_attempts_per_day: Option<i32>,
}

#[derive(Debug, Deserialize)]
pub struct UpdateExerciseRequest {
    pub title: Option<String>,
    pub prompt: Option<String>,
    pub exercise_type: Option<String>,
    pub starter_code: Option<String>,
    pub language: Option<String>,
    pub difficulty: Option<String>,
    pub pass_score: Option<i32>,
    pub max_attempts_per_day: Option<i32>,
    pub status: Option<String>,
}

#[handler]
pub async fn list_exercises(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<Vec<Exercise>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let chapter_id = req.param::<String>("chapter_id")
        .ok_or_else(StatusError::bad_request)?;
    
    let status_filter = req.query::<String>("status").unwrap_or_else(|| "published".to_string());
    
    let exercises = sqlx::query_as::<_, Exercise>(
        "SELECT * FROM exercises WHERE chapter_id = $1 AND status = $2 ORDER BY created_at"
    )
    .bind(&chapter_id)
    .bind(&status_filter)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(Json(ApiResponse::new(exercises)))
}

#[handler]
pub async fn get_exercise(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<Exercise>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("id")
        .ok_or_else(StatusError::bad_request)?;
    
    let exercise = sqlx::query_as::<_, Exercise>("SELECT * FROM exercises WHERE id = $1")
        .bind(&id)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;
    
    Ok(Json(ApiResponse::new(exercise)))
}

#[handler]
pub async fn create_exercise(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let chapter_id = req.param::<String>("chapter_id")
        .ok_or_else(StatusError::bad_request)?;
    
    let body: CreateExerciseRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let id = Uuid::new_v4();
    sqlx::query(
        "INSERT INTO exercises (id, chapter_id, exercise_code, title, prompt, exercise_type, 
         starter_code, language, difficulty, pass_score, max_attempts_per_day, status, content_version) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, 'draft', 1)"
    )
    .bind(id)
    .bind(&chapter_id)
    .bind(&body.exercise_code)
    .bind(&body.title)
    .bind(&body.prompt)
    .bind(&body.exercise_type)
    .bind(&body.starter_code)
    .bind(&body.language)
    .bind(&body.difficulty)
    .bind(body.pass_score)
    .bind(body.max_attempts_per_day)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::CREATED)
}

#[handler]
pub async fn update_exercise(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("id")
        .ok_or_else(StatusError::bad_request)?;
    
    let body: UpdateExerciseRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    sqlx::query(
        "UPDATE exercises SET 
         title = COALESCE($2, title),
         prompt = COALESCE($3, prompt),
         exercise_type = COALESCE($4, exercise_type),
         starter_code = COALESCE($5, starter_code),
         language = COALESCE($6, language),
         difficulty = COALESCE($7, difficulty),
         pass_score = COALESCE($8, pass_score),
         max_attempts_per_day = COALESCE($9, max_attempts_per_day),
         status = COALESCE($10, status),
         updated_at = NOW()
         WHERE id = $1"
    )
    .bind(&id)
    .bind(&body.title)
    .bind(&body.prompt)
    .bind(&body.exercise_type)
    .bind(&body.starter_code)
    .bind(&body.language)
    .bind(&body.difficulty)
    .bind(body.pass_score)
    .bind(body.max_attempts_per_day)
    .bind(&body.status)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::OK)
}

#[handler]
pub async fn delete_exercise(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("id")
        .ok_or_else(StatusError::bad_request)?;
    
    sqlx::query("DELETE FROM exercises WHERE id = $1")
        .bind(&id)
        .execute(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::NO_CONTENT)
}
