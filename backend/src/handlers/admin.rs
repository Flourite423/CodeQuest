use salvo::prelude::*;
use serde::{Deserialize, Serialize};
use sqlx::PgPool;
use uuid::Uuid;
use chrono::{DateTime, Utc};

use crate::handlers::auth;
use crate::models::{Announcement, ApiResponse, SystemConfig};

const COURSE_SELECT_COLUMNS: &str = "SELECT
    id,
    course_code,
    title,
    summary,
    description,
    cover_image_url,
    difficulty::text AS difficulty,
    estimated_minutes,
    status::text AS status,
    sort_order,
    content_version,
    created_by,
    published_at,
    created_at,
    updated_at
 FROM courses";

fn map_course_difficulty(value: Option<&str>) -> crate::models::DifficultyLevel {
    match value.unwrap_or("beginner") {
        "intermediate" => crate::models::DifficultyLevel::Intermediate,
        "easy" => crate::models::DifficultyLevel::Easy,
        "medium" => crate::models::DifficultyLevel::Medium,
        "hard" => crate::models::DifficultyLevel::Hard,
        _ => crate::models::DifficultyLevel::Beginner,
    }
}

async fn fetch_admin_course_detail(pool: &PgPool, course_id: Uuid) -> Result<serde_json::Value, StatusError> {
    let query = format!("{COURSE_SELECT_COLUMNS} WHERE id = $1");
    let course = sqlx::query_as::<_, crate::models::Course>(&query)
        .bind(course_id)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;

    let chapters = sqlx::query_as::<_, crate::models::Chapter>(
        "SELECT * FROM chapters WHERE course_id = $1 ORDER BY order_index ASC"
    )
    .bind(course_id)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    let mut value = serde_json::to_value(course).map_err(|_| StatusError::internal_server_error())?;
    if let Some(object) = value.as_object_mut() {
        object.insert(
            "chapters".to_string(),
            serde_json::to_value(chapters).map_err(|_| StatusError::internal_server_error())?,
        );
    }
    Ok(value)
}

#[derive(Debug, Deserialize)]
pub struct CreateAnnouncementRequest {
    pub title: String,
    pub body_markdown: String,
    pub audience: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SafeAccount {
    pub id: String,
    pub email: String,
    pub default_role: String,
    pub account_status: String,
    pub last_login_at: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[handler]
pub async fn list_admin_users(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<crate::models::ListResponse<SafeAccount>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let page_size = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * page_size;

    let users = sqlx::query_as::<_, crate::models::Account>("SELECT * FROM accounts ORDER BY created_at DESC LIMIT $1 OFFSET $2")
        .bind(page_size)
        .bind(offset)
        .fetch_all(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;

    let safe_users: Vec<SafeAccount> = users.into_iter().map(|account| SafeAccount {
        id: account.id.to_string(),
        email: account.email,
        default_role: format!("{:?}", account.default_role).to_lowercase(),
        account_status: format!("{:?}", account.account_status).to_lowercase(),
        last_login_at: account.last_login_at,
        created_at: account.created_at,
        updated_at: account.updated_at,
    }).collect();
    
    let total: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM accounts")
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;

    let response = crate::models::ListResponse {
        items: safe_users,
        meta: crate::models::ListMeta::new(page, page_size, total.0),
    };

    Ok(Json(ApiResponse::new(response)))
}

#[handler]
pub async fn get_admin_stats(depot: &mut Depot) -> Result<Json<ApiResponse<serde_json::Value>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let users: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM accounts")
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    let courses: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM courses")
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;

    Ok(Json(ApiResponse::new(serde_json::json!({
        "total_users": users.0,
        "total_courses": courses.0
    }))))
}

#[handler]
pub async fn create_announcement(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<Announcement>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let body: CreateAnnouncementRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;

    let announcement = sqlx::query_as::<_, Announcement>(
        "INSERT INTO announcements (id, title, body_markdown, audience, status, created_by) \
        VALUES ($1, $2, $3, $4, 'draft', $5) RETURNING *"
    )
    .bind(Uuid::new_v4())
    .bind(&body.title)
    .bind(&body.body_markdown)
    .bind(&body.audience)
    .bind(auth::get_current_account_id(depot)?)
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    Ok(Json(ApiResponse::new(announcement)))
}

#[handler]
pub async fn list_system_configs(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<crate::models::ListResponse<SystemConfig>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let page_size = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * page_size;

    let configs = sqlx::query_as::<_, SystemConfig>("SELECT * FROM system_configs ORDER BY updated_at DESC LIMIT $1 OFFSET $2")
        .bind(page_size)
        .bind(offset)
        .fetch_all(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    let total: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM system_configs")
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;

    let response = crate::models::ListResponse {
        items: configs,
        meta: crate::models::ListMeta::new(page, page_size, total.0),
    };

    Ok(Json(ApiResponse::new(response)))
}

#[handler]
pub async fn get_dashboard_stats(depot: &mut Depot) -> Result<Json<ApiResponse<serde_json::Value>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let users: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM accounts")
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    let courses: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM courses")
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    let submissions: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM submissions")
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;

    Ok(Json(ApiResponse::new(serde_json::json!({
        "total_users": users.0,
        "total_courses": courses.0,
        "total_submissions": submissions.0
    }))))
}

#[handler]
pub async fn get_course_stats(depot: &mut Depot) -> Result<Json<ApiResponse<serde_json::Value>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let published: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM courses WHERE status = 'published'")
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    let draft: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM courses WHERE status = 'draft'")
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;

    Ok(Json(ApiResponse::new(serde_json::json!({
        "published_courses": published.0,
        "draft_courses": draft.0
    }))))
}

#[handler]
pub async fn get_user_stats(depot: &mut Depot) -> Result<Json<ApiResponse<serde_json::Value>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let learners: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM accounts WHERE default_role = 'learner'")
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    let admins: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM accounts WHERE default_role = 'admin'")
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;

