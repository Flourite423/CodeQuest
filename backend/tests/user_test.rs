use salvo::prelude::*;
use salvo::test::{ResponseExt, TestClient};
use serde_json::json;
mod common;

use common::{create_test_service, setup_test_db};

#[tokio::test]
async fn test_list_users() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/users")
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
    
    let mut login_res = TestClient::post("http://127.0.0.1:8080/api/v1/auth")
        .json(&json!({
            "phone": "13800138001",
            "verification_code": "123456"
        }))
        .send(&service)
        .await;
    
    assert_eq!(login_res.status_code, Some(StatusCode::OK));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/users")
        .send(&service)
        .await;
    
    let body = list_res.take_json::<serde_json::Value>().await.unwrap();
    let users = body["data"].as_array().unwrap();
    
    assert!(!users.is_empty());
    
    let user_id = users[0]["id"].as_str().unwrap();
    
    let mut get_res = TestClient::get(&format!("http://127.0.0.1:8080/api/v1/users/{}", user_id))
        .send(&service)
        .await;
    
    assert_eq!(get_res.status_code, Some(StatusCode::OK));
    
    let get_body = get_res.take_json::<serde_json::Value>().await.unwrap();
    assert_eq!(get_body["data"]["email"], "13800138001");
    assert_eq!(get_body["data"]["default_role"], "learner");
}

#[tokio::test]
async fn test_get_user_not_found() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/users/550e8400-e29b-41d4-a716-446655440000")
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::NOT_FOUND));
}

#[tokio::test]
async fn test_update_user() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut login_res = TestClient::post("http://127.0.0.1:8080/api/v1/auth")
        .json(&json!({
            "phone": "13800138002",
            "verification_code": "123456"
        }))
        .send(&service)
        .await;
    
    assert_eq!(login_res.status_code, Some(StatusCode::OK));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/users")
        .send(&service)
        .await;
    
    let body = list_res.take_json::<serde_json::Value>().await.unwrap();
    let users = body["data"].as_array().unwrap();
    
    if !users.is_empty() {
        let user_id = users[0]["id"].as_str().unwrap();
        
        let mut update_res = TestClient::put(&format!("http://127.0.0.1:8080/api/v1/users/{}", user_id))
            .json(&json!({
                "account_status": "suspended"
            }))
            .send(&service)
            .await;
        
        assert_eq!(update_res.status_code, Some(StatusCode::OK));
        
        let mut get_res = TestClient::get(&format!("http://127.0.0.1:8080/api/v1/users/{}", user_id))
            .send(&service)
            .await;
        
        let get_body = get_res.take_json::<serde_json::Value>().await.unwrap();
        assert_eq!(get_body["data"]["account_status"], "suspended");
    }
}

#[tokio::test]
async fn test_delete_user() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut login_res = TestClient::post("http://127.0.0.1:8080/api/v1/auth")
        .json(&json!({
            "phone": "13800138003",
            "verification_code": "123456"
        }))
        .send(&service)
        .await;
    
    assert_eq!(login_res.status_code, Some(StatusCode::OK));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/users")
        .send(&service)
        .await;
    
    let body = list_res.take_json::<serde_json::Value>().await.unwrap();
    let users = body["data"].as_array().unwrap();
    
    if !users.is_empty() {
        let user_id = users[0]["id"].as_str().unwrap();
        
        let mut delete_res = TestClient::delete(&format!("http://127.0.0.1:8080/api/v1/users/{}", user_id))
            .send(&service)
            .await;
        
        assert_eq!(delete_res.status_code, Some(StatusCode::NO_CONTENT));
        
        let mut get_res = TestClient::get(&format!("http://127.0.0.1:8080/api/v1/users/{}", user_id))
            .send(&service)
            .await;
        
        assert_eq!(get_res.status_code, Some(StatusCode::NOT_FOUND));
    }
}

#[tokio::test]
async fn test_update_user_invalid_body() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut login_res = TestClient::post("http://127.0.0.1:8080/api/v1/auth")
        .json(&json!({
            "phone": "13800138004",
            "verification_code": "123456"
        }))
        .send(&service)
        .await;
    
    assert_eq!(login_res.status_code, Some(StatusCode::OK));
    
    let mut list_res = TestClient::get("http://127.0.0.1:8080/api/v1/users")
        .send(&service)
        .await;
    
    let body = list_res.take_json::<serde_json::Value>().await.unwrap();
    let users = body["data"].as_array().unwrap();
    
    if !users.is_empty() {
        let user_id = users[0]["id"].as_str().unwrap();
        
        let mut res = TestClient::put(&format!("http://127.0.0.1:8080/api/v1/users/{}", user_id))
            .json(&json!({
                "invalid_field": "value"
            }))
            .send(&service)
            .await;
        
        assert_eq!(res.status_code, Some(StatusCode::OK));
    }
}
