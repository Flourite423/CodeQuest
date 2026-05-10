use sqlx::PgPool;
use uuid::Uuid;
use crate::models::CourseProgress;

pub async fn list_progress_by_learner(
    pool: &PgPool,
    learner_id: Uuid,
) -> Result<Vec<CourseProgress>, sqlx::Error> {
    sqlx::query_as::<_, CourseProgress>(
        "SELECT id, learner_id, course_id, completed_chapter_count, total_chapter_count, completed_exercise_count, progress_percent, last_studied_chapter_id, status::text AS status, started_at, completed_at, updated_at FROM course_progress WHERE learner_id = $1 ORDER BY updated_at DESC"
    )
    .bind(learner_id)
    .fetch_all(pool)
    .await
}

pub async fn find_progress_by_learner_and_course(
    pool: &PgPool,
    learner_id: Uuid,
    course_id: Uuid,
) -> Result<Option<CourseProgress>, sqlx::Error> {
    sqlx::query_as::<_, CourseProgress>(
        "SELECT id, learner_id, course_id, completed_chapter_count, total_chapter_count, completed_exercise_count, progress_percent, last_studied_chapter_id, status::text AS status, started_at, completed_at, updated_at FROM course_progress WHERE learner_id = $1 AND course_id = $2"
    )
    .bind(learner_id)
    .bind(course_id)
    .fetch_optional(pool)
    .await
}

pub async fn create_progress(
    pool: &PgPool,
    learner_id: Uuid,
    course_id: Uuid,
) -> Result<(), sqlx::Error> {
    let id = Uuid::new_v4();
    sqlx::query(
        "INSERT INTO course_progress (id, learner_id, course_id, completed_chapter_count, 
         total_chapter_count, completed_exercise_count, progress_percent, status, started_at) 
         VALUES ($1, $2, $3, 0, 0, 0, 0, 'in_progress', NOW())"
    )
    .bind(id)
    .bind(learner_id)
    .bind(course_id)
    .execute(pool)
    .await?;
    Ok(())
}

pub async fn update_progress(
    pool: &PgPool,
    learner_id: Uuid,
    course_id: Uuid,
    completed_chapter_count: Option<i32>,
    total_chapter_count: Option<i32>,
    completed_exercise_count: Option<i32>,
    progress_percent: Option<i32>,
    last_studied_chapter_id: Option<Uuid>,
    status: Option<&str>,
) -> Result<(), sqlx::Error> {
    sqlx::query(
        "UPDATE course_progress SET 
         completed_chapter_count = COALESCE($3, completed_chapter_count),
         total_chapter_count = COALESCE($4, total_chapter_count),
         completed_exercise_count = COALESCE($5, completed_exercise_count),
         progress_percent = COALESCE($6, progress_percent),
         last_studied_chapter_id = COALESCE($7, last_studied_chapter_id),
         status = COALESCE($8, status),
         completed_at = CASE WHEN $8 = 'completed' THEN NOW() ELSE completed_at END,
         updated_at = NOW()
         WHERE learner_id = $1 AND course_id = $2"
    )
    .bind(learner_id)
    .bind(course_id)
    .bind(completed_chapter_count)
    .bind(total_chapter_count)
    .bind(completed_exercise_count)
    .bind(progress_percent)
    .bind(last_studied_chapter_id)
    .bind(status)
    .execute(pool)
    .await?;
    Ok(())
}

pub async fn complete_chapter(
    pool: &PgPool,
    learner_id: Uuid,
    course_id: Uuid,
    chapter_id: Uuid,
) -> Result<(), sqlx::Error> {
    sqlx::query(
        "UPDATE course_progress SET 
         completed_chapter_count = completed_chapter_count + 1,
         last_studied_chapter_id = $3,
         updated_at = NOW()
         WHERE learner_id = $1 AND course_id = $2"
    )
    .bind(learner_id)
    .bind(course_id)
    .bind(chapter_id)
    .execute(pool)
    .await?;
    Ok(())
}

pub async fn delete_progress(
    pool: &PgPool,
    learner_id: Uuid,
    course_id: Uuid,
) -> Result<(), sqlx::Error> {
    sqlx::query("DELETE FROM course_progress WHERE learner_id = $1 AND course_id = $2")
        .bind(learner_id)
        .bind(course_id)
        .execute(pool)
        .await?;
    Ok(())
}
