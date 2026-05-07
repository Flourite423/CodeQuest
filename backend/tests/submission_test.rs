use salvo::prelude::*;
use salvo::test::{ResponseExt, TestClient};
use serde_json::json;
mod common;

use common::{create_test_service, get_auth_token, get_admin_token, setup_test_db};

#[tokio::test]
async fn test_create_submission() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let admin_token = get_admin_token(&service).await;
    let learner_token = get_auth_token(&service).await;
    
    let course_code = format!("COURSE-{}", uuid::Uuid::new_v4().to_string().split('-').next().unwrap());
    let mut course_res = TestClient::post("http://127.0.0.1:8080/api/v1/admin/courses")
        .bearer_auth(&admin_token)
        .json(&json!({
            "course_code": course_code,
            "title": "Test Course",
            "summary": "A test course",
            "difficulty": "beginner",
            "estimated_minutes": 60
        }))
        .send(&service)
        .await;
    
    assert_eq!(course_res.status_code, Some(StatusCode::CREATED));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/courses")
        .bearer_auth(&learner_token)
        .send(&service)
        .await;
    
    let body = list_res.take_json::<serde_json::Value>().await.unwrap();
    let courses = body["data"].as_array().unwrap();
    
    if !courses.is_empty() {
        let course_id = courses[0]["id"].as_str().unwrap();
        
        let chapter_code = format!("CHAPTER-{}", uuid::Uuid::new_v4().to_string().split('-').next().unwrap());
        let mut chapter_res = TestClient::post(&format!("http://127.0.0.1:8080/api/v1/admin/chapters/{}", course_id))
            .bearer_auth(&admin_token)
            .json(&json!({
                "chapter_code": chapter_code,
                "title": "Test Chapter",
                "summary": "A test chapter",
                "learning_content_markdown": "# Chapter Content",
                "estimated_minutes": 30,
                "order_index": 1
            }))
            .send(&service)
            .await;
        
        assert_eq!(chapter_res.status_code, Some(StatusCode::CREATED));
        
        let mut chapters_res = TestClient::get(&format!("http://127.0.0.1:8080/api/v1/learner/courses/{}/chapters", course_id))
            .bearer_auth(&learner_token)
            .send(&service)
            .await;
        
        let chapters_body = chapters_res.take_json::<serde_json::Value>().await.unwrap();
        let chapters = chapters_body["data"].as_array().unwrap();
        
        if !chapters.is_empty() {
            let chapter_id = chapters[0]["id"].as_str().unwrap();
            
            let exercise_code = format!("EX-{}", uuid::Uuid::new_v4().to_string().split('-').next().unwrap());
            let mut exercise_res = TestClient::post(&format!("http://127.0.0.1:8080/api/v1/admin/chapters/{}/exercises", chapter_id))
                .bearer_auth(&admin_token)
                .json(&json!({
                    "exercise_code": exercise_code,
                    "title": "Test Exercise",
                    "prompt": "Write a function...",
                    "exercise_type": "coding",
                    "language": "python",
                    "difficulty": "easy",
                    "pass_score": 100
                }))
                .send(&service)
                .await;
            
            assert_eq!(exercise_res.status_code, Some(StatusCode::CREATED));
            
            let mut exercises_res = TestClient::get(&format!("http://127.0.0.1:8080/api/v1/learner/courses/{}/chapters/{}/exercises", course_id, chapter_id))
                .bearer_auth(&learner_token)
                .send(&service)
                .await;
            
            let exercises_body = exercises_res.take_json::<serde_json::Value>().await.unwrap();
            let exercises = exercises_body["data"].as_array().unwrap();
            
            if !exercises.is_empty() {
                let exercise_id = exercises[0]["id"].as_str().unwrap();
                
                let mut submission_res = TestClient::post(&format!("http://127.0.0.1:8080/api/v1/learner/submissions?exercise_id={}", exercise_id))
                    .bearer_auth(&learner_token)
                    .json(&json!({
                        "source_code": "def hello(): return 'world'"
                    }))
                    .send(&service)
                    .await;
                
                assert_eq!(submission_res.status_code, Some(StatusCode::CREATED));
            }
        }
    }
}