use sqlx::{postgres::PgPoolOptions, PgPool};
use std::time::Duration;
use uuid::Uuid;

use crate::models::RoleType;

pub async fn create_pool(database_url: &str) -> Result<PgPool, sqlx::Error> {
    let pool = PgPoolOptions::new()
        .max_connections(20)
        .min_connections(5)
        .acquire_timeout(Duration::from_secs(30))
        .idle_timeout(Duration::from_secs(600))
        .max_lifetime(Duration::from_secs(1800))
        .connect(database_url)
        .await?;
    
    sqlx::query("SELECT 1")
        .fetch_one(&pool)
        .await
        .map_err(|e| {
            eprintln!("Database connection test failed: {}", e);
            e
        })?;
    
    Ok(pool)
}

#[allow(dead_code)]
pub async fn run_migrations(pool: &PgPool) -> Result<(), sqlx::migrate::MigrateError> {
    sqlx::migrate!("./migrations")
        .run(pool)
        .await
}

pub async fn seed_dev_accounts(pool: &PgPool) -> Result<(), sqlx::Error> {
    let desired_learner_id = Uuid::parse_str("00000000-0000-0000-0000-000000000001")
        .expect("valid learner seed uuid");
    let desired_admin_id = Uuid::parse_str("00000000-0000-0000-0000-000000000002")
        .expect("valid admin seed uuid");

    let learner_hash = bcrypt::hash("Password123", bcrypt::DEFAULT_COST)
        .expect("failed to hash learner seed password");
    let admin_hash = bcrypt::hash("Admin123", bcrypt::DEFAULT_COST)
        .expect("failed to hash admin seed password");

    let learner_id = sqlx::query_scalar::<_, Uuid>(
        "INSERT INTO accounts (id, email, password_hash, default_role, account_status)
         VALUES ($1, $2, $3, $4, 'active')
         ON CONFLICT (email) DO UPDATE SET
            password_hash = EXCLUDED.password_hash,
            default_role = EXCLUDED.default_role,
            account_status = EXCLUDED.account_status,
            updated_at = NOW()
         RETURNING id",
    )
    .bind(desired_learner_id)
    .bind("test@example.com")
    .bind(&learner_hash)
    .bind(RoleType::Learner)
    .fetch_one(pool)
    .await?;

    let admin_id = sqlx::query_scalar::<_, Uuid>(
        "INSERT INTO accounts (id, email, password_hash, default_role, account_status)
         VALUES ($1, $2, $3, $4, 'active')
         ON CONFLICT (email) DO UPDATE SET
            password_hash = EXCLUDED.password_hash,
            default_role = EXCLUDED.default_role,
            account_status = EXCLUDED.account_status,
            updated_at = NOW()
         RETURNING id",
    )
    .bind(desired_admin_id)
    .bind("admin@example.com")
    .bind(&admin_hash)
    .bind(RoleType::Admin)
    .fetch_one(pool)
    .await?;

    sqlx::query(
        "INSERT INTO learner_profiles (account_id, nickname, created_at, updated_at)
         VALUES ($1, $2, NOW(), NOW())
         ON CONFLICT (account_id) DO UPDATE SET
           nickname = EXCLUDED.nickname,
           updated_at = NOW()",
    )
    .bind(learner_id)
    .bind("TestUser")
    .execute(pool)
    .await?;

    sqlx::query(
        "INSERT INTO admin_profiles (account_id, display_name, admin_status, created_at, updated_at)
         VALUES ($1, $2, 'enabled', NOW(), NOW())
         ON CONFLICT (account_id) DO UPDATE SET
           display_name = EXCLUDED.display_name,
           admin_status = EXCLUDED.admin_status,
           updated_at = NOW()",
    )
    .bind(admin_id)
    .bind("AdminUser")
    .execute(pool)
    .await?;

    Ok(())
}
