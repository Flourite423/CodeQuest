use salvo::prelude::*;
use salvo::test::{ResponseExt, TestClient};
mod common;

use common::{create_test_service, get_auth_token, setup_test_db};

#[tokio::test]
async fn test_get_global_leaderboard() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let token = get_auth_token(&service).await;
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/leaderboards")
        .bearer_auth(&token)
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    assert!(body["data"]["items"].is_array());
}

#[tokio::test]
async fn test_get_friends_leaderboard() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let token = get_auth_token(&service).await;
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/leaderboards/friends")
        .bearer_auth(&token)
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    assert!(body["data"]["items"].is_array());
}

#[tokio::test]
async fn test_get_course_leaderboard() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let token = get_auth_token(&service).await;
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/leaderboards/courses/00000000-0000-0000-0000-000000000000")
        .bearer_auth(&token)
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    assert!(body["data"]["items"].is_array());
}