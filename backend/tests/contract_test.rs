use chrono::Utc;
use salvo::prelude::*;
use salvo::test::{ResponseExt, TestClient};
use serial_test::serial;
use serde::Deserialize;
use serde_json::{json, Value};
use sqlx::PgPool;
use std::collections::{BTreeMap, BTreeSet};
use uuid::Uuid;

mod common;

use common::{create_test_service, setup_test_db};

const OPENAPI_PATH: &str = "/home/ltc/CodeQuest/contracts/openapi/openapi.yaml";

#[derive(Debug, Deserialize)]
struct OpenApiSpec {
    paths: BTreeMap<String, PathItem>,
}

#[derive(Debug, Deserialize, Default)]
struct PathItem {
    #[serde(default)]
    get: Option<Operation>,
    #[serde(default)]
    post: Option<Operation>,
    #[serde(default)]
    put: Option<Operation>,
    #[serde(default)]
    patch: Option<Operation>,
    #[serde(default)]
    delete: Option<Operation>,
}

#[derive(Debug, Deserialize, Default)]
struct Operation {
    #[serde(rename = "x-audience")]
    audience: Option<String>,
}

#[derive(Debug)]
struct SeedData {
    learner_id: Uuid,
    admin_id: Uuid,
    published_course_id: Uuid,
}

fn load_openapi_spec() -> OpenApiSpec {
    let contents = std::fs::read_to_string(OPENAPI_PATH).expect("Failed to read OpenAPI spec");
    serde_yaml::from_str(&contents).expect("Failed to parse OpenAPI spec")
}

fn operation_exists(path_item: &PathItem, method: &str) -> bool {
    match method {
        "GET" => path_item.get.is_some(),
        "POST" => path_item.post.is_some(),
        "PUT" => path_item.put.is_some(),
        "PATCH" => path_item.patch.is_some(),
        "DELETE" => path_item.delete.is_some(),
        _ => false,
    }
}

fn convert_path_to_router_format(path: &str) -> String {
    path.trim_start_matches("/").replace('{', "{").replace('}', "}")
}

fn assert_success_envelope(body: &Value) {
    assert!(body.get("data").is_some(), "response missing data: {body}");
    let meta = body
        .get("meta")
        .and_then(Value::as_object)
        .expect("response missing meta object");

    let request_id = meta
        .get("request_id")
        .and_then(Value::as_str)
        .expect("response meta missing request_id");
    assert!(Uuid::parse_str(request_id).is_ok(), "request_id is not uuid: {request_id}");

    let server_time = meta
        .get("server_time")
        .and_then(Value::as_str)
        .expect("response meta missing server_time");
    assert!(chrono::DateTime::parse_from_rfc3339(server_time).is_ok(), "server_time is not RFC3339: {server_time}");
}

fn assert_login_response_contract(body: &Value) {
    assert_success_envelope(body);
    let data = body.get("data").expect("login response missing data");

    for field in [
        "account_id",
        "active_role",
        "access_token",
        "refresh_token",
        "expires_in",
        "session_id",
        "profile",
    ] {
        assert!(data.get(field).is_some(), "login response missing `{field}`: {data}");
    }

    let account_id = data["account_id"].as_str().expect("account_id should be string");
    assert!(Uuid::parse_str(account_id).is_ok(), "account_id should be uuid");

    let active_role = data["active_role"].as_str().expect("active_role should be string");
    assert!(matches!(active_role, "learner" | "admin"), "unexpected active_role `{active_role}`");

    let session_id = data["session_id"].as_str().expect("session_id should be string");
    assert!(Uuid::parse_str(session_id).is_ok(), "session_id should be uuid");

    let expires_in = data["expires_in"].as_i64().expect("expires_in should be integer");
    assert!(expires_in > 0, "expires_in should be > 0");

    assert!(data["profile"].is_object(), "profile should be an object");
}

