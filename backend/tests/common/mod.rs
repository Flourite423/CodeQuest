use learning_app_backend::routes;
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
    let router = routes::create_router().hoop(affix_state::inject(pool));
    Service::new(router)
}
