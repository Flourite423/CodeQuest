use salvo::prelude::*;
use salvo::test::{ResponseExt, TestClient};
use serde_json::json;
mod common;

use common::{create_test_service, setup_test_db};

#[tokio::test]
async fn test_list_courses() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/courses")
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    assert!(body["data"].is_array());
}

#[tokio::test]
async fn test_create_and_get_course() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut create_res = TestClient::post("http://127.0.0.1:8080/api/v1/admin/courses")
        .json(&json!({
            "course_code": "TEST-001",
            "title": "Test Course",
            "summary": "A test course",
            "description": "This is a test course description",
            "difficulty": "beginner",
            "estimated_minutes": 60
        }))
        .send(&service)
        .await;
    
    assert_eq!(create_res.status_code, Some(StatusCode::CREATED));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/courses")
        .send(&service)
        .await;
    
    let body = list_res.take_json::<serde_json::Value>().await.unwrap();
    let courses = body["data"].as_array().unwrap();
    
    if !courses.is_empty() {
        let course_id = courses[0]["id"].as_str().unwrap();
        
        let mut get_res = TestClient::get(&format!("http://127.0.0.1:8080/api/v1/learner/courses/{}", course_id))
            .send(&service)
            .await;
        
        assert_eq!(get_res.status_code, Some(StatusCode::OK));
        
        let get_body = get_res.take_json::<serde_json::Value>().await.unwrap();
        assert_eq!(get_body["data"]["course_code"], "TEST-001");
    }
}

#[tokio::test]
async fn test_get_course_not_found() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/courses/550e8400-e29b-41d4-a716-446655440000")
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::NOT_FOUND));
}

#[tokio::test]
async fn test_update_course() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut create_res = TestClient::post("http://127.0.0.1:8080/api/v1/admin/courses")
        .json(&json!({
            "course_code": "TEST-002",
            "title": "Original Title",
            "summary": "A test course",
            "difficulty": "beginner",
            "estimated_minutes": 60
        }))
        .send(&service)
        .await;
    
    assert_eq!(create_res.status_code, Some(StatusCode::CREATED));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/courses")
        .send(&service)
        .await;
    
    let body = list_res.take_json::<serde_json::Value>().await.unwrap();
    let courses = body["data"].as_array().unwrap();
    
    if !courses.is_empty() {
        let course_id = courses[0]["id"].as_str().unwrap();
        
        let mut update_res = TestClient::put(&format!("http://127.0.0.1:8080/api/v1/admin/courses/{}", course_id))
            .json(&json!({
                "title": "Updated Title"
            }))
            .send(&service)
            .await;
        
        assert_eq!(update_res.status_code, Some(StatusCode::OK));
    }
}

#[tokio::test]
async fn test_delete_course() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut create_res = TestClient::post("http://127.0.0.1:8080/api/v1/admin/courses")
        .json(&json!({
            "course_code": "TEST-003",
            "title": "Course to Delete",
            "summary": "A test course",
            "difficulty": "beginner",
            "estimated_minutes": 60
        }))
        .send(&service)
        .await;
    
    assert_eq!(create_res.status_code, Some(StatusCode::CREATED));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/courses")
        .send(&service)
        .await;
    
    let body = list_res.take_json::<serde_json::Value>().await.unwrap();
    let courses = body["data"].as_array().unwrap();
    
    if !courses.is_empty() {
        let course_id = courses[0]["id"].as_str().unwrap();
        
        let mut delete_res = TestClient::delete(&format!("http://127.0.0.1:8080/api/v1/admin/courses/{}", course_id))
            .send(&service)
            .await;
        
        assert_eq!(delete_res.status_code, Some(StatusCode::NO_CONTENT));
    }
}

#[tokio::test]
async fn test_create_course_invalid_body() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut res = TestClient::post("http://127.0.0.1:8080/api/v1/admin/courses")
        .json(&json!({
            "course_code": "TEST-004"
        }))
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::BAD_REQUEST));
}
