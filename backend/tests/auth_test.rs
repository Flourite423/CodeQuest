use salvo::prelude::*;
use salvo::test::{ResponseExt, TestClient};
use serde_json::json;
mod common;

use common::{create_test_service, setup_test_db};

#[tokio::test]
async fn test_auth_login_success() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut res = TestClient::post("http://127.0.0.1:8080/api/v1/auth/learner/login")
        .json(&json!({
            "email": "test@example.com",
            "password": "password123"
        }))
        .send(&service)
        .await;
    
    if res.status_code != Some(StatusCode::OK) {
        let body = res.take_string().await.unwrap_or_default();
        println!("Login failed with status {:?}: {}", res.status_code, body);
    }
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    assert!(body["data"]["access_token"].as_str().is_some());
    assert!(body["data"]["refresh_token"].as_str().is_some());
    assert_eq!(body["data"]["expires_in"], 86400);
    assert_eq!(body["data"]["token_type"], "Bearer");
}

#[tokio::test]
async fn test_auth_login_invalid_body() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let res = TestClient::post("http://127.0.0.1:8080/api/v1/auth/learner/login")
        .json(&json!({
            "email": "test@example.com"
        }))
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::BAD_REQUEST));
}

#[tokio::test]
async fn test_auth_logout() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let res = TestClient::post("http://127.0.0.1:8080/api/v1/auth/logout")
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
}

#[tokio::test]
async fn test_auth_refresh() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut login_res = TestClient::post("http://127.0.0.1:8080/api/v1/auth/learner/login")
        .json(&json!({
            "email": "test@example.com",
            "password": "password123"
        }))
        .send(&service)
        .await;
    
    let login_body = login_res.take_json::<serde_json::Value>().await.unwrap();
    let refresh_token = login_body["data"]["refresh_token"].as_str().unwrap();
    
    let mut res = TestClient::post("http://127.0.0.1:8080/api/v1/auth/refresh")
        .json(&json!({
            "refresh_token": refresh_token
        }))
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    assert!(body["data"]["access_token"].as_str().is_some());
}

#[tokio::test]
async fn test_get_current_user_without_auth() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let res = TestClient::get("http://127.0.0.1:8080/api/v1/me")
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::UNAUTHORIZED));
}

#[tokio::test]
async fn test_get_current_user_with_auth() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut login_res = TestClient::post("http://127.0.0.1:8080/api/v1/auth/learner/login")
        .json(&json!({
            "email": "test@example.com",
            "password": "password123"
        }))
        .send(&service)
        .await;
    
    let login_body = login_res.take_json::<serde_json::Value>().await.unwrap();
    let token = login_body["data"]["access_token"].as_str().unwrap();
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/me")
        .bearer_auth(token)
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    assert!(body["data"]["id"].as_str().is_some());
}