fn assert_learner_profile_contract(body: &Value) {
    assert_success_envelope(body);
    let data = body.get("data").expect("profile response missing data");

    for field in [
        "account_id",
        "nickname",
        "theme_mode",
        "daily_goal_minutes",
        "streak_days",
        "total_xp",
        "current_level",
        "friend_count",
        "ai_daily_limit",
        "created_at",
        "updated_at",
    ] {
        assert!(data.get(field).is_some(), "profile response missing `{field}`: {data}");
    }

    let account_id = data["account_id"].as_str().expect("account_id should be string");
    assert!(Uuid::parse_str(account_id).is_ok(), "account_id should be uuid");
    assert!(chrono::DateTime::parse_from_rfc3339(data["created_at"].as_str().expect("created_at should be string")).is_ok());
    assert!(chrono::DateTime::parse_from_rfc3339(data["updated_at"].as_str().expect("updated_at should be string")).is_ok());
}

fn assert_learner_courses_contract(body: &Value) {
    assert_success_envelope(body);
    let data = body.get("data").expect("courses response missing data");
    let items = data.get("items").and_then(Value::as_array).expect("courses data.items should be array");
    let list_meta = data.get("meta").and_then(Value::as_object).expect("courses data.meta should be object");

    for field in ["page", "page_size", "total", "has_more"] {
        assert!(list_meta.get(field).is_some(), "courses data.meta missing `{field}`: {list_meta:?}");
    }

    if let Some(first) = items.first() {
        for field in [
            "id",
            "title",
            "summary",
            "difficulty",
            "estimated_minutes",
            "sort_order",
            "published_at",
            "updated_at",
        ] {
            assert!(first.get(field).is_some(), "course item missing `{field}`: {first}");
        }
    }
}

fn assert_admin_course_detail_contract(body: &Value) {
    assert_success_envelope(body);
    let data = body.get("data").expect("admin course response missing data");

    for field in [
        "id",
        "course_code",
        "title",
        "summary",
        "difficulty",
        "estimated_minutes",
        "status",
        "sort_order",
        "content_version",
        "created_by",
        "created_at",
        "updated_at",
        "chapters",
    ] {
        assert!(data.get(field).is_some(), "admin course detail missing `{field}`: {data}");
    }
}

async fn reset_database(pool: &PgPool) {
    sqlx::query(
        "TRUNCATE TABLE \
         account_roles, sessions, learner_profiles, admin_profiles, courses, chapters, exercises, \
         exercise_options, exercise_test_cases, submissions, challenges, challenge_stages, \
         challenge_attempts, daily_challenges, daily_challenge_records, xp_ledger, badges, \
         learner_badges, friend_relations, social_activities, leaderboard_snapshots, course_progress, \
         ai_help_requests, feedback_tickets, moderation_cases, announcements, system_configs, audit_logs, accounts \
         RESTART IDENTITY CASCADE"
    )
    .execute(pool)
    .await
    .expect("failed to truncate test database");

    sqlx::query(
        "INSERT INTO accounts (id, email, password_hash, default_role, account_status) VALUES ($1, $2, $3, 'admin', 'active')"
    )
    .bind(Uuid::nil())
    .bind("system@localhost")
    .bind("$2b$12$dummyhashforlocalhostsystemaccount")
    .execute(pool)
    .await
    .expect("failed to restore system account");

    sqlx::query(
        "INSERT INTO system_configs (config_key, config_scope, value_json, updated_by) VALUES
         ('max_friends_per_learner', 'system', '{\"value\": 50}', $1),
         ('ai_daily_limit_default', 'ai', '{\"value\": 50}', $1),
         ('challenge_max_attempts_default', 'challenge', '{\"value\": 3}', $1),
         ('streak_bonus_xp_multiplier', 'reward', '{\"value\": 1.5}', $1)"
    )
    .bind(Uuid::nil())
    .execute(pool)
    .await
    .expect("failed to restore default system configs");
}