    Ok(Json(ApiResponse::new(serde_json::json!({
        "total_learners": learners.0,
        "total_admins": admins.0
    }))))
}

#[derive(Debug, serde::Serialize)]
pub struct AdminListMeta {
    pub total: i64,
}

#[handler]
pub async fn list_admin_courses(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<serde_json::Value>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let page_size = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * page_size;

    let query = format!("{COURSE_SELECT_COLUMNS} ORDER BY created_at DESC LIMIT $1 OFFSET $2");
    let courses = sqlx::query_as::<_, crate::models::Course>(&query)
        .bind(page_size)
        .bind(offset)
        .fetch_all(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    let total: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM courses")
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;

    let meta = crate::models::ListMeta::new(page, page_size, total.0);

    Ok(Json(ApiResponse::new(serde_json::json!({
        "items": courses,
        "meta": meta
    }))))
}

#[handler]
pub async fn create_course(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<serde_json::Value>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let body = req.parse_json::<serde_json::Value>().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let id = Uuid::new_v4();
    let difficulty_enum = map_course_difficulty(body.get("difficulty").and_then(|v| v.as_str()));
    let estimated_minutes = body.get("estimated_minutes").and_then(|v| v.as_i64()).unwrap_or(0) as i32;
    let status = body.get("status").and_then(|v| v.as_str()).unwrap_or("draft");
    let sort_order = body.get("sort_order").and_then(|v| v.as_i64()).unwrap_or(0) as i32;
    let content_version = body.get("content_version").and_then(|v| v.as_i64()).unwrap_or(1) as i32;
    let published_at = if status == "published" { Some(chrono::Utc::now()) } else { None };
    let created_by = auth::get_current_account_id(depot)?;
    
    sqlx::query(
        "INSERT INTO courses (
            id, course_code, title, summary, description, cover_image_url, difficulty,
            estimated_minutes, status, sort_order, content_version, created_by, published_at
         ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9::course_status, $10, $11, $12, $13)"
    )
    .bind(id)
    .bind(body.get("course_code").and_then(|v| v.as_str()).unwrap_or(""))
    .bind(body.get("title").and_then(|v| v.as_str()).unwrap_or(""))
    .bind(body.get("summary").and_then(|v| v.as_str()).unwrap_or(""))
    .bind(body.get("description").and_then(|v| v.as_str()))
    .bind(body.get("cover_image_url").and_then(|v| v.as_str()))
    .bind(difficulty_enum)
    .bind(estimated_minutes)
    .bind(status)
    .bind(sort_order)
    .bind(content_version)
    .bind(created_by)
    .bind(published_at)
    .execute(pool)
    .await
    .map_err(|e| {
        eprintln!("Database error creating course: {:?}", e);
        StatusError::internal_server_error()
    })?;
    
    let detail = fetch_admin_course_detail(pool, id).await?;
    Ok(Json(ApiResponse::new(detail)))
}

