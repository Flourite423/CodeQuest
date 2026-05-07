use sqlx::PgPool;
use uuid::Uuid;
use crate::models::{Account, RoleType, AccountStatus};

pub async fn find_account_by_id(pool: &PgPool, id: Uuid) -> Result<Option<Account>, sqlx::Error> {
    sqlx::query_as::<_, Account>("SELECT * FROM accounts WHERE id = $1")
        .bind(id)
        .fetch_optional(pool)
        .await
}

pub async fn find_account_by_email(pool: &PgPool, email: &str) -> Result<Option<Account>, sqlx::Error> {
    sqlx::query_as::<_, Account>("SELECT * FROM accounts WHERE email = $1")
        .bind(email)
        .fetch_optional(pool)
        .await
}

pub async fn create_account(
    pool: &PgPool,
    email: &str,
    role: RoleType,
) -> Result<Account, sqlx::Error> {
    let id = Uuid::new_v4();
    sqlx::query(
        "INSERT INTO accounts (id, email, password_hash, default_role, account_status) 
         VALUES ($1, $2, $3, $4, $5)"
    )
    .bind(id)
    .bind(email)
    .bind("")
    .bind(&role)
    .bind(AccountStatus::Active)
    .execute(pool)
    .await?;
    
    Ok(Account {
        id,
        email: email.to_string(),
        password_hash: "".to_string(),
        default_role: role.clone(),
        account_status: AccountStatus::Active,
        last_login_at: None,
        created_at: chrono::Utc::now(),
        updated_at: chrono::Utc::now(),
    })
}

pub async fn update_last_login(pool: &PgPool, id: Uuid) -> Result<(), sqlx::Error> {
    sqlx::query("UPDATE accounts SET last_login_at = NOW() WHERE id = $1")
        .bind(id)
        .execute(pool)
        .await?;
    Ok(())
}
