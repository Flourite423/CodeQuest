use salvo::prelude::*;
use salvo::test::{ResponseExt, TestClient};
use serde_json::json;
mod common;

use common::{create_test_service, get_auth_token, setup_test_db};

#[tokio::test]
async fn test_create_ai_help() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let token = get_auth_token(&service).await;
    
    let mut res = TestClient::post("http://127.0.0.1:8080/api/v1/learner/ai/help")
        .bearer_auth(&token)
        .json(&json!({
            "request_type": "hint",
            "source_code": "fn main() {}"
        }))
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    assert!(body["data"]["id"].as_str().is_some());
    assert_eq!(body["data"]["request_type"], "Hint");
}

#[tokio::test]
async fn test_list_ai_help_history() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let token = get_auth_token(&service).await;
    
    TestClient::post("http://127.0.0.1:8080/api/v1/learner/ai/help")
        .bearer_auth(&token)
        .json(&json!({
            "request_type": "debug",
            "source_code": "fn main() { let x = 1; }"
        }))
        .send(&service)
        .await;
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/ai/help")
        .bearer_auth(&token)
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    assert!(body["data"].is_array());
}