async fn seed_contract_data(pool: &PgPool) -> SeedData {
    reset_database(pool).await;

    let learner_id = Uuid::new_v4();
    let admin_id = Uuid::new_v4();
    let published_course_id = Uuid::new_v4();
    let now = Utc::now();
    let learner_password_hash = bcrypt::hash("Password123", bcrypt::DEFAULT_COST).expect("hash learner password");
    let admin_password_hash = bcrypt::hash("Admin12345", bcrypt::DEFAULT_COST).expect("hash admin password");

    sqlx::query(
        "INSERT INTO accounts (id, email, password_hash, default_role, account_status, created_at, updated_at)
         VALUES ($1, $2, $3, 'learner', 'active', $4, $4),
                ($5, $6, $7, 'admin', 'active', $4, $4)"
    )
    .bind(learner_id)
    .bind("contract-learner@example.com")
    .bind(&learner_password_hash)
    .bind(now)
    .bind(admin_id)
    .bind("admin@example.com")
    .bind(&admin_password_hash)
    .execute(pool)
    .await
    .expect("failed to insert seed accounts");

    sqlx::query(
        "INSERT INTO learner_profiles (
            account_id, nickname, avatar_url, bio, theme_mode, daily_goal_minutes,
            streak_days, total_xp, current_level, friend_count, ai_daily_limit,
            created_at, updated_at
         ) VALUES ($1, $2, $3, $4, 'system', 30, 7, 1200, 4, 2, 50, $5, $5)"
    )
    .bind(learner_id)
    .bind("Contract Learner")
    .bind("https://example.com/avatar.png")
    .bind("Contract profile")
    .bind(now)
    .execute(pool)
    .await
    .expect("failed to insert learner profile");

    sqlx::query(
        "INSERT INTO admin_profiles (account_id, display_name, admin_status, created_at, updated_at)
         VALUES ($1, $2, 'enabled', $3, $3)"
    )
    .bind(admin_id)
    .bind("Contract Admin")
    .bind(now)
    .execute(pool)
    .await
    .expect("failed to insert admin profile");

    sqlx::query(
        "INSERT INTO courses (
            id, course_code, title, summary, description, cover_image_url, difficulty,
            estimated_minutes, status, sort_order, content_version, created_by,
            published_at, created_at, updated_at
         ) VALUES ($1, $2, $3, $4, $5, $6, 'beginner', $7, 'published', $8, $9, $10, $11, $11, $11)"
    )
    .bind(published_course_id)
    .bind("CONTRACT-COURSE")
    .bind("Contract Testing Course")
    .bind("Course used by OpenAPI contract tests")
    .bind("Detailed contract test course")
    .bind("https://example.com/course-cover.png")
    .bind(45_i32)
    .bind(1_i32)
    .bind(1_i32)
    .bind(admin_id)
    .bind(now)
    .execute(pool)
    .await
    .expect("failed to insert published course");

    SeedData {
        learner_id,
        admin_id,
        published_course_id,
    }
}

async fn create_seeded_service() -> (Service, SeedData) {
    let pool = setup_test_db().await;
    let seed = seed_contract_data(&pool).await;
    let service = create_test_service(pool);
    (service, seed)
}

async fn learner_token(service: &Service) -> String {
    let mut response = TestClient::post("http://127.0.0.1:8080/api/v1/auth/learner/login")
        .json(&json!({
            "email": "contract-learner@example.com",
            "password": "Password123",
            "device_id": "device-learner-1",
            "platform": "ios"
        }))
        .send(service)
        .await;

    let status = response.status_code;
    let body_text = response.take_string().await.expect("learner login body text");
    let body: Value = serde_json::from_str(&body_text)
        .unwrap_or_else(|_| panic!("learner login body is not JSON: {body_text}"));
    assert_eq!(status, Some(StatusCode::OK), "learner login failed: {body}");
    body["data"]["access_token"]
        .as_str()
        .expect("learner access token missing")
        .to_string()
}

