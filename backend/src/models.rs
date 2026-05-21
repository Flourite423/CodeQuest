use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::Type)]
#[sqlx(type_name = "role_type", rename_all = "snake_case")]
pub enum RoleType {
    Learner,
    Admin,
}

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::Type)]
#[sqlx(type_name = "account_status", rename_all = "snake_case")]
pub enum AccountStatus {
    Active,
    Suspended,
    Closed,
}

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::Type)]
#[sqlx(type_name = "difficulty_level", rename_all = "snake_case")]
pub enum DifficultyLevel {
    Beginner,
    Intermediate,
    Easy,
    Medium,
    Hard,
}

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::Type)]
#[sqlx(type_name = "ai_request_type", rename_all = "snake_case")]
pub enum AiRequestType {
    ErrorExplanation,
    Hint,
}

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::Type)]
#[sqlx(type_name = "ai_request_status", rename_all = "snake_case")]
pub enum AiRequestStatus {
    Pending,
    Succeeded,
    Failed,
    RateLimited,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct Account {
    pub id: Uuid,
    pub email: String,
    pub password_hash: String,
    pub default_role: RoleType,
    pub account_status: AccountStatus,
    pub last_login_at: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
#[allow(dead_code)]
pub struct AccountRole {
    pub id: Uuid,
    pub account_id: Uuid,
    pub role: String,
    pub role_status: String,
    pub granted_at: DateTime<Utc>,
    pub revoked_at: Option<DateTime<Utc>>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
#[allow(dead_code)]
pub struct Session {
    pub id: Uuid,
    pub account_id: Uuid,
    pub role: String,
    pub device_id: String,
    pub device_name: Option<String>,
    pub platform: String,
    pub ip_address: Option<String>,
    pub user_agent: Option<String>,
    pub refresh_token_hash: String,
    pub refresh_expires_at: DateTime<Utc>,
    pub revoked_at: Option<DateTime<Utc>>,
    pub last_seen_at: DateTime<Utc>,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
#[allow(dead_code)]
pub struct LearnerProfile {
    pub account_id: Uuid,
    pub nickname: String,
    pub avatar_url: Option<String>,
    pub bio: Option<String>,
    pub theme_mode: String,
    pub daily_goal_minutes: i32,
    pub streak_days: i32,
    pub total_xp: i32,
    pub current_level: i32,
    pub friend_count: i32,
    pub ai_daily_limit: i32,
    pub last_study_at: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
#[allow(dead_code)]
pub struct AdminProfile {
    pub account_id: Uuid,
    pub display_name: String,
    pub avatar_url: Option<String>,
    pub admin_status: String,
    pub last_active_at: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct Course {
    pub id: Uuid,
    pub course_code: String,
    pub title: String,
    pub summary: String,
    pub description: Option<String>,
    pub cover_image_url: Option<String>,
    pub difficulty: String,
    pub estimated_minutes: i32,
    pub status: String,
    pub sort_order: i32,
    pub content_version: i32,
    pub created_by: Uuid,
    pub published_at: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct Chapter {
    pub id: Uuid,
    pub course_id: Uuid,
    pub chapter_code: String,
    pub title: String,
    pub summary: String,
    pub learning_content_markdown: String,
    pub sample_code: Option<String>,
    pub estimated_minutes: i32,
    pub order_index: i32,
    pub unlock_rule: String,
    pub status: String,
    pub content_version: i32,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct Exercise {
    pub id: Uuid,
    pub chapter_id: Uuid,
    pub exercise_code: String,
    pub title: String,
    pub prompt: String,
    pub exercise_type: String,
    pub starter_code: Option<String>,
    pub language: String,
    pub difficulty: String,
    pub pass_score: i32,
    pub max_attempts_per_day: Option<i32>,
    pub status: String,
    pub content_version: i32,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
#[allow(dead_code)]
pub struct ExerciseOption {
    pub id: Uuid,
    pub exercise_id: Uuid,
    pub option_key: String,
    pub option_text: String,
    pub is_correct: bool,
    pub order_index: i32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct LearnerExerciseOption {
    pub id: Uuid,
    pub exercise_id: Uuid,
    pub option_key: String,
    pub option_text: String,
    pub order_index: i32,
}

impl From<ExerciseOption> for LearnerExerciseOption {
    fn from(option: ExerciseOption) -> Self {
        Self {
            id: option.id,
            exercise_id: option.exercise_id,
            option_key: option.option_key,
            option_text: option.option_text,
            order_index: option.order_index,
        }
    }
}

#[derive(Debug, Serialize, Deserialize)]
pub struct LearnerVisibleTestCase {
    pub id: Uuid,
    pub exercise_id: Uuid,
    pub case_name: String,
    pub case_type: String,
    pub input_payload_json: Option<serde_json::Value>,
    pub weight: i32,
    pub order_index: i32,
    pub rule_version: i32,
}

impl From<ExerciseTestCase> for LearnerVisibleTestCase {
    fn from(tc: ExerciseTestCase) -> Self {
        Self {
            id: tc.id,
            exercise_id: tc.exercise_id,
            case_name: tc.case_name,
            case_type: tc.case_type,
            input_payload_json: tc.input_payload_json,
            weight: tc.weight,
            order_index: tc.order_index,
            rule_version: tc.rule_version,
        }
    }
}

#[derive(Debug, Serialize, Deserialize)]
pub struct LearnerExerciseDetail {
    pub exercise: Exercise,
    pub options: Vec<LearnerExerciseOption>,
    pub visible_test_cases: Vec<LearnerVisibleTestCase>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
#[allow(dead_code)]
pub struct ExerciseTestCase {
    pub id: Uuid,
    pub exercise_id: Uuid,
    pub case_name: String,
    pub case_type: String,
    pub input_payload_json: Option<serde_json::Value>,
    pub expected_payload_json: serde_json::Value,
    pub weight: i32,
    pub is_hidden: bool,
    pub order_index: i32,
    pub rule_version: i32,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
#[allow(dead_code)]
pub struct ChallengeStage {
    pub id: Uuid,
    pub challenge_id: Uuid,
    pub exercise_id: Uuid,
    pub order_index: i32,
    pub star_rule_json: serde_json::Value,
    pub unlock_rule_json: serde_json::Value,
    pub rule_version: i32,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
#[allow(dead_code)]
pub struct ChallengeAttempt {
    pub id: Uuid,
    pub challenge_id: Uuid,
    pub learner_id: Uuid,
    pub best_star: i32,
    pub status: String,
    pub started_at: Option<DateTime<Utc>>,
    pub completed_at: Option<DateTime<Utc>>,
    pub reward_claimed_at: Option<DateTime<Utc>>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
#[allow(dead_code)]
pub struct DailyChallengeRecord {
    pub id: Uuid,
    pub daily_challenge_id: Uuid,
    pub learner_id: Uuid,
    pub status: String,
    pub score: i32,
    pub elapsed_seconds: Option<i32>,
    pub streak_after_completion: i32,
    pub completed_at: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct Submission {
    pub id: Uuid,
    pub exercise_id: Uuid,
    pub learner_id: Uuid,
    pub chapter_id: Uuid,
    pub attempt_no: i32,
    pub source_code: String,
    pub judge_status: String,
    pub score: i32,
    pub passed_case_count: i32,
    pub total_case_count: i32,
    pub error_summary: Option<String>,
    pub runtime_ms: Option<i32>,
    pub content_version: i32,
    pub rule_version: i32,
    pub submitted_at: DateTime<Utc>,
    pub completed_at: Option<DateTime<Utc>>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct Challenge {
    pub id: Uuid,
    pub challenge_code: String,
    pub title: String,
    pub summary: String,
    pub related_course_id: Option<Uuid>,
    pub difficulty: String,
    pub reward_xp: i32,
    pub status: String,
    pub sort_order: i32,
    pub content_version: i32,
    pub published_at: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}



#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct DailyChallenge {
    pub id: Uuid,
    pub challenge_date: chrono::NaiveDate,
    pub title: String,
    pub exercise_id: Uuid,
    pub difficulty: String,
    pub time_limit_seconds: i32,
    pub reward_xp: i32,
    pub status: String,
    pub published_at: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct XpLedger {
    pub id: Uuid,
    pub learner_id: Uuid,
    pub source_type: String,
    pub source_id: Uuid,
    pub delta_xp: i32,
    pub balance_after: i32,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
#[allow(dead_code)]
pub struct Badge {
    pub id: Uuid,
    pub badge_code: String,
    pub name: String,
    pub description: String,
    pub icon_url: Option<String>,
    pub rule_type: String,
    pub rule_config_json: serde_json::Value,
    pub status: String,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct LearnerBadge {
    pub id: Uuid,
    pub learner_id: Uuid,
    pub badge_id: Uuid,
    pub award_source_type: String,
    pub award_source_id: Option<Uuid>,
    pub awarded_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct FriendRelation {
    pub id: Uuid,
    pub requester_id: Uuid,
    pub addressee_id: Uuid,
    pub status: String,
    pub created_at: DateTime<Utc>,
    pub responded_at: Option<DateTime<Utc>>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct SocialActivity {
    pub id: Uuid,
    pub learner_id: Uuid,
    pub activity_type: String,
    pub visibility: String,
    pub payload_json: serde_json::Value,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct LeaderboardSnapshot {
    pub id: Uuid,
    pub board_type: String,
    pub period_key: String,
    pub learner_id: Uuid,
    pub score: i32,
    pub rank_position: i32,
    pub generated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct CourseProgress {
    pub id: Uuid,
    pub learner_id: Uuid,
    pub course_id: Uuid,
    pub completed_chapter_count: i32,
    pub total_chapter_count: i32,
    pub completed_exercise_count: i32,
    pub progress_percent: i32,
    pub last_studied_chapter_id: Option<Uuid>,
    pub status: String,
    pub started_at: Option<DateTime<Utc>>,
    pub completed_at: Option<DateTime<Utc>>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct AiHelpRequest {
    pub id: Uuid,
    pub learner_id: Uuid,
    pub exercise_id: Option<Uuid>,
    pub submission_id: Option<Uuid>,
    pub request_type: AiRequestType,
    pub source_code: Option<String>,
    pub error_context_json: Option<serde_json::Value>,
    pub response_text: Option<String>,
    pub response_structured_json: Option<serde_json::Value>,
    pub provider_name: String,
    pub token_usage: Option<i32>,
    pub latency_ms: Option<i32>,
    pub status: AiRequestStatus,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
#[allow(dead_code)]
pub struct FeedbackTicket {
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
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
#[allow(dead_code)]
pub struct ModerationCase {
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
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct Announcement {
    pub id: Uuid,
    pub title: String,
    pub body_markdown: String,
    pub audience: String,
    pub status: String,
    pub published_at: Option<DateTime<Utc>>,
    pub expires_at: Option<DateTime<Utc>>,
    pub created_by: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct SystemConfig {
    pub id: Uuid,
    pub config_key: String,
    pub config_scope: String,
    pub value_json: serde_json::Value,
    pub status: String,
    pub updated_by: Uuid,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
#[allow(dead_code)]
pub struct AuditLog {
    pub id: Uuid,
    pub actor_id: Option<Uuid>,
    pub action: String,
    pub resource_type: String,
    pub resource_id: Option<Uuid>,
    pub old_value_json: Option<serde_json::Value>,
    pub new_value_json: Option<serde_json::Value>,
    pub ip_address: Option<String>,
    pub user_agent: Option<String>,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ApiResponse<T> {
    pub data: T,
    pub meta: ResponseMeta,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ResponseMeta {
    pub request_id: String,
    pub server_time: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ListResponse<T> {
    pub items: Vec<T>,
    pub meta: ListMeta,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ListMeta {
    pub page: i64,
    pub page_size: i64,
    pub total: i64,
    pub has_more: bool,
}

impl ListMeta {
    pub fn new(page: i64, page_size: i64, total: i64) -> Self {
        Self {
            page,
            page_size,
            total,
            has_more: page * page_size < total,
        }
    }
}

impl Default for ResponseMeta {
    fn default() -> Self {
        Self::new()
    }
}

impl ResponseMeta {
    pub fn new() -> Self {
        Self {
            request_id: Uuid::new_v4().to_string(),
            server_time: Utc::now(),
        }
    }
}

impl<T> ApiResponse<T> {
    pub fn new(data: T) -> Self {
        Self {
            data,
            meta: ResponseMeta::new(),
        }
    }
}

#[derive(Debug, Serialize, Deserialize)]
#[allow(dead_code)]
pub struct ApiError {
    pub error: ErrorDetail,
    pub meta: ResponseMeta,
}

#[derive(Debug, Serialize, Deserialize)]
#[allow(dead_code)]
pub struct ErrorDetail {
    pub code: String,
    pub message: String,
    pub details: Option<serde_json::Value>,
}

impl ApiError {
    #[allow(dead_code)]
    pub fn new(code: &str, message: &str) -> Self {
        Self {
            error: ErrorDetail {
                code: code.to_string(),
                message: message.to_string(),
                details: None,
            },
            meta: ResponseMeta::new(),
        }
    }
}
