use salvo::prelude::*;
use serde::{Deserialize, Serialize};
use sqlx::PgPool;
use crate::models::{ApiResponse, ApiError};

#[derive(Debug, Deserialize)]
pub struct LoginRequest {
    pub phone: String,
    pub verification_code: String,
}

#[derive(Debug, Serialize)]
pub struct LoginResponse {
    pub token: String,
    pub expires_in: i64,
}

#[handler]
pub async fn login(req: &mut Request, depot: &mut Depot) -> Result<Json<ApiResponse<LoginResponse>>, StatusError> {
    let _body: LoginRequest = req.parse_json().await
        .map_err(|_| StatusError::bad_request())?;
    
    Ok(Json(ApiResponse::new(LoginResponse {
        token: "mock_jwt_token".to_string(),
        expires_in: 86400,
    })))
}

#[handler]
pub async fn logout() -> Result<StatusCode, StatusError> {
    Ok(StatusCode::OK)
}

#[handler]
pub async fn refresh_token() -> Result<Json<ApiResponse<LoginResponse>>, StatusError> {
    Ok(Json(ApiResponse::new(LoginResponse {
        token: "mock_refreshed_token".to_string(),
        expires_in: 86400,
    })))
}