async fn admin_token(service: &Service) -> String {
    let mut response = TestClient::post("http://127.0.0.1:8080/api/v1/auth/admin/login")
        .json(&json!({
            "email": "admin@example.com",
            "password": "Admin12345",
            "device_id": "device-admin-1",
            "platform": "web"
        }))
        .send(service)
        .await;

    let status = response.status_code;
    let body_text = response.take_string().await.expect("admin login body text");
    let body: Value = serde_json::from_str(&body_text)
        .unwrap_or_else(|_| panic!("admin login body is not JSON: {body_text}"));
    assert_eq!(status, Some(StatusCode::OK), "admin login failed: {body}");
    body["data"]["access_token"]
        .as_str()
        .expect("admin access token missing")
        .to_string()
}

#[tokio::test]
#[serial]
async fn contract_routes_cover_all_openapi_paths() {
    let spec = load_openapi_spec();

    let expected: BTreeSet<(String, String)> = spec
        .paths
        .iter()
        .flat_map(|(path, item)| {
            ["GET", "POST", "PUT", "PATCH", "DELETE"]
                .into_iter()
                .filter(move |method| operation_exists(item, method))
                .map(move |method| (method.to_string(), format!("api/v1/{}", convert_path_to_router_format(path))))
        })
        .collect();

    let actual: BTreeSet<(String, String)> = [
        ("POST", "api/v1/auth/register"),
        ("POST", "api/v1/auth/learner/login"),
        ("POST", "api/v1/auth/admin/login"),
        ("POST", "api/v1/auth/refresh"),
        ("POST", "api/v1/auth/logout"),
        ("GET", "api/v1/learner/courses"),
        ("GET", "api/v1/learner/courses/{course_id}"),
        ("GET", "api/v1/learner/profile"),
        ("PATCH", "api/v1/learner/profile"),
        ("GET", "api/v1/learner/friends"),
        ("POST", "api/v1/learner/friends/requests"),
        ("PATCH", "api/v1/learner/friends/requests/{request_id}"),
        ("GET", "api/v1/learner/activities"),
        ("GET", "api/v1/learner/leaderboards"),
        ("GET", "api/v1/learner/stats/personal"),
        ("GET", "api/v1/learner/challenges"),
        ("POST", "api/v1/learner/challenges/{challenge_id}/attempts"),
        ("GET", "api/v1/learner/daily-challenges/today"),
        ("POST", "api/v1/learner/daily-challenges/{daily_challenge_id}/submit"),
        ("GET", "api/v1/learner/rewards"),
        ("POST", "api/v1/learner/submissions"),
        ("GET", "api/v1/learner/submissions/{submission_id}"),
        ("POST", "api/v1/learner/ai/help"),
        ("GET", "api/v1/learner/exercises/{exercise_id}"),
        ("GET", "api/v1/admin/stats/dashboard"),
        ("GET", "api/v1/admin/stats/courses"),
        ("GET", "api/v1/admin/stats/users"),
        ("GET", "api/v1/admin/courses"),
        ("POST", "api/v1/admin/courses"),
        ("PATCH", "api/v1/admin/courses/{course_id}"),
        ("GET", "api/v1/admin/challenges"),
        ("POST", "api/v1/admin/challenges"),
        ("PATCH", "api/v1/admin/challenges/{challenge_id}"),
        ("GET", "api/v1/admin/exercises"),
        ("POST", "api/v1/admin/exercises"),
        ("PATCH", "api/v1/admin/exercises/{exercise_id}"),
        ("GET", "api/v1/admin/users"),
        ("GET", "api/v1/admin/users/{user_id}"),
        ("PATCH", "api/v1/admin/users/{user_id}/status"),
        ("GET", "api/v1/admin/feedback"),
        ("PATCH", "api/v1/admin/feedback/{ticket_id}"),
        ("GET", "api/v1/admin/moderation"),
        ("PATCH", "api/v1/admin/moderation/{case_id}"),
        ("GET", "api/v1/admin/announcements"),
        ("POST", "api/v1/admin/announcements"),
        ("PATCH", "api/v1/admin/announcements/{announcement_id}"),
        ("GET", "api/v1/admin/configs"),
        ("PATCH", "api/v1/admin/configs/{config_key}"),
    ]
    .into_iter()
    .map(|(method, path)| (method.to_string(), path.to_string()))
    .collect();

    let missing: Vec<_> = expected.difference(&actual).cloned().collect();
    let unexpected: Vec<_> = actual.difference(&expected).cloned().collect();

    assert!(missing.is_empty(), "routes missing from implementation: {missing:?}");
    assert!(unexpected.is_empty(), "routes not documented in OpenAPI: {unexpected:?}");
}

