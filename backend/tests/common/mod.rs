use learning_app_backend::{config::AppConfig, db, routes};
use salvo::affix_state;
use salvo::prelude::*;
use salvo::test::{ResponseExt, TestClient};
use sqlx::{postgres::PgPoolOptions, PgPool};
use std::time::Duration;

pub async fn setup_test_db() -> PgPool {
    let database_url = std::env::var("TEST_DATABASE_URL")
        .unwrap_or_else(|_| "postgres://postgres:postgres@localhost/learning_app_test".to_string());

    let pool = PgPoolOptions::new()
        .max_connections(5)
        .acquire_timeout(Duration::from_secs(30))
        .connect(&database_url)
        .await
        .expect("Failed to connect to test database");

    sqlx::query("SELECT 1")
        .fetch_one(&pool)
        .await
        .expect("Failed to verify test database connection");

    let _ = db::run_migrations(&pool).await;

    sqlx::query("ALTER TABLE sessions ALTER COLUMN refresh_token_hash TYPE TEXT")
        .execute(&pool)
        .await
        .expect("Failed to widen sessions.refresh_token_hash for tests");

    let _ = sqlx::query(
        "TRUNCATE TABLE account_roles, sessions, learner_profiles, admin_profiles, courses, chapters, exercises, \
         exercise_options, exercise_test_cases, submissions, challenges, challenge_stages, \
         challenge_attempts, daily_challenges, daily_challenge_records, xp_ledger, badges, \
         learner_badges, friend_relations, social_activities, leaderboard_snapshots, course_progress, \
         ai_help_requests, feedback_tickets, moderation_cases, announcements, system_configs, audit_logs, accounts \
         RESTART IDENTITY CASCADE"
    )
    .execute(&pool)
    .await;

    seed_test_accounts(&pool).await;
    pool
}

async fn seed_test_accounts(pool: &PgPool) {
    let learner_hash = bcrypt::hash("Password123", bcrypt::DEFAULT_COST).unwrap_or_default();
    let admin_hash = bcrypt::hash("Admin123", bcrypt::DEFAULT_COST).unwrap_or_default();

    let _ = sqlx::query(
        "INSERT INTO accounts (id, email, password_hash, default_role, account_status)
         VALUES ($1, $2, $3, 'learner', 'active'),
                ($4, $5, $6, 'admin', 'active')
         ON CONFLICT (email) DO UPDATE SET password_hash = EXCLUDED.password_hash"
    )
    .bind(uuid::Uuid::parse_str("00000000-0000-0000-0000-000000000001").unwrap_or_else(|_| uuid::Uuid::new_v4()))
    .bind("test@example.com")
    .bind(&learner_hash)
    .bind(uuid::Uuid::parse_str("00000000-0000-0000-0000-000000000002").unwrap_or_else(|_| uuid::Uuid::new_v4()))
    .bind("admin@example.com")
    .bind(&admin_hash)
    .execute(pool)
    .await;

    let _ = sqlx::query(
        "INSERT INTO learner_profiles (account_id, nickname, created_at, updated_at)
         SELECT id, 'TestUser', NOW(), NOW() FROM accounts WHERE email = 'test@example.com'
         ON CONFLICT (account_id) DO NOTHING"
    )
    .execute(pool)
    .await;

    let _ = sqlx::query(
        "INSERT INTO admin_profiles (account_id, display_name, admin_status, created_at, updated_at)
         SELECT id, 'AdminUser', 'enabled', NOW(), NOW() FROM accounts WHERE email = 'admin@example.com'
         ON CONFLICT (account_id) DO NOTHING"
    )
    .execute(pool)
    .await;
}

pub fn create_test_service(pool: PgPool) -> Service {
    let cfg = AppConfig {
        server_addr: "127.0.0.1:8080".to_string(),
        database_url: "postgres://postgres:postgres@localhost/learning_app_test".to_string(),
        jwt_secret: "test-secret-key-at-least-32-bytes-long!!".to_string(),
        jwt_expiration: 86400,
        ai: learning_app_backend::config::AiConfig {
            provider: "mock".to_string(),
            mock_response: "Test response".to_string(),
        },
    };
    
    let router = routes::create_router()
        .hoop(affix_state::inject(pool))
        .hoop(affix_state::inject(cfg));
    Service::new(router)
}

#[allow(dead_code)]
pub async fn get_auth_token(service: &Service) -> String {
    let mut res = TestClient::post("http://127.0.0.1:8080/api/v1/auth/learner/login")
        .json(&serde_json::json!({
            "email": "test@example.com",
            "password": "Password123"
        }))
        .send(service)
        .await;

    let body = res.take_json::<serde_json::Value>().await.unwrap();
    body["data"]["access_token"].as_str().unwrap().to_string()
}

#[allow(dead_code)]
pub async fn get_admin_token(service: &Service) -> String {
    let mut res = TestClient::post("http://127.0.0.1:8080/api/v1/auth/admin/login")
        .json(&serde_json::json!({
            "email": "admin@example.com",
            "password": "Admin123"
        }))
        .send(service)
        .await;

    let body = res.take_json::<serde_json::Value>().await.unwrap();
    body["data"]["access_token"].as_str().unwrap().to_string()
}
