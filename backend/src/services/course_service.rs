use sqlx::PgPool;
use uuid::Uuid;
use crate::models::Course;

pub async fn list_published_courses(pool: &PgPool) -> Result<Vec<Course>, sqlx::Error> {
    sqlx::query_as::<_, Course>("SELECT * FROM courses WHERE status = 'published' ORDER BY sort_order")
        .fetch_all(pool)
        .await
}

pub async fn find_course_by_id(pool: &PgPool, id: Uuid) -> Result<Option<Course>, sqlx::Error> {
    sqlx::query_as::<_, Course>("SELECT * FROM courses WHERE id = $1")
        .bind(id)
        .fetch_optional(pool)
        .await
}

pub async fn create_course(
    pool: &PgPool,
    course_code: &str,
    title: &str,
    summary: &str,
    created_by: Uuid,
) -> Result<(), sqlx::Error> {
    let id = Uuid::new_v4();
    sqlx::query(
        "INSERT INTO courses (id, course_code, title, summary, status, sort_order, content_version, created_by) 
         VALUES ($1, $2, $3, $4, 'draft', 0, 1, $5)"
    )
    .bind(id)
    .bind(course_code)
    .bind(title)
    .bind(summary)
    .bind(created_by)
    .execute(pool)
    .await?;
    Ok(())
}

pub async fn update_course(
    pool: &PgPool,
    id: Uuid,
    title: Option<&str>,
    summary: Option<&str>,
    status: Option<&str>,
) -> Result<(), sqlx::Error> {
    sqlx::query(
        "UPDATE courses SET 
         title = COALESCE($2, title),
         summary = COALESCE($3, summary),
         status = COALESCE($4, status),
         updated_at = NOW()
         WHERE id = $1"
    )
    .bind(id)
    .bind(title)
    .bind(summary)
    .bind(status)
    .execute(pool)
    .await?;
    Ok(())
}

pub async fn delete_course(pool: &PgPool, id: Uuid) -> Result<(), sqlx::Error> {
    sqlx::query("DELETE FROM courses WHERE id = $1")
        .bind(id)
        .execute(pool)
        .await?;
    Ok(())
}