#[tokio::test]
#[serial]
async fn contract_openapi_method_mismatches_are_detected() {
    let spec = load_openapi_spec();

    let profile = spec.paths.get("/learner/profile").expect("learner profile path missing in spec");
    assert!(profile.get.is_some(), "OpenAPI should define GET /learner/profile");
    assert!(profile.patch.is_some(), "OpenAPI should define PATCH /learner/profile");
    assert!(profile.put.is_none(), "OpenAPI should not define PUT /learner/profile");

    let admin_course = spec.paths.get("/admin/courses/{course_id}").expect("admin course detail path missing in spec");
    assert!(admin_course.patch.is_some(), "OpenAPI should define PATCH /admin/courses/{{course_id}}");
    assert!(admin_course.put.is_none(), "OpenAPI should not define PUT /admin/courses/{{course_id}}");
}

#[tokio::test]
#[serial]
async fn contract_auth_requirements_match_openapi_audience_rules() {
    let spec = load_openapi_spec();

    for path in [
        "/learner/courses",
        "/learner/profile",
        "/admin/courses",
    ] {
        let operation = spec.paths.get(path).expect("path missing in spec");
        let audience = if path.starts_with("/admin") {
            operation.post.as_ref().or(operation.get.as_ref()).and_then(|op| op.audience.as_deref())
        } else {
            operation.get.as_ref().and_then(|op| op.audience.as_deref())
        };
        assert!(audience.is_some(), "OpenAPI path `{path}` missing x-audience");
    }

    let (service, _) = create_seeded_service().await;
    let learner_jwt = learner_token(&service).await;

    let learner_no_auth = TestClient::get("http://127.0.0.1:8080/api/v1/learner/courses")
        .send(&service)
        .await;
    assert_eq!(learner_no_auth.status_code, Some(StatusCode::UNAUTHORIZED));

    let admin_no_auth = TestClient::post("http://127.0.0.1:8080/api/v1/admin/courses")
        .json(&json!({}))
        .send(&service)
        .await;
    assert_eq!(admin_no_auth.status_code, Some(StatusCode::UNAUTHORIZED));

    let admin_with_learner_role = TestClient::post("http://127.0.0.1:8080/api/v1/admin/courses")
        .bearer_auth(&learner_jwt)
        .json(&json!({
            "course_code": "FORBIDDEN-COURSE",
            "title": "Forbidden",
            "summary": "Forbidden",
            "difficulty": "beginner",
            "estimated_minutes": 10,
            "status": "draft",
            "sort_order": 1,
            "content_version": 1
        }))
        .send(&service)
        .await;
    assert_eq!(admin_with_learner_role.status_code, Some(StatusCode::FORBIDDEN));
}

#[tokio::test]
#[serial]
async fn contract_post_auth_register_matches_openapi() {
    let (service, _) = create_seeded_service().await;

    let mut response = TestClient::post("http://127.0.0.1:8080/api/v1/auth/register")
        .json(&json!({
            "email": "new-contract-user@example.com",
            "password": "Password123",
            "nickname": "New Learner",
            "device_id": "device-register-1",
            "platform": "ios"
        }))
        .send(&service)
        .await;

    let status = response.status_code;
    let body_text = response.take_string().await.expect("register body text");
    let body: Value = serde_json::from_str(&body_text)
        .unwrap_or_else(|_| panic!("register body is not JSON: {body_text}"));

    assert_eq!(status, Some(StatusCode::CREATED), "register status drifted from OpenAPI: {body}");
    assert_login_response_contract(&body);
}

