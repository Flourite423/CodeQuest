use learning_app_backend::{config::AppConfig, routes};
use salvo::affix_state;
use salvo::prelude::*;
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

    pool
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