#[handler]
pub async fn get_admin_course(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<crate::models::Course>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("course_id")
        .ok_or_else(StatusError::bad_request)?;
    let query = format!("{COURSE_SELECT_COLUMNS} WHERE id = $1");
    let course = sqlx::query_as::<_, crate::models::Course>(&query)
        .bind(&id)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;
    
    Ok(Json(ApiResponse::new(course)))
}

#[handler]
pub async fn update_course(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<serde_json::Value>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("course_id")
        .ok_or_else(StatusError::bad_request)?;
    
    let body = req.parse_json::<serde_json::Value>().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let difficulty_enum = body
        .get("difficulty")
        .and_then(|v| v.as_str())
        .map(|value| map_course_difficulty(Some(value)));
    let published_at = if body.get("status").and_then(|v| v.as_str()) == Some("published") {
        Some(chrono::Utc::now())
    } else {
        None
    };
    
    sqlx::query(
        "UPDATE courses SET 
         title = COALESCE($2, title),
         summary = COALESCE($3, summary),
         description = COALESCE($4, description),
         cover_image_url = COALESCE($5, cover_image_url),
         difficulty = COALESCE($6, difficulty),
         estimated_minutes = COALESCE($7, estimated_minutes),
         status = COALESCE($8::course_status, status),
         sort_order = COALESCE($9, sort_order),
         content_version = COALESCE($10, content_version),
         published_at = COALESCE($11, published_at),
         updated_at = NOW()
         WHERE id = $1"
    )
    .bind(&id)
    .bind(body.get("title").and_then(|v| v.as_str()))
    .bind(body.get("summary").and_then(|v| v.as_str()))
    .bind(body.get("description").and_then(|v| v.as_str()))
    .bind(body.get("cover_image_url").and_then(|v| v.as_str()))
    .bind(difficulty_enum)
    .bind(body.get("estimated_minutes").and_then(|v| v.as_i64()).map(|v| v as i32))
    .bind(body.get("status").and_then(|v| v.as_str()))
    .bind(body.get("sort_order").and_then(|v| v.as_i64()).map(|v| v as i32))
    .bind(body.get("content_version").and_then(|v| v.as_i64()).map(|v| v as i32))
    .bind(published_at)
    .execute(pool)
    .await
    .map_err(|e| {
        eprintln!("Database error updating course: {:?}", e);
        StatusError::internal_server_error()
    })?;
    
    let course_id = Uuid::parse_str(&id).map_err(|_| StatusError::bad_request())?;
    let detail = fetch_admin_course_detail(pool, course_id).await?;
    Ok(Json(ApiResponse::new(detail)))
}

#[handler]
pub async fn delete_course(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("course_id")
        .ok_or_else(StatusError::bad_request)?;
    
    sqlx::query("DELETE FROM courses WHERE id = $1")
        .bind(&id)
        .execute(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::NO_CONTENT)
}

