use salvo::prelude::*;
use serde::{Deserialize, Serialize};
use sqlx::PgPool;
use uuid::Uuid;
use chrono::{DateTime, Utc};

use crate::handlers::auth;
use crate::models::{Announcement, ApiResponse, FeedbackTicket, ModerationCase, SystemConfig};

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
        "SELECT id, course_id, chapter_code, title, summary, learning_content_markdown, sample_code, estimated_minutes, order_index, unlock_rule::text AS unlock_rule, status::text AS status, content_version, created_at, updated_at FROM chapters WHERE course_id = $1 ORDER BY order_index ASC"
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

#[derive(Debug, Serialize)]
pub struct FeedbackLearnerProfileSummary {
    pub account_id: Uuid,
    pub nickname: String,
    pub avatar_url: Option<String>,
}

#[derive(Debug, Serialize)]
pub struct AdminFeedbackListItem {
    #[serde(flatten)]
    pub ticket: FeedbackTicket,
    pub learner_profile: FeedbackLearnerProfileSummary,
}

#[derive(Debug, Deserialize)]
pub struct UpdateFeedbackRequest {
    pub status: String,
    pub admin_reply: Option<String>,
}

#[derive(Debug, Serialize)]
pub struct ModerationTargetSummary {
    pub target_label: String,
    pub target_owner_id: Option<Uuid>,
}

#[derive(Debug, Serialize)]
pub struct ReviewerProfileSummary {
    pub account_id: Uuid,
    pub display_name: String,
    pub avatar_url: Option<String>,
}

#[derive(Debug, Serialize)]
pub struct AdminModerationListItem {
    #[serde(flatten)]
    pub case_record: ModerationCase,
    pub target_summary: ModerationTargetSummary,
    pub reviewer_profile: Option<ReviewerProfileSummary>,
}

#[derive(Debug, Deserialize)]
pub struct UpdateModerationCaseRequest {
    pub status: String,
    pub decision_reason: Option<String>,
}

#[derive(Debug, sqlx::FromRow)]
struct AdminFeedbackListRow {
    pub id: Uuid,
    pub learner_id: Uuid,
    pub category: String,
    pub content: String,
    pub screenshot_urls: serde_json::Value,
    pub status: String,
    pub admin_reply: Option<String>,
    pub replied_at: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub learner_nickname: String,
    pub learner_avatar_url: Option<String>,
}

#[derive(Debug, sqlx::FromRow)]
struct AdminModerationListRow {
    pub id: Uuid,
    pub case_type: String,
    pub target_id: Uuid,
    pub target_snapshot_json: serde_json::Value,
    pub status: String,
    pub decision_reason: Option<String>,
    pub reviewed_by: Option<Uuid>,
    pub reviewed_at: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub reviewer_display_name: Option<String>,
    pub reviewer_avatar_url: Option<String>,
}

fn build_feedback_list_item(row: AdminFeedbackListRow) -> AdminFeedbackListItem {
    AdminFeedbackListItem {
        ticket: FeedbackTicket {
            id: row.id,
            learner_id: row.learner_id,
            category: row.category,
            content: row.content,
            screenshot_urls: row.screenshot_urls,
            status: row.status,
            admin_reply: row.admin_reply,
            replied_at: row.replied_at,
            created_at: row.created_at,
            updated_at: row.updated_at,
        },
        learner_profile: FeedbackLearnerProfileSummary {
            account_id: row.learner_id,
            nickname: row.learner_nickname,
            avatar_url: row.learner_avatar_url,
        },
    }
}

