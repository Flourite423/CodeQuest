use salvo::prelude::*;
use salvo::test::{ResponseExt, TestClient};
use serde_json::json;
mod common;

use common::{create_test_service, get_admin_token, get_auth_token, setup_test_db};

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
    assert!(body["data"]["items"].is_array());
}

#[tokio::test]
async fn test_create_user_via_auth() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let admin_token = get_admin_token(&service).await;
    
    let register_res = TestClient::post("http://127.0.0.1:8080/api/v1/auth/register")
        .json(&json!({
            "email": "test_user@example.com",
            "password": "Password123",
            "nickname": "TestUser",
            "device_id": "test-device",
            "platform": "web"
        }))
        .send(&service)
        .await;
    
    assert_eq!(register_res.status_code, Some(StatusCode::CREATED));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/admin/users")
        .bearer_auth(&admin_token)
        .send(&service)
        .await;
    
    let body = list_res.take_json::<serde_json::Value>().await.unwrap();
    let users = body["data"]["items"].as_array().unwrap();
    
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
    
    let res = TestClient::get("http://127.0.0.1:8080/api/v1/admin/users/550e8400-e29b-41d4-a716-446655440000")
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
    
    let register_res = TestClient::post("http://127.0.0.1:8080/api/v1/auth/register")
        .json(&json!({
            "email": "test_update@example.com",
            "password": "Password123",
            "nickname": "TestUpdate",
            "device_id": "test-device",
            "platform": "web"
        }))
        .send(&service)
        .await;
    
    assert_eq!(register_res.status_code, Some(StatusCode::CREATED));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/admin/users")
        .bearer_auth(&admin_token)
        .send(&service)
        .await;
    
    let body = list_res.take_json::<serde_json::Value>().await.unwrap();
    let users = body["data"]["items"].as_array().unwrap();
    
    if !users.is_empty() {
        let user_id = users[0]["id"].as_str().unwrap();
        
        let update_res = TestClient::put(&format!("http://127.0.0.1:8080/api/v1/admin/users/{}", user_id))
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
    
    let register_res = TestClient::post("http://127.0.0.1:8080/api/v1/auth/register")
        .json(&json!({
            "email": "test_delete@example.com",
            "password": "Password123",
            "nickname": "TestDelete",
            "device_id": "test-device",
            "platform": "web"
        }))
        .send(&service)
        .await;
    
    assert_eq!(register_res.status_code, Some(StatusCode::CREATED));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/admin/users")
        .bearer_auth(&admin_token)
        .send(&service)
        .await;
    
    let body = list_res.take_json::<serde_json::Value>().await.unwrap();
    let users = body["data"]["items"].as_array().unwrap();
    
    if !users.is_empty() {
        let user_id = users[0]["id"].as_str().unwrap();
        
        let delete_res = TestClient::delete(&format!("http://127.0.0.1:8080/api/v1/admin/users/{}", user_id))
            .bearer_auth(&admin_token)
            .send(&service)
            .await;
        
        assert_eq!(delete_res.status_code, Some(StatusCode::NO_CONTENT));
        
        let get_res = TestClient::get(&format!("http://127.0.0.1:8080/api/v1/admin/users/{}", user_id))
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
    
    let register_res = TestClient::post("http://127.0.0.1:8080/api/v1/auth/register")
        .json(&json!({
            "email": "test_invalid@example.com",
            "password": "Password123",
            "nickname": "TestInvalid",
            "device_id": "test-device",
            "platform": "web"
        }))
        .send(&service)
        .await;
    
    assert_eq!(register_res.status_code, Some(StatusCode::CREATED));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/admin/users")
        .bearer_auth(&admin_token)
        .send(&service)
        .await;
    
    let body = list_res.take_json::<serde_json::Value>().await.unwrap();
    let users = body["data"]["items"].as_array().unwrap();
    
    if !users.is_empty() {
        let user_id = users[0]["id"].as_str().unwrap();
        
        let res = TestClient::put(&format!("http://127.0.0.1:8080/api/v1/admin/users/{}", user_id))
            .bearer_auth(&admin_token)
            .json(&json!({
                "invalid_field": "value"
            }))
            .send(&service)
            .await;
        
        assert_eq!(res.status_code, Some(StatusCode::OK));
    }
}

#[tokio::test]
async fn test_login_nonexistent_user_returns_401() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let login_res = TestClient::post("http://127.0.0.1:8080/api/v1/auth/learner/login")
        .json(&json!({
            "email": "nonexistent@example.com",
            "password": "Password123"
        }))
        .send(&service)
        .await;
    
    assert_eq!(login_res.status_code, Some(StatusCode::UNAUTHORIZED));
}

#[tokio::test]
async fn test_admin_login_nonexistent_returns_401() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let login_res = TestClient::post("http://127.0.0.1:8080/api/v1/auth/admin/login")
        .json(&json!({
            "email": "nonexistent@example.com",
            "password": "Password123"
        }))
        .send(&service)
        .await;
    
    assert_eq!(login_res.status_code, Some(StatusCode::UNAUTHORIZED));
}

#[tokio::test]
async fn test_user_response_excludes_password_hash() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let admin_token = get_admin_token(&service).await;
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/admin/users")
        .bearer_auth(&admin_token)
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    let users = body["data"]["items"].as_array().unwrap();
    
    if !users.is_empty() {
        let user = &users[0];
        assert!(user.get("password_hash").is_none(), "password_hash should not be exposed in API response");
    }
}

#[tokio::test]
async fn test_me_endpoint_excludes_password_hash() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let admin_token = get_admin_token(&service).await;
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/me")
        .bearer_auth(&admin_token)
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    assert!(body["data"].get("password_hash").is_none(), "password_hash should not be exposed in /me response");
}

#[tokio::test]
async fn test_learner_cannot_access_admin_endpoints() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    let learner_token = get_auth_token(&service).await;
    
    let res = TestClient::get("http://127.0.0.1:8080/api/v1/admin/users")
        .bearer_auth(&learner_token)
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::FORBIDDEN));
}

#[tokio::test]
async fn test_unauthenticated_access_to_protected_endpoints() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let res = TestClient::get("http://127.0.0.1:8080/api/v1/learner/courses")
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::UNAUTHORIZED));
}