#[handler]
pub async fn list_admin_challenges(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<serde_json::Value>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let page_size = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * page_size;

    let challenges = sqlx::query_as::<_, crate::models::Challenge>("SELECT * FROM challenges ORDER BY created_at DESC LIMIT $1 OFFSET $2")
        .bind(page_size)
        .bind(offset)
        .fetch_all(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    let total: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM challenges")
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;

    let meta = crate::models::ListMeta::new(page, page_size, total.0);

    Ok(Json(ApiResponse::new(serde_json::json!({
        "items": challenges,
        "meta": meta
    }))))
}

#[handler]
pub async fn create_challenge(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<crate::models::Challenge>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let body = req.parse_json::<serde_json::Value>().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let id = Uuid::new_v4();
    let difficulty = body.get("difficulty").and_then(|v| v.as_str()).unwrap_or("easy");
    let difficulty_enum = match difficulty {
        "beginner" => crate::models::DifficultyLevel::Beginner,
        "intermediate" => crate::models::DifficultyLevel::Intermediate,
        "easy" => crate::models::DifficultyLevel::Easy,
        "medium" => crate::models::DifficultyLevel::Medium,
        "hard" => crate::models::DifficultyLevel::Hard,
        _ => crate::models::DifficultyLevel::Easy,
    };
    
    let challenge = sqlx::query_as::<_, crate::models::Challenge>(
        "INSERT INTO challenges (id, challenge_code, title, summary, difficulty, reward_xp, status) 
         VALUES ($1, $2, $3, $4, $5, $6, 'draft')
         RETURNING id, challenge_code, title, summary, related_course_id, difficulty::text, reward_xp, status::text, sort_order, content_version, created_at, updated_at"
    )
    .bind(id)
    .bind(body.get("challenge_code").and_then(|v| v.as_str()).unwrap_or(""))
    .bind(body.get("title").and_then(|v| v.as_str()).unwrap_or(""))
    .bind(body.get("summary").and_then(|v| v.as_str()).unwrap_or(""))
    .bind(difficulty_enum)
    .bind(body.get("reward_xp").and_then(|v| v.as_i64()).unwrap_or(0) as i32)
    .fetch_one(pool)
    .await
    .map_err(|e| {
        eprintln!("Database error creating challenge: {:?}", e);
        StatusError::internal_server_error()
    })?;
    
    Ok(Json(ApiResponse::new(challenge)))
}

#[handler]
pub async fn create_challenge_with_status(req: &mut Request, depot: &mut Depot) -> Result<(StatusCode, Json<ApiResponse<crate::models::Challenge>>), StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let body = req.parse_json::<serde_json::Value>().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let id = Uuid::new_v4();
    let difficulty = body.get("difficulty").and_then(|v| v.as_str()).unwrap_or("easy");
    let difficulty_enum = match difficulty {
        "beginner" => crate::models::DifficultyLevel::Beginner,
        "intermediate" => crate::models::DifficultyLevel::Intermediate,
        "easy" => crate::models::DifficultyLevel::Easy,
        "medium" => crate::models::DifficultyLevel::Medium,
        "hard" => crate::models::DifficultyLevel::Hard,
        _ => crate::models::DifficultyLevel::Easy,
    };
    
    let challenge = sqlx::query_as::<_, crate::models::Challenge>(
        "INSERT INTO challenges (id, challenge_code, title, summary, difficulty, reward_xp, status) 
         VALUES ($1, $2, $3, $4, $5, $6, 'draft')
         RETURNING id, challenge_code, title, summary, related_course_id, difficulty::text, reward_xp, status::text, sort_order, content_version, created_at, updated_at"
    )
    .bind(id)
    .bind(body.get("challenge_code").and_then(|v| v.as_str()).unwrap_or(""))
    .bind(body.get("title").and_then(|v| v.as_str()).unwrap_or(""))
    .bind(body.get("summary").and_then(|v| v.as_str()).unwrap_or(""))
    .bind(difficulty_enum)
    .bind(body.get("reward_xp").and_then(|v| v.as_i64()).unwrap_or(0) as i32)
    .fetch_one(pool)
    .await
    .map_err(|e| {
        eprintln!("Database error creating challenge: {:?}", e);
        StatusError::internal_server_error()
    })?;
    
    Ok((StatusCode::CREATED, Json(ApiResponse::new(challenge))))
}

#[handler]
pub async fn get_admin_challenge(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<crate::models::Challenge>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("challenge_id")
        .ok_or_else(StatusError::bad_request)?;
    
    let challenge = sqlx::query_as::<_, crate::models::Challenge>("SELECT * FROM challenges WHERE id = $1")
        .bind(&id)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;
    
    Ok(Json(ApiResponse::new(challenge)))
}

#[handler]
pub async fn update_challenge(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("challenge_id")
        .ok_or_else(StatusError::bad_request)?;
    
    let body = req.parse_json::<serde_json::Value>().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let difficulty = body.get("difficulty").and_then(|v| v.as_str());
    let difficulty_enum = difficulty.map(|d| match d {
        "beginner" => crate::models::DifficultyLevel::Beginner,
        "intermediate" => crate::models::DifficultyLevel::Intermediate,
        "easy" => crate::models::DifficultyLevel::Easy,
        "medium" => crate::models::DifficultyLevel::Medium,
        "hard" => crate::models::DifficultyLevel::Hard,
        _ => crate::models::DifficultyLevel::Easy,
    });
    
    sqlx::query(
        "UPDATE challenges SET 
         title = COALESCE($2, title),
         summary = COALESCE($3, summary),
         difficulty = COALESCE($4, difficulty),
         reward_xp = COALESCE($5, reward_xp),
         status = COALESCE($6, status),
         updated_at = NOW()
         WHERE id = $1"
    )
    .bind(&id)
    .bind(body.get("title").and_then(|v| v.as_str()))
    .bind(body.get("summary").and_then(|v| v.as_str()))
    .bind(difficulty_enum)
    .bind(body.get("reward_xp").and_then(|v| v.as_i64()).map(|v| v as i32))
    .bind(body.get("status").and_then(|v| v.as_str()))
    .execute(pool)
    .await
    .map_err(|e| {
        eprintln!("Database error updating challenge: {:?}", e);
        StatusError::internal_server_error()
    })?;
    
    Ok(StatusCode::OK)
}