fn build_moderation_list_item(row: AdminModerationListRow) -> AdminModerationListItem {
    let target_label = row.target_snapshot_json
        .get("target_label")
        .and_then(|value| value.as_str())
        .or_else(|| row.target_snapshot_json.get("nickname").and_then(|value| value.as_str()))
        .or_else(|| row.target_snapshot_json.get("title").and_then(|value| value.as_str()))
        .or_else(|| row.target_snapshot_json.get("content").and_then(|value| value.as_str()))
        .unwrap_or("unknown")
        .to_string();

    let target_owner_id = row.target_snapshot_json
        .get("target_owner_id")
        .and_then(|value| value.as_str())
        .and_then(|value| Uuid::parse_str(value).ok())
        .or_else(|| row.target_snapshot_json.get("learner_id").and_then(|value| value.as_str()).and_then(|value| Uuid::parse_str(value).ok()))
        .or_else(|| row.target_snapshot_json.get("account_id").and_then(|value| value.as_str()).and_then(|value| Uuid::parse_str(value).ok()));

    AdminModerationListItem {
        case_record: ModerationCase {
            id: row.id,
            case_type: row.case_type,
            target_id: row.target_id,
            target_snapshot_json: row.target_snapshot_json,
            status: row.status,
            decision_reason: row.decision_reason,
            reviewed_by: row.reviewed_by,
            reviewed_at: row.reviewed_at,
            created_at: row.created_at,
            updated_at: row.updated_at,
        },
        target_summary: ModerationTargetSummary {
            target_label,
            target_owner_id,
        },
        reviewer_profile: row.reviewed_by.zip(row.reviewer_display_name).map(|(account_id, display_name)| ReviewerProfileSummary {
            account_id,
            display_name,
            avatar_url: row.reviewer_avatar_url,
        }),
    }
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
pub async fn create_announcement(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<Announcement>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let body: CreateAnnouncementRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;

    let announcement = sqlx::query_as::<_, Announcement>(
        "INSERT INTO announcements (id, title, body_markdown, audience, status, created_by) \
        VALUES ($1, $2, $3, $4, 'draft', $5) \
        RETURNING id, title, body_markdown, audience::text AS audience, status::text AS status, published_at, expires_at, created_by, created_at, updated_at"
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

    let configs = sqlx::query_as::<_, SystemConfig>("SELECT id, config_key, config_scope::text AS config_scope, value_json, status::text AS status, updated_by, updated_at FROM system_configs ORDER BY updated_at DESC LIMIT $1 OFFSET $2")
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

    let active_today: (i64,) = sqlx::query_as(
        "SELECT COUNT(DISTINCT account_id) FROM sessions WHERE last_seen_at >= CURRENT_DATE"
    )
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    let pending_moderation: (i64,) = sqlx::query_as(
        "SELECT COUNT(*) FROM moderation_cases WHERE status = 'pending'"
    )
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    // 近7天趋势数据
    let new_users_trend: Vec<(chrono::NaiveDate, i64)> = sqlx::query_as(
        "SELECT DATE(created_at) as date, COUNT(*) as count
         FROM accounts
         WHERE created_at >= CURRENT_DATE - INTERVAL '6 days'
         GROUP BY DATE(created_at)
         ORDER BY date"
    )
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    let submissions_trend: Vec<(chrono::NaiveDate, i64)> = sqlx::query_as(
        "SELECT DATE(submitted_at) as date, COUNT(*) as count
         FROM submissions
         WHERE submitted_at >= CURRENT_DATE - INTERVAL '6 days'
         GROUP BY DATE(submitted_at)
         ORDER BY date"
    )
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    let active_trend: Vec<(chrono::NaiveDate, i64)> = sqlx::query_as(
        "SELECT DATE(last_seen_at) as date, COUNT(DISTINCT account_id) as count
         FROM sessions
         WHERE last_seen_at >= CURRENT_DATE - INTERVAL '6 days'
         GROUP BY DATE(last_seen_at)
         ORDER BY date"
    )
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    // 构建近7天完整日期数组
    let mut dates = Vec::new();
    let mut new_users_daily = Vec::new();
    let mut submissions_daily = Vec::new();
    let mut active_daily = Vec::new();

    for i in 0..7 {
        let date = chrono::Local::now().date_naive() - chrono::Duration::days(6 - i);
        dates.push(date.format("%m-%d").to_string());
        new_users_daily.push(new_users_trend.iter().find(|(d, _)| *d == date).map(|(_, c)| *c).unwrap_or(0));
        submissions_daily.push(submissions_trend.iter().find(|(d, _)| *d == date).map(|(_, c)| *c).unwrap_or(0));
        active_daily.push(active_trend.iter().find(|(d, _)| *d == date).map(|(_, c)| *c).unwrap_or(0));
    }

    Ok(Json(ApiResponse::new(serde_json::json!({
        "total_users": users.0,
        "total_courses": courses.0,
        "total_submissions": submissions.0,
        "active_today": active_today.0,
        "pending_moderation": pending_moderation.0,
        "trend": {
            "dates": dates,
            "new_users": new_users_daily,
            "submissions": submissions_daily,
            "active_users": active_daily
        }
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

    let challenges = sqlx::query_as::<_, crate::models::Challenge>("SELECT id, challenge_code, title, summary, related_course_id, difficulty::text AS difficulty, reward_xp, status::text AS status, sort_order, content_version, published_at, created_at, updated_at FROM challenges ORDER BY created_at DESC LIMIT $1 OFFSET $2")
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
    let status = body.get("status").and_then(|v| v.as_str()).unwrap_or("draft");
    let published_at = if status == "published" {
        Some(chrono::Utc::now())
    } else {
        None
    };
    
    let challenge = sqlx::query_as::<_, crate::models::Challenge>(
        "INSERT INTO challenges (id, challenge_code, title, summary, difficulty, reward_xp, status, published_at) 
         VALUES ($1, $2, $3, $4, $5, $6, $7::course_status, $8)
         RETURNING id, challenge_code, title, summary, related_course_id, difficulty::text, reward_xp, status::text, sort_order, content_version, published_at, created_at, updated_at"
    )
    .bind(id)
    .bind(body.get("challenge_code").and_then(|v| v.as_str()).unwrap_or(""))
    .bind(body.get("title").and_then(|v| v.as_str()).unwrap_or(""))
    .bind(body.get("summary").and_then(|v| v.as_str()).unwrap_or(""))
    .bind(difficulty_enum)
    .bind(body.get("reward_xp").and_then(|v| v.as_i64()).unwrap_or(0) as i32)
    .bind(status)
    .bind(published_at)
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
    let status = body.get("status").and_then(|v| v.as_str()).unwrap_or("draft");
    let published_at = if status == "published" {
        Some(chrono::Utc::now())
    } else {
        None
    };
    
    let challenge = sqlx::query_as::<_, crate::models::Challenge>(
        "INSERT INTO challenges (id, challenge_code, title, summary, difficulty, reward_xp, status, published_at) 
         VALUES ($1, $2, $3, $4, $5, $6, $7::course_status, $8)
         RETURNING id, challenge_code, title, summary, related_course_id, difficulty::text, reward_xp, status::text, sort_order, content_version, published_at, created_at, updated_at"
    )
    .bind(id)
    .bind(body.get("challenge_code").and_then(|v| v.as_str()).unwrap_or(""))
    .bind(body.get("title").and_then(|v| v.as_str()).unwrap_or(""))
    .bind(body.get("summary").and_then(|v| v.as_str()).unwrap_or(""))
    .bind(difficulty_enum)
    .bind(body.get("reward_xp").and_then(|v| v.as_i64()).unwrap_or(0) as i32)
    .bind(status)
    .bind(published_at)
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
    
    let challenge = sqlx::query_as::<_, crate::models::Challenge>("SELECT id, challenge_code, title, summary, related_course_id, difficulty::text AS difficulty, reward_xp, status::text AS status, sort_order, content_version, published_at, created_at, updated_at FROM challenges WHERE id = $1")
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
    let published_at = if body.get("status").and_then(|v| v.as_str()) == Some("published") {
        Some(chrono::Utc::now())
    } else {
        None
    };
    
    sqlx::query(
        "UPDATE challenges SET 
         title = COALESCE($2, title),
         summary = COALESCE($3, summary),
         difficulty = COALESCE($4, difficulty),
         reward_xp = COALESCE($5, reward_xp),
         status = COALESCE($6, status),
         published_at = COALESCE($7, published_at),
         updated_at = NOW()
         WHERE id = $1"
    )
    .bind(&id)
    .bind(body.get("title").and_then(|v| v.as_str()))
    .bind(body.get("summary").and_then(|v| v.as_str()))
    .bind(difficulty_enum)
    .bind(body.get("reward_xp").and_then(|v| v.as_i64()).map(|v| v as i32))
    .bind(body.get("status").and_then(|v| v.as_str()))
    .bind(published_at)
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

    let exercises = sqlx::query_as::<_, crate::models::Exercise>("SELECT id, chapter_id, exercise_code, title, prompt, exercise_type::text AS exercise_type, starter_code, language::text AS language, difficulty::text AS difficulty, pass_score, max_attempts_per_day, status::text AS status, content_version, created_at, updated_at FROM exercises ORDER BY created_at DESC LIMIT $1 OFFSET $2")
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
         RETURNING id, chapter_id, exercise_code, title, prompt, exercise_type::text AS exercise_type, starter_code, language::text AS language, difficulty::text AS difficulty, pass_score, max_attempts_per_day, status::text AS status, content_version, created_at, updated_at"
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
pub async fn get_admin_user(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<SafeAccount>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let id = req.param::<String>("user_id")
        .ok_or_else(StatusError::bad_request)?;
    
    let id = Uuid::parse_str(&id)
        .map_err(|_| StatusError::bad_request().brief("Invalid user ID"))?;
    
    let user = sqlx::query_as::<_, crate::models::Account>("SELECT * FROM accounts WHERE id = $1")
        .bind(id)
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
    .bind(id)
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
pub async fn list_feedback(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<crate::models::ListResponse<AdminFeedbackListItem>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let page_size = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * page_size;

    let rows = sqlx::query_as::<_, AdminFeedbackListRow>(
        "SELECT
            ft.id,
            ft.learner_id,
            ft.category::text AS category,
            ft.content,
            ft.screenshot_urls,
            ft.status::text AS status,
            ft.admin_reply,
            ft.replied_at,
            ft.created_at,
            ft.updated_at,
            lp.nickname AS learner_nickname,
            lp.avatar_url AS learner_avatar_url
         FROM feedback_tickets ft
         INNER JOIN learner_profiles lp ON lp.account_id = ft.learner_id
         ORDER BY ft.created_at DESC
         LIMIT $1 OFFSET $2"
    )
    .bind(page_size)
    .bind(offset)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    let total: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM feedback_tickets")
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;

    let response = crate::models::ListResponse {
        items: rows.into_iter().map(build_feedback_list_item).collect(),
        meta: crate::models::ListMeta::new(page, page_size, total.0),
    };

    Ok(Json(ApiResponse::new(response)))
}

#[handler]
pub async fn get_feedback(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<FeedbackTicket>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let ticket_id = req.param::<String>("ticket_id")
        .ok_or_else(StatusError::bad_request)?;

    let ticket_id = Uuid::parse_str(&ticket_id)
        .map_err(|_| StatusError::bad_request().brief("Invalid feedback ticket ID"))?;

    let ticket = sqlx::query_as::<_, FeedbackTicket>(
        "SELECT
            id,
            learner_id,
            category::text AS category,
            content,
            screenshot_urls,
            status::text AS status,
            admin_reply,
            replied_at,
            created_at,
            updated_at
         FROM feedback_tickets
         WHERE id = $1"
    )
    .bind(ticket_id)
    .fetch_optional(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?
    .ok_or_else(StatusError::not_found)?;

    Ok(Json(ApiResponse::new(ticket)))
}

#[handler]
pub async fn update_feedback(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<FeedbackTicket>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let ticket_id = req.param::<String>("ticket_id")
        .ok_or_else(StatusError::bad_request)?;

    let ticket_id = Uuid::parse_str(&ticket_id)
        .map_err(|_| StatusError::bad_request().brief("Invalid feedback ticket ID"))?;

    let body: UpdateFeedbackRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;

    match body.status.as_str() {
        "open" | "in_progress" | "resolved" | "closed" => {}
        _ => return Err(StatusError::bad_request().brief("Invalid feedback status")),
    }

    let replied_at = if body.admin_reply.is_some() {
        Some(Utc::now())
    } else {
        None
    };

    let ticket = sqlx::query_as::<_, FeedbackTicket>(
        "UPDATE feedback_tickets SET
            status = $2::feedback_status,
            admin_reply = $3,
            replied_at = CASE WHEN $3 IS NOT NULL THEN $4 ELSE replied_at END,
            updated_at = NOW()
         WHERE id = $1
         RETURNING
            id,
            learner_id,
            category::text AS category,
            content,
            screenshot_urls,
            status::text AS status,
            admin_reply,
            replied_at,
            created_at,
            updated_at"
    )
    .bind(ticket_id)
    .bind(&body.status)
    .bind(&body.admin_reply)
    .bind(replied_at)
    .fetch_optional(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?
    .ok_or_else(StatusError::not_found)?;

    Ok(Json(ApiResponse::new(ticket)))
}

#[handler]
pub async fn list_moderation_cases(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<crate::models::ListResponse<AdminModerationListItem>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let page_size = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * page_size;

    let rows = sqlx::query_as::<_, AdminModerationListRow>(
        "SELECT
            mc.id,
            mc.case_type::text AS case_type,
            mc.target_id,
            mc.target_snapshot_json,
            mc.status::text AS status,
            mc.decision_reason,
            mc.reviewed_by,
            mc.reviewed_at,
            mc.created_at,
            mc.updated_at,
            ap.display_name AS reviewer_display_name,
            ap.avatar_url AS reviewer_avatar_url
         FROM moderation_cases mc
         LEFT JOIN admin_profiles ap ON ap.account_id = mc.reviewed_by
         ORDER BY mc.created_at DESC
         LIMIT $1 OFFSET $2"
    )
    .bind(page_size)
    .bind(offset)
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;

    let total: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM moderation_cases")
        .fetch_one(pool)
        .await
        .map_err(|_| StatusError::internal_server_error())?;

    let response = crate::models::ListResponse {
        items: rows.into_iter().map(build_moderation_list_item).collect(),
        meta: crate::models::ListMeta::new(page, page_size, total.0),
    };

    Ok(Json(ApiResponse::new(response)))
}

#[handler]
pub async fn get_moderation_case(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<ModerationCase>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let case_id = req.param::<String>("case_id")
        .ok_or_else(StatusError::bad_request)?;

    let case_id = Uuid::parse_str(&case_id)
        .map_err(|_| StatusError::bad_request().brief("Invalid moderation case ID"))?;

    let case_record = sqlx::query_as::<_, ModerationCase>(
        "SELECT
            id,
            case_type::text AS case_type,
            target_id,
            target_snapshot_json,
            status::text AS status,
            decision_reason,
            reviewed_by,
            reviewed_at,
            created_at,
            updated_at
         FROM moderation_cases
         WHERE id = $1"
    )
    .bind(case_id)
    .fetch_optional(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?
    .ok_or_else(StatusError::not_found)?;

    Ok(Json(ApiResponse::new(case_record)))
}

#[handler]
pub async fn update_moderation_case(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<ModerationCase>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let case_id = req.param::<String>("case_id")
        .ok_or_else(StatusError::bad_request)?;

    let case_id = Uuid::parse_str(&case_id)
        .map_err(|_| StatusError::bad_request().brief("Invalid moderation case ID"))?;

    let body: UpdateModerationCaseRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request().brief("Invalid request body"))?;

    match body.status.as_str() {
        "pending" | "approved" | "rejected" => {}
        _ => return Err(StatusError::bad_request().brief("Invalid moderation status")),
    }

    let reviewer_id = auth::get_current_account_id(depot)?;
    let reviewed_at = if body.status == "pending" {
        None
    } else {
        Some(Utc::now())
    };

    let case_record = sqlx::query_as::<_, ModerationCase>(
        "UPDATE moderation_cases SET
            status = $2::moderation_status,
            decision_reason = $3,
            reviewed_by = CASE WHEN $2 = 'pending' THEN NULL ELSE $4 END,
            reviewed_at = CASE WHEN $2 = 'pending' THEN NULL ELSE $5 END,
            updated_at = NOW()
         WHERE id = $1
         RETURNING
            id,
            case_type::text AS case_type,
            target_id,
            target_snapshot_json,
            status::text AS status,
            decision_reason,
            reviewed_by,
            reviewed_at,
            created_at,
            updated_at"
    )
    .bind(case_id)
    .bind(&body.status)
    .bind(&body.decision_reason)
    .bind(reviewer_id)
    .bind(reviewed_at)
    .fetch_optional(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?
    .ok_or_else(StatusError::not_found)?;

    Ok(Json(ApiResponse::new(case_record)))
}

#[handler]
pub async fn list_announcements(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<crate::models::ListResponse<Announcement>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    let page = req.query::<i64>("page").unwrap_or(1).max(1);
    let page_size = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
    let offset = (page - 1) * page_size;

    let announcements = sqlx::query_as::<_, Announcement>("SELECT id, title, body_markdown, audience::text AS audience, status::text AS status, published_at, expires_at, created_by, created_at, updated_at FROM announcements ORDER BY created_at DESC LIMIT $1 OFFSET $2")
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

    let announcement = sqlx::query_as::<_, Announcement>("SELECT id, title, body_markdown, audience::text AS audience, status::text AS status, published_at, expires_at, created_by, created_at, updated_at FROM announcements WHERE id = $1")
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
        VALUES ($1, $2, $3, $4, $5) \
        RETURNING id, config_key, config_scope::text AS config_scope, value_json, status::text AS status, updated_by, updated_at"
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

    let config = sqlx::query_as::<_, SystemConfig>("SELECT id, config_key, config_scope::text AS config_scope, value_json, status::text AS status, updated_by, updated_at FROM system_configs WHERE config_key = $1")
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
