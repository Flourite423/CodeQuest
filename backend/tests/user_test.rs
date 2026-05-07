use salvo::prelude::*;
use salvo::test::{ResponseExt, TestClient};
use serde_json::json;
mod common;

use common::{create_test_service, get_auth_token, get_admin_token, setup_test_db};

#[tokio::test]
async fn test_list_users() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let admin_token = get_admin_token(&service).await;
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/admin/users")
        .bearer_auth(&admin_token)
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    assert!(body["data"].is_array());
}

#[tokio::test]
async fn test_create_user_via_auth() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let admin_token = get_admin_token(&service).await;
    
    let mut login_res = TestClient::post("http://127.0.0.1:8080/api/v1/auth/learner/login")
        .json(&json!({
            "email": "test_user@example.com",
            "password": "password123"
        }))
        .send(&service)
        .await;
    
    assert_eq!(login_res.status_code, Some(StatusCode::OK));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/admin/users")
        .bearer_auth(&admin_token)
        .send(&service)
        .await;
    
    let body = list_res.take_json::<serde_json::Value>().await.unwrap();
    let users = body["data"].as_array().unwrap();
    
    assert!(!users.is_empty());
    
    let user_id = users[0]["id"].as_str().unwrap();
    
    let mut get_res = TestClient::get(&format!("http://127.0.0.1:8080/api/v1/admin/users/{}", user_id))
        .bearer_auth(&admin_token)
        .send(&service)
        .await;
    
    assert_eq!(get_res.status_code, Some(StatusCode::OK));
    
    let get_body = get_res.take_json::<serde_json::Value>().await.unwrap();
    assert_eq!(get_body["data"]["email"], "test_user@example.com");
}

#[tokio::test]
async fn test_get_user_not_found() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let admin_token = get_admin_token(&service).await;
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/admin/users/550e8400-e29b-41d4-a716-446655440000")
        .bearer_auth(&admin_token)
        .send(&service)
        .await;
    
    assert!(res.status_code == Some(StatusCode::NOT_FOUND) || res.status_code == Some(StatusCode::BAD_REQUEST));
}

#[tokio::test]
async fn test_update_user() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let admin_token = get_admin_token(&service).await;
    
    let mut login_res = TestClient::post("http://127.0.0.1:8080/api/v1/auth/learner/login")
        .json(&json!({
            "email": "test_update@example.com",
            "password": "password123"
        }))
        .send(&service)
        .await;
    
    assert_eq!(login_res.status_code, Some(StatusCode::OK));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/admin/users")
        .bearer_auth(&admin_token)
        .send(&service)
        .await;
    
    let body = list_res.take_json::<serde_json::Value>().await.unwrap();
    let users = body["data"].as_array().unwrap();
    
    if !users.is_empty() {
        let user_id = users[0]["id"].as_str().unwrap();
        
        let mut update_res = TestClient::put(&format!("http://127.0.0.1:8080/api/v1/admin/users/{}", user_id))
            .bearer_auth(&admin_token)
            .json(&json!({
                "account_status": "suspended"
            }))
            .send(&service)
            .await;
        
        assert_eq!(update_res.status_code, Some(StatusCode::OK));
    }
}

#[tokio::test]
async fn test_delete_user() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let admin_token = get_admin_token(&service).await;
    
    let mut login_res = TestClient::post("http://127.0.0.1:8080/api/v1/auth/learner/login")
        .json(&json!({
            "email": "test_delete@example.com",
            "password": "password123"
        }))
        .send(&service)
        .await;
    
    assert_eq!(login_res.status_code, Some(StatusCode::OK));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/admin/users")
        .bearer_auth(&admin_token)
        .send(&service)
        .await;
    
    let body = list_res.take_json::<serde_json::Value>().await.unwrap();
    let users = body["data"].as_array().unwrap();
    
    if !users.is_empty() {
        let user_id = users[0]["id"].as_str().unwrap();
        
        let mut delete_res = TestClient::delete(&format!("http://127.0.0.1:8080/api/v1/admin/users/{}", user_id))
            .bearer_auth(&admin_token)
            .send(&service)
            .await;
        
        assert_eq!(delete_res.status_code, Some(StatusCode::NO_CONTENT));
        
        let mut get_res = TestClient::get(&format!("http://127.0.0.1:8080/api/v1/admin/users/{}", user_id))
            .bearer_auth(&admin_token)
            .send(&service)
            .await;
        
        assert_eq!(get_res.status_code, Some(StatusCode::NOT_FOUND));
    }
}

#[tokio::test]
async fn test_update_user_invalid_body() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let admin_token = get_admin_token(&service).await;
    
    let mut login_res = TestClient::post("http://127.0.0.1:8080/api/v1/auth/learner/login")
        .json(&json!({
            "email": "test_invalid@example.com",
            "password": "password123"
        }))
        .send(&service)
        .await;
    
    assert_eq!(login_res.status_code, Some(StatusCode::OK));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/admin/users")
        .bearer_auth(&admin_token)
        .send(&service)
        .await;
    
    let body = list_res.take_json::<serde_json::Value>().await.unwrap();
    let users = body["data"].as_array().unwrap();
    
    if !users.is_empty() {
        let user_id = users[0]["id"].as_str().unwrap();
        
        let mut res = TestClient::put(&format!("http://127.0.0.1:8080/api/v1/admin/users/{}", user_id))
            .bearer_auth(&admin_token)
            .json(&json!({
                "invalid_field": "value"
            }))
            .send(&service)
            .await;
        
        assert_eq!(res.status_code, Some(StatusCode::OK));
    }
}