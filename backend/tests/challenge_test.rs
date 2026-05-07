use salvo::prelude::*;
use salvo::test::{ResponseExt, TestClient};
use serde_json::json;
mod common;

use common::{create_test_service, setup_test_db};

#[tokio::test]
async fn test_list_challenges() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/challenges")
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    assert!(body["data"].is_array());
}

#[tokio::test]
async fn test_create_and_get_challenge() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut create_res = TestClient::post("http://127.0.0.1:8080/api/v1/admin/challenges")
        .json(&json!({
            "challenge_code": "CHAL-001",
            "title": "Test Challenge",
            "summary": "A test challenge",
            "difficulty": "easy",
            "reward_xp": 100
        }))
        .send(&service)
        .await;
    
    assert_eq!(create_res.status_code, Some(StatusCode::CREATED));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/challenges")
        .send(&service)
        .await;
    
    let body = list_res.take_json::<serde_json::Value>().await.unwrap();
    let challenges = body["data"].as_array().unwrap();
    
    if !challenges.is_empty() {
        let challenge_id = challenges[0]["id"].as_str().unwrap();
        
        let mut get_res = TestClient::get(&format!("http://127.0.0.1:8080/api/v1/learner/challenges/{}", challenge_id))
            .send(&service)
            .await;
        
        assert_eq!(get_res.status_code, Some(StatusCode::OK));
        
        let get_body = get_res.take_json::<serde_json::Value>().await.unwrap();
        assert_eq!(get_body["data"]["challenge_code"], "CHAL-001");
    }
}

#[tokio::test]
async fn test_get_challenge_not_found() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/challenges/550e8400-e29b-41d4-a716-446655440000")
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::NOT_FOUND));
}

#[tokio::test]
async fn test_update_challenge() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut create_res = TestClient::post("http://127.0.0.1:8080/api/v1/admin/challenges")
        .json(&json!({
            "challenge_code": "CHAL-002",
            "title": "Original Title",
            "summary": "A test challenge",
            "difficulty": "easy",
            "reward_xp": 100
        }))
        .send(&service)
        .await;
    
    assert_eq!(create_res.status_code, Some(StatusCode::CREATED));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/challenges")
        .send(&service)
        .await;
    
    assert_eq!(create_res.status_code, Some(StatusCode::CREATED));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/challenges")
        .send(&service)
        .await;
    
    let body = list_res.take_json::<serde_json::Value>().await.unwrap();
    let challenges = body["data"].as_array().unwrap();
    
    if !challenges.is_empty() {
        let challenge_id = challenges[0]["id"].as_str().unwrap();
        
        let mut update_res = TestClient::put(&format!("http://127.0.0.1:8080/api/v1/admin/challenges/{}", challenge_id))
            .json(&json!({
                "title": "Updated Challenge"
            }))
            .send(&service)
            .await;
        
        assert_eq!(update_res.status_code, Some(StatusCode::OK));
    }
}

#[tokio::test]
async fn test_delete_challenge() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut create_res = TestClient::post("http://127.0.0.1:8080/api/v1/challenges")
        .json(&json!({
            "challenge_code": "CHAL-003",
            "title": "Challenge to Delete",
            "summary": "A test challenge",
            "difficulty": "easy",
            "reward_xp": 100
        }))
        .send(&service)
        .await;
    
    assert_eq!(create_res.status_code, Some(StatusCode::CREATED));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/challenges")
        .send(&service)
        .await;
    
    let body = list_res.take_json::<serde_json::Value>().await.unwrap();
    let challenges = body["data"].as_array().unwrap();
    
    if !challenges.is_empty() {
        let challenge_id = challenges[0]["id"].as_str().unwrap();
        
        let mut delete_res = TestClient::delete(&format!("http://127.0.0.1:8080/api/v1/admin/challenges/{}", challenge_id))
            .send(&service)
            .await;
        
        assert_eq!(delete_res.status_code, Some(StatusCode::NO_CONTENT));
    }
}

#[tokio::test]
async fn test_create_challenge_with_course() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut course_res = TestClient::post("http://127.0.0.1:8080/api/v1/admin/courses")
        .json(&json!({
            "course_code": "COURSE-FOR-CHAL",
            "title": "Course for Challenge",
            "summary": "A test course",
            "difficulty": "beginner",
            "estimated_minutes": 60
        }))
        .send(&service)
        .await;
    
    assert_eq!(course_res.status_code, Some(StatusCode::CREATED));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/courses")
        .send(&service)
        .await;
    
    let body = list_res.take_json::<serde_json::Value>().await.unwrap();
    let courses = body["data"].as_array().unwrap();
    
    if !courses.is_empty() {
        let course_id = courses[0]["id"].as_str().unwrap();
        
            let mut challenge_res = TestClient::post("http://127.0.0.1:8080/api/v1/admin/challenges")
            .json(&json!({
                "challenge_code": "CHAL-WITH-COURSE",
                "title": "Challenge with Course",
                "summary": "A test challenge",
                "related_course_id": course_id,
                "difficulty": "medium",
                "reward_xp": 200
            }))
            .send(&service)
            .await;
        
        assert_eq!(challenge_res.status_code, Some(StatusCode::CREATED));
    }
}
