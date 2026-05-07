use salvo::prelude::*;
use salvo::test::{ResponseExt, TestClient};
mod common;

use common::{create_test_service, get_auth_token, setup_test_db};

#[tokio::test]
async fn test_get_rewards() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let token = get_auth_token(&service).await;
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/rewards")
        .bearer_auth(&token)
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    assert!(body["data"]["total_xp"].is_number());
    assert!(body["data"]["badges"].is_array());
}

#[tokio::test]
async fn test_get_xp_ledger() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let token = get_auth_token(&service).await;
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/rewards/xp")
        .bearer_auth(&token)
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    assert!(body["data"].is_array());
}

#[tokio::test]
async fn test_get_learner_badges() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let token = get_auth_token(&service).await;
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/rewards/badges")
        .bearer_auth(&token)
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    assert!(body["data"].is_array());
}