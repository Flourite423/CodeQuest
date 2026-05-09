use sqlx::PgPool;
use uuid::Uuid;
use crate::models::Course;

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

#[derive(Debug, serde::Serialize)]
pub struct CourseListMeta {
    pub page: i64,
    pub page_size: i64,
    pub total: i64,
    pub has_more: bool,
}

#[derive(Debug, serde::Serialize)]
pub struct LearnerCourseListItem {
    pub id: Uuid,
    pub title: String,
    pub summary: String,
    pub cover_image_url: Option<String>,
    pub difficulty: String,
    pub estimated_minutes: i32,
    pub sort_order: i32,
    pub published_at: chrono::DateTime<chrono::Utc>,
    pub updated_at: chrono::DateTime<chrono::Utc>,
}

#[derive(Debug, serde::Serialize)]
pub struct LearnerCourseListResponse {
    pub items: Vec<LearnerCourseListItem>,
    pub meta: CourseListMeta,
}

pub async fn list_published_courses(pool: &PgPool, page: i64, per_page: i64, sort_by: Option<&str>, sort_order: Option<&str>) -> Result<Vec<Course>, sqlx::Error> {
    let offset = (page - 1) * per_page;
    let sort_column = match sort_by {
        Some("title") => "title",
        Some("created_at") => "created_at",
        Some("updated_at") => "updated_at",
        Some("published_at") => "published_at",
        _ => "sort_order",
    };
    let order = if sort_order == Some("asc") { "ASC" } else { "DESC" };
    let query = format!("{COURSE_SELECT_COLUMNS} WHERE status = 'published' ORDER BY {} {} LIMIT $1 OFFSET $2", sort_column, order);
    sqlx::query_as::<_, Course>(&query)
    .bind(per_page)
    .bind(offset)
    .fetch_all(pool)
    .await
}

#[allow(dead_code)]
pub async fn count_published_courses(pool: &PgPool) -> Result<i64, sqlx::Error> {
    let row: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM courses WHERE status = 'published'")
        .fetch_one(pool)
        .await?;
    Ok(row.0)
}

pub async fn list_published_courses_with_meta(
    pool: &PgPool,
    page: i64,
    per_page: i64,
    sort_by: Option<&str>,
    sort_order: Option<&str>,
) -> Result<LearnerCourseListResponse, sqlx::Error> {
    let items = list_published_courses(pool, page, per_page, sort_by, sort_order).await?
        .into_iter()
        .filter_map(|course| {
            course.published_at.map(|published_at| LearnerCourseListItem {
                id: course.id,
                title: course.title,
                summary: course.summary,
                cover_image_url: course.cover_image_url,
                difficulty: course.difficulty,
                estimated_minutes: course.estimated_minutes,
                sort_order: course.sort_order,
                published_at,
                updated_at: course.updated_at,
            })
        })
        .collect::<Vec<_>>();

    let total = count_published_courses(pool).await?;
    let has_more = page * per_page < total;

    Ok(LearnerCourseListResponse {
        items,
        meta: CourseListMeta {
            page,
            page_size: per_page,
            total,
            has_more,
        },
    })
}

pub async fn find_course_by_id(pool: &PgPool, id: Uuid) -> Result<Option<Course>, sqlx::Error> {
    let query = format!("{COURSE_SELECT_COLUMNS} WHERE id = $1");
    sqlx::query_as::<_, Course>(&query)
        .bind(id)
        .fetch_optional(pool)
        .await
}

#[allow(dead_code)]
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

#[allow(dead_code)]
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

#[allow(dead_code)]
pub async fn delete_course(pool: &PgPool, id: Uuid) -> Result<(), sqlx::Error> {
    sqlx::query("DELETE FROM courses WHERE id = $1")
        .bind(id)
        .execute(pool)
        .await?;
    Ok(())
}
