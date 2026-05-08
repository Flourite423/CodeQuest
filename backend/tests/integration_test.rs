use salvo::prelude::*;
use salvo::test::{ResponseExt, TestClient};
mod common;

use common::{create_test_service, setup_test_db};

#[tokio::test]
async fn test_health_check() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let mut res = TestClient::get("http://127.0.0.1:8080/api/v1/health")
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::OK));
    
    let body = res.take_json::<serde_json::Value>().await.unwrap();
    assert_eq!(body["data"]["status"], "healthy");
    assert_eq!(body["data"]["service"], "learning-app-backend");
}

#[tokio::test]
async fn test_not_found() {
    let pool = setup_test_db().await;
    let service = create_test_service(pool);
    
    let res = TestClient::get("http://127.0.0.1:8080/api/v1/nonexistent")
        .send(&service)
        .await;
    
    assert_eq!(res.status_code, Some(StatusCode::NOT_FOUND));
}
