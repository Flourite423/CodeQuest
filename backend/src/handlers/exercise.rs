use salvo::prelude::*;
use sqlx::PgPool;
use crate::models::{ApiResponse, Exercise, ExerciseOption, ExerciseTestCase, LearnerExerciseDetail, LearnerExerciseOption, LearnerVisibleTestCase};
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
        "SELECT id, chapter_id, exercise_code, title, prompt, exercise_type::text AS exercise_type, starter_code, language::text AS language, difficulty::text AS difficulty, pass_score, max_attempts_per_day, status::text AS status, content_version, created_at, updated_at FROM exercises WHERE chapter_id = $1 AND status = $2 ORDER BY created_at"
    )
    .bind(&chapter_id)
    .bind(&status_filter)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(Json(ApiResponse::new(exercises)))
}

#[handler]
pub async fn get_exercise(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<LearnerExerciseDetail>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id_str = req.param::<String>("exercise_id")
        .or_else(|| req.param::<String>("id"))
        .ok_or_else(StatusError::bad_request)?;
    let id = Uuid::parse_str(&id_str)
        .map_err(|_| StatusError::bad_request().brief("Invalid exercise ID"))?;
    
    let exercise = sqlx::query_as::<_, Exercise>("SELECT id, chapter_id, exercise_code, title, prompt, exercise_type::text AS exercise_type, starter_code, language::text AS language, difficulty::text AS difficulty, pass_score, max_attempts_per_day, status::text AS status, content_version, created_at, updated_at FROM exercises WHERE id = $1")
        .bind(id)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;
    
    let options = sqlx::query_as::<_, ExerciseOption>(
        "SELECT id, exercise_id, option_key, option_text, is_correct, order_index FROM exercise_options WHERE exercise_id = $1 ORDER BY order_index"
    )
    .bind(id)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    let test_cases = sqlx::query_as::<_, ExerciseTestCase>(
        "SELECT id, exercise_id, case_name, case_type::text AS case_type, input_payload_json, expected_payload_json, weight, is_hidden, order_index, rule_version, created_at, updated_at FROM exercise_test_cases WHERE exercise_id = $1 AND is_hidden = false ORDER BY order_index"
    )
    .bind(id)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    let learner_options: Vec<LearnerExerciseOption> = options.into_iter().map(LearnerExerciseOption::from).collect();
    let learner_test_cases: Vec<LearnerVisibleTestCase> = test_cases.into_iter().map(LearnerVisibleTestCase::from).collect();
    
    let detail = LearnerExerciseDetail {
        exercise,
        options: learner_options,
        visible_test_cases: learner_test_cases,
    };
    
    Ok(Json(ApiResponse::new(detail)))
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
    
    let id = req.param::<String>("exercise_id")
        .or_else(|| req.param::<String>("id"))
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
    
    let id = req.param::<String>("exercise_id")
        .or_else(|| req.param::<String>("id"))
        .ok_or_else(StatusError::bad_request)?;
    
    sqlx::query("DELETE FROM exercises WHERE id = $1")
        .bind(&id)
        .execute(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::NO_CONTENT)
}
