use salvo::prelude::*;
use salvo::test::{ResponseExt, TestClient};
mod common;

use common::{create_test_service, get_auth_token, setup_test_db};

#[tokio::test]
async fn test_list_friends() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let token = get_auth_token(&service).await;
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/friends")
        .bearer_auth(&token)
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    assert!(body["data"]["items"].is_array());
}

#[tokio::test]
async fn test_list_friend_requests() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let token = get_auth_token(&service).await;
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/friends/requests")
        .bearer_auth(&token)
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    assert!(body["data"].is_array());
}

#[tokio::test]
async fn test_list_social_activities() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let token = get_auth_token(&service).await;
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/activities")
        .bearer_auth(&token)
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    assert!(body["data"]["items"].is_array());
}