#[tokio::test]
#[serial]
async fn contract_post_auth_learner_login_matches_openapi() {
    let (service, seed) = create_seeded_service().await;

    let mut response = TestClient::post("http://127.0.0.1:8080/api/v1/auth/learner/login")
        .json(&json!({
            "email": "contract-learner@example.com",
            "password": "Password123",
            "device_id": "device-login-1",
            "platform": "ios"
        }))
        .send(&service)
        .await;

    let status = response.status_code;
    let body_text = response.take_string().await.expect("learner login body text");
    let body: Value = serde_json::from_str(&body_text)
        .unwrap_or_else(|_| panic!("learner login body is not JSON: {body_text}"));

    assert_eq!(status, Some(StatusCode::OK), "learner login returned unexpected status: {body}");
    assert_login_response_contract(&body);
    assert_eq!(body["data"]["account_id"], Value::String(seed.learner_id.to_string()));
    assert_eq!(body["data"]["active_role"], Value::String("learner".to_string()));
}

#[tokio::test]
#[serial]
async fn contract_get_learner_courses_matches_openapi() {
    let (service, seed) = create_seeded_service().await;
    let token = learner_token(&service).await;

    let mut response = TestClient::get("http://127.0.0.1:8080/api/v1/learner/courses")
        .bearer_auth(&token)
        .send(&service)
        .await;

    let status = response.status_code;
    let body_text = response.take_string().await.expect("learner courses body text");
    let body: Value = serde_json::from_str(&body_text)
        .unwrap_or_else(|_| panic!("learner courses body is not JSON: {body_text}"));

    assert_eq!(status, Some(StatusCode::OK), "learner courses returned unexpected status: {body}");
    assert_learner_courses_contract(&body);

    let items = body["data"]["items"].as_array().expect("items should be array");
    assert!(items.iter().any(|item| item["id"] == seed.published_course_id.to_string()), "published course not returned in learner list: {items:?}");
}

#[tokio::test]
#[serial]
async fn contract_post_admin_courses_matches_openapi() {
    let (service, seed) = create_seeded_service().await;
    let token = admin_token(&service).await;
    let course_code = format!("ADMIN-{}", Uuid::new_v4().simple());

    let mut response = TestClient::post("http://127.0.0.1:8080/api/v1/admin/courses")
        .bearer_auth(&token)
        .json(&json!({
            "course_code": course_code,
            "title": "Admin Contract Course",
            "summary": "Created from contract test",
            "description": "Admin detail should match OpenAPI",
            "cover_image_url": "https://example.com/admin-course.png",
            "difficulty": "beginner",
            "estimated_minutes": 90,
            "status": "draft",
            "sort_order": 2,
            "content_version": 1
        }))
        .send(&service)
        .await;

    let status = response.status_code;
    let body_text = response.take_string().await.expect("admin course create body text");
    let body: Value = serde_json::from_str(&body_text)
        .unwrap_or_else(|_| panic!("admin course create body is not JSON: {body_text}"));

    assert_eq!(status, Some(StatusCode::OK), "admin course creation should follow OpenAPI 200 envelope: {body}");
    assert_admin_course_detail_contract(&body);
    assert_eq!(body["data"]["course_code"], Value::String(course_code));
    assert_eq!(body["data"]["created_by"], Value::String(seed.admin_id.to_string()));
}

#[tokio::test]
#[serial]
async fn contract_get_learner_profile_matches_openapi() {
    let (service, seed) = create_seeded_service().await;
    let token = learner_token(&service).await;

    let mut response = TestClient::get("http://127.0.0.1:8080/api/v1/learner/profile")
        .bearer_auth(&token)
        .send(&service)
        .await;

    let status = response.status_code;
    let body_text = response.take_string().await.expect("learner profile body text");
    let body: Value = serde_json::from_str(&body_text)
        .unwrap_or_else(|_| panic!("learner profile body is not JSON: {body_text}"));

    assert_eq!(status, Some(StatusCode::OK), "learner profile returned unexpected status: {body}");
    assert_learner_profile_contract(&body);
    assert_eq!(body["data"]["account_id"], Value::String(seed.learner_id.to_string()));
}
