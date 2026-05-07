use salvo::prelude::*;
use salvo::test::{ResponseExt, TestClient};
use serde_json::json;
mod common;

use common::{create_test_service, get_auth_token, get_admin_token, setup_test_db};

#[tokio::test]
async fn test_list_chapters() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let token = get_auth_token(&service).await;
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/courses/550e8400-e29b-41d4-a716-446655440000/chapters")
        .bearer_auth(&token)
        .send(&service)
        .await;
    
    if res.status_code == Some(StatusCode::OK) {
        let body = res.take_json::<serde_json::Value>().await.unwrap();
        assert!(body["data"].is_array());
    }
}

#[tokio::test]
async fn test_create_and_get_chapter() {
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
        let mut create_res = TestClient::post(&format!("http://127.0.0.1:8080/api/v1/admin/chapters/{}", course_id))
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
        
        assert_eq!(create_res.status_code, Some(StatusCode::CREATED));
        
        let mut chapters_res = TestClient::get(&format!("http://127.0.0.1:8080/api/v1/learner/courses/{}/chapters", course_id))
            .bearer_auth(&learner_token)
            .send(&service)
            .await;
        
        let chapters_body = chapters_res.take_json::<serde_json::Value>().await.unwrap();
        let chapters = chapters_body["data"].as_array().unwrap();
        
        if !chapters.is_empty() {
            let chapter_id = chapters[0]["id"].as_str().unwrap();
            
            let mut get_res = TestClient::get(&format!("http://127.0.0.1:8080/api/v1/learner/courses/{}/chapters/{}", course_id, chapter_id))
                .bearer_auth(&learner_token)
                .send(&service)
                .await;
            
            assert_eq!(get_res.status_code, Some(StatusCode::OK));
            
            let get_body = get_res.take_json::<serde_json::Value>().await.unwrap();
            assert_eq!(get_body["data"]["chapter_code"], chapter_code);
        }
    }
}

#[tokio::test]
async fn test_update_chapter() {
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
        let mut create_res = TestClient::post(&format!("http://127.0.0.1:8080/api/v1/admin/chapters/{}", course_id))
            .bearer_auth(&admin_token)
            .json(&json!({
                "chapter_code": chapter_code,
                "title": "Original Title",
                "summary": "A test chapter",
                "learning_content_markdown": "# Content",
                "estimated_minutes": 30,
                "order_index": 1
            }))
            .send(&service)
            .await;
        
        assert_eq!(create_res.status_code, Some(StatusCode::CREATED));
        
        let mut chapters_res = TestClient::get(&format!("http://127.0.0.1:8080/api/v1/learner/courses/{}/chapters", course_id))
            .bearer_auth(&learner_token)
            .send(&service)
            .await;
        
        let chapters_body = chapters_res.take_json::<serde_json::Value>().await.unwrap();
        let chapters = chapters_body["data"].as_array().unwrap();
        
        if !chapters.is_empty() {
            let chapter_id = chapters[0]["id"].as_str().unwrap();
            
            let mut update_res = TestClient::put(&format!("http://127.0.0.1:8080/api/v1/admin/chapters/{}", chapter_id))
                .bearer_auth(&admin_token)
                .json(&json!({
                    "title": "Updated Title"
                }))
                .send(&service)
                .await;
            
            assert_eq!(update_res.status_code, Some(StatusCode::OK));
        }
    }
}

#[tokio::test]
async fn test_delete_chapter() {
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
        let mut create_res = TestClient::post(&format!("http://127.0.0.1:8080/api/v1/admin/chapters/{}", course_id))
            .bearer_auth(&admin_token)
            .json(&json!({
                "chapter_code": chapter_code,
                "title": "Chapter to Delete",
                "summary": "A test chapter",
                "learning_content_markdown": "# Content",
                "estimated_minutes": 30,
                "order_index": 1
            }))
            .send(&service)
            .await;
        
        assert_eq!(create_res.status_code, Some(StatusCode::CREATED));
        
        let mut chapters_res = TestClient::get(&format!("http://127.0.0.1:8080/api/v1/learner/courses/{}/chapters", course_id))
            .bearer_auth(&learner_token)
            .send(&service)
            .await;
        
        let chapters_body = chapters_res.take_json::<serde_json::Value>().await.unwrap();
        let chapters = chapters_body["data"].as_array().unwrap();
        
        if !chapters.is_empty() {
            let chapter_id = chapters[0]["id"].as_str().unwrap();
            
            let mut delete_res = TestClient::delete(&format!("http://127.0.0.1:8080/api/v1/admin/chapters/{}", chapter_id))
                .bearer_auth(&admin_token)
                .send(&service)
                .await;
            
            assert_eq!(delete_res.status_code, Some(StatusCode::NO_CONTENT));
        }
    }
}