#[handler]
pub async fn delete_challenge(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("challenge_id")
        .ok_or_else(StatusError::bad_request)?;
    
    sqlx::query("DELETE FROM challenges WHERE id = $1")
        .bind(&id)
        .execute(pool)
        .await
        .map_err(|e| {
            eprintln!("Database error deleting challenge: {:?}", e);
            StatusError::internal_server_error()
        })?;
    
    Ok(StatusCode::NO_CONTENT)
}

#[handler]
pub async fn list_admin_exercises(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<serde_json::Value>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let page_size = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * page_size;

    let exercises = sqlx::query_as::<_, crate::models::Exercise>("SELECT * FROM exercises ORDER BY created_at DESC LIMIT $1 OFFSET $2")
        .bind(page_size)
        .bind(offset)
        .fetch_all(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    let total: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM exercises")
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;

    let meta = crate::models::ListMeta::new(page, page_size, total.0);

    Ok(Json(ApiResponse::new(serde_json::json!({
        "items": exercises,
        "meta": meta
    }))))
}

#[handler]
pub async fn create_exercise(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<crate::models::Exercise>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let body = req.parse_json::<serde_json::Value>().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let id = Uuid::new_v4();
    let chapter_id = body.get("chapter_id").and_then(|v| v.as_str())
        .and_then(|s| Uuid::parse_str(s).ok());
    
    let exercise = sqlx::query_as::<_, crate::models::Exercise>(
        "INSERT INTO exercises (id, chapter_id, exercise_code, title, difficulty, status) 
         VALUES ($1, $2, $3, $4, $5, 'draft')
         RETURNING *"
    )
    .bind(id)
    .bind(chapter_id)
    .bind(body.get("exercise_code").and_then(|v| v.as_str()).unwrap_or(""))
    .bind(body.get("title").and_then(|v| v.as_str()).unwrap_or(""))
    .bind(body.get("difficulty").and_then(|v| v.as_str()).unwrap_or(""))
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(Json(ApiResponse::new(exercise)))
}

#[handler]
pub async fn get_admin_exercise(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<crate::models::Exercise>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("exercise_id")
        .ok_or_else(StatusError::bad_request)?;
    
    let exercise = sqlx::query_as::<_, crate::models::Exercise>("SELECT * FROM exercises WHERE id = $1")
        .bind(&id)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;
    
    Ok(Json(ApiResponse::new(exercise)))
}

#[handler]
pub async fn update_exercise(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("exercise_id")
        .ok_or_else(StatusError::bad_request)?;
    
    let body = req.parse_json::<serde_json::Value>().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    sqlx::query(
        "UPDATE exercises SET 
         title = COALESCE($2, title),
         difficulty = COALESCE($3, difficulty),
         status = COALESCE($4, status),
         updated_at = NOW()
         WHERE id = $1"
    )
    .bind(&id)
    .bind(body.get("title").and_then(|v| v.as_str()))
    .bind(body.get("difficulty").and_then(|v| v.as_str()))
    .bind(body.get("status").and_then(|v| v.as_str()))
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
        .ok_or_else(StatusError::bad_request)?;
    
    sqlx::query("DELETE FROM exercises WHERE id = $1")
        .bind(&id)
        .execute(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(StatusCode::NO_CONTENT)
}

#[handler]
pub async fn get_admin_user(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<SafeAccount>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("user_id")
        .ok_or_else(StatusError::bad_request)?;
    
    let id = Uuid::parse_str(&id)
        .map_err(|_| StatusError::bad_request().brief("Invalid user ID"))?;
    
    let user = sqlx::query_as::<_, crate::models::Account>("SELECT * FROM accounts WHERE id = $1")
        .bind(&id)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;
    
    let safe_user = SafeAccount {
        id: user.id.to_string(),
        email: user.email,
        default_role: format!("{:?}", user.default_role).to_lowercase(),
        account_status: format!("{:?}", user.account_status).to_lowercase(),
        last_login_at: user.last_login_at,
        created_at: user.created_at,
        updated_at: user.updated_at,
    };
    
    Ok(Json(ApiResponse::new(safe_user)))
}

#[handler]
pub async fn update_user(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("user_id")
        .ok_or_else(StatusError::bad_request)?;
    
    let id = Uuid::parse_str(&id)
        .map_err(|_| StatusError::bad_request().brief("Invalid user ID"))?;
    
    let body = req.parse_json::<serde_json::Value>().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let role = body.get("default_role").and_then(|v| v.as_str());
    let role_enum = role.map(|r| match r {
        "admin" => crate::models::RoleType::Admin,
        _ => crate::models::RoleType::Learner,
    });
    
    let status = body.get("account_status").and_then(|v| v.as_str());
    let status_enum = status.map(|s| match s {
        "suspended" => crate::models::AccountStatus::Suspended,
        "closed" => crate::models::AccountStatus::Closed,
        _ => crate::models::AccountStatus::Active,
    });
    
    sqlx::query(
        "UPDATE accounts SET 
         email = COALESCE($2, email),
         default_role = COALESCE($3, default_role),
         account_status = COALESCE($4, account_status),
         updated_at = NOW()
         WHERE id = $1"
    )
    .bind(&id)
    .bind(body.get("email").and_then(|v| v.as_str()))
    .bind(role_enum)
    .bind(status_enum)
    .execute(pool)
    .await
    .map_err(|e| {
        eprintln!("Database error updating user: {:?}", e);
        StatusError::internal_server_error()
    })?;
    
    Ok(StatusCode::OK)
}

#[derive(Debug, Deserialize)]
pub struct UpdateUserStatusRequest {
    pub status: String,
}

#[handler]
pub async fn update_user_status(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let user_id = req.param::<String>("user_id")
        .ok_or_else(StatusError::bad_request)?;
    
    let body: UpdateUserStatusRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;

    sqlx::query("UPDATE accounts SET account_status = $2, updated_at = NOW() WHERE id = $1")
        .bind(&user_id)
        .bind(&body.status)
        .execute(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;

    Ok(StatusCode::OK)
}

#[handler]
pub async fn list_feedback(_depot: &mut Depot) -> Result<Json<ApiResponse<serde_json::Value>>, StatusError> {
    Ok(Json(ApiResponse::new(serde_json::json!({"items": []}))))
}

#[handler]
pub async fn get_feedback(req: &mut Request, _depot: &mut Depot) -> Result<Json<ApiResponse<serde_json::Value>>, StatusError> {
    let _ticket_id = req.param::<String>("ticket_id")
        .ok_or_else(StatusError::bad_request)?;
    Ok(Json(ApiResponse::new(serde_json::json!({}))))
}

#[handler]
pub async fn update_feedback(req: &mut Request, _depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let _ticket_id = req.param::<String>("ticket_id")
        .ok_or_else(StatusError::bad_request)?;
    let _body = req.parse_json::<serde_json::Value>().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    Ok(StatusCode::OK)
}

#[handler]
pub async fn list_moderation_cases(_depot: &mut Depot) -> Result<Json<ApiResponse<serde_json::Value>>, StatusError> {
    Ok(Json(ApiResponse::new(serde_json::json!({"items": []}))))
}

#[handler]
pub async fn get_moderation_case(req: &mut Request, _depot: &mut Depot) -> Result<Json<ApiResponse<serde_json::Value>>, StatusError> {
    let _case_id = req.param::<String>("case_id")
        .ok_or_else(StatusError::bad_request)?;
    Ok(Json(ApiResponse::new(serde_json::json!({}))))
}

#[handler]
pub async fn update_moderation_case(req: &mut Request, _depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let _case_id = req.param::<String>("case_id")
        .ok_or_else(StatusError::bad_request)?;
    let _body = req.parse_json::<serde_json::Value>().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    Ok(StatusCode::OK)
}

#[handler]
pub async fn list_announcements(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<crate::models::ListResponse<Announcement>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let page_size = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * page_size;

    let announcements = sqlx::query_as::<_, Announcement>("SELECT * FROM announcements ORDER BY created_at DESC LIMIT $1 OFFSET $2")
        .bind(page_size)
        .bind(offset)
        .fetch_all(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;
    
    let total: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM announcements")
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;

    let response = crate::models::ListResponse {
        items: announcements,
        meta: crate::models::ListMeta::new(page, page_size, total.0),
    };

    Ok(Json(ApiResponse::new(response)))
}

#[handler]
pub async fn get_announcement(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<Announcement>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let id = req.param::<String>("announcement_id")
        .ok_or_else(StatusError::bad_request)?;

    let announcement = sqlx::query_as::<_, Announcement>("SELECT * FROM announcements WHERE id = $1")
        .bind(&id)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;

    Ok(Json(ApiResponse::new(announcement)))
}

#[derive(Debug, Deserialize)]
pub struct UpdateAnnouncementRequest {
    pub title: Option<String>,
    pub body_markdown: Option<String>,
    pub audience: Option<String>,
    pub status: Option<String>,
}

#[handler]
pub async fn update_announcement(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let id = req.param::<String>("announcement_id")
        .ok_or_else(StatusError::bad_request)?;
    
    let body: UpdateAnnouncementRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;

    sqlx::query(
        "UPDATE announcements SET 
         title = COALESCE($2, title),
         body_markdown = COALESCE($3, body_markdown),
         audience = COALESCE($4, audience),
         status = COALESCE($5, status),
         updated_at = NOW()
         WHERE id = $1"
    )
    .bind(&id)
    .bind(&body.title)
    .bind(&body.body_markdown)
    .bind(&body.audience)
    .bind(&body.status)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    Ok(StatusCode::OK)
}

#[handler]
pub async fn delete_announcement(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let id = req.param::<String>("announcement_id")
        .ok_or_else(StatusError::bad_request)?;

    sqlx::query("DELETE FROM announcements WHERE id = $1")
        .bind(&id)
        .execute(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;

    Ok(StatusCode::NO_CONTENT)
}

#[derive(Debug, Deserialize)]
pub struct CreateConfigRequest {
    pub config_key: String,
    pub config_scope: String,
    pub value_json: serde_json::Value,
    pub status: Option<String>,
}

#[handler]
pub async fn create_config(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<SystemConfig>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let body: CreateConfigRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;

    let admin_id = auth::get_current_account_id(depot)?;
    let status = body.status.as_deref().unwrap_or("active");

    let config = sqlx::query_as::<_, SystemConfig>(
        "INSERT INTO system_configs (config_key, config_scope, value_json, status, updated_by) \
        VALUES ($1, $2, $3, $4, $5) RETURNING *"
    )
    .bind(&body.config_key)
    .bind(&body.config_scope)
    .bind(&body.value_json)
    .bind(status)
    .bind(admin_id)
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    Ok(Json(ApiResponse::new(config)))
}

#[handler]
pub async fn get_config(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<SystemConfig>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let config_key = req.param::<String>("config_key")
        .ok_or_else(StatusError::bad_request)?;

    let config = sqlx::query_as::<_, SystemConfig>("SELECT * FROM system_configs WHERE config_key = $1")
        .bind(&config_key)
        .fetch_optional(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?
        .ok_or_else(StatusError::not_found)?;

    Ok(Json(ApiResponse::new(config)))
}

#[derive(Debug, Deserialize)]
pub struct UpdateConfigRequest {
    pub config_scope: Option<String>,
    pub value_json: Option<serde_json::Value>,
    pub status: Option<String>,
}

#[handler]
pub async fn update_config(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let config_key = req.param::<String>("config_key")
        .ok_or_else(StatusError::bad_request)?;
    
    let body: UpdateConfigRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;
    
    let admin_id = auth::get_current_account_id(depot)?;

    sqlx::query(
        "UPDATE system_configs SET 
         config_scope = COALESCE($2, config_scope),
         value_json = COALESCE($3, value_json),
         status = COALESCE($4, status),
         updated_by = $5,
         updated_at = NOW()
         WHERE config_key = $1"
    )
    .bind(&config_key)
    .bind(&body.config_scope)
    .bind(&body.value_json)
    .bind(&body.status)
    .bind(admin_id)
    .execute(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    Ok(StatusCode::OK)
}

#[handler]
pub async fn delete_config(req: &mut Request, depot: &mut Depot) -> Result<StatusCode, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let config_key = req.param::<String>("config_key")
        .ok_or_else(StatusError::bad_request)?;

    sqlx::query("DELETE FROM system_configs WHERE config_key = $1")
        .bind(&config_key)
        .execute(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;

    Ok(StatusCode::NO_CONTENT)
}
