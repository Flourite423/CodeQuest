use salvo::prelude::*;
use salvo::test::{ResponseExt, TestClient};
mod common;

use common::{create_test_service, get_auth_token, setup_test_db};

#[tokio::test]
async fn test_list_progress() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let token = get_auth_token(&service).await;
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/progress")
        .bearer_auth(&token)
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    assert!(body["data"].is_array());
}

#[tokio::test]
async fn test_get_course_progress_not_found() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let token = get_auth_token(&service).await;
    
    let res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/progress/courses/00000000-0000-0000-0000-000000000000")
        .bearer_auth(&token)
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::NOT_FOUND));
}

#[tokio::test]
async fn test_create_progress_invalid_course() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let token = get_auth_token(&service).await;
    
    let res = TestClient::post("http://127.0.0.1:8080/api/v1/learner/progress")
        .bearer_auth(&token)
        .json(&serde_json::json!({
            "course_id": "00000000-0000-0000-0000-000000000000"
        }))
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::INTERNAL_SERVER_ERROR));
}