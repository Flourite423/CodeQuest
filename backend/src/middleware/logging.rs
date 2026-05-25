use salvo::prelude::*;
use tracing::{info, warn, error};
use std::time::Instant;

#[handler]
pub async fn request_logger(req: &mut Request, depot: &mut Depot, res: &mut Response, ctrl: &mut FlowCtrl) {
    let method = req.method().to_string();
    let path = req.uri().path().to_string();
    let query = req.uri().query().map(|q| q.to_string()).unwrap_or_default();
    let request_id = uuid::Uuid::new_v4().to_string();
    let start = Instant::now();

    if query.is_empty() {
        info!(request_id = %request_id, method = %method, path = %path, "→ 收到请求");
    } else {
        info!(request_id = %request_id, method = %method, path = %path, query = %query, "→ 收到请求");
    }

    depot.insert("request_id", request_id.clone());

    ctrl.call_next(req, depot, res).await;

    let duration_ms = start.elapsed().as_millis() as u64;
    let status = res.status_code.unwrap_or(StatusCode::OK);
    let status_u16 = status.as_u16();

    // 根据状态码选择日志级别，便于调试时一眼发现错误
    if status_u16 >= 500 {
        error!(
            request_id = %request_id,
            method = %method,
            path = %path,
            status = %status_u16,
            duration_ms = %duration_ms,
            "✗ 请求处理失败 (Server Error)"
        );
    } else if status_u16 >= 400 {
        warn!(
            request_id = %request_id,
            method = %method,
            path = %path,
            status = %status_u16,
            duration_ms = %duration_ms,
            "⚠ 请求处理异常 (Client Error)"
        );
    } else {
        info!(
            request_id = %request_id,
            method = %method,
            path = %path,
            status = %status_u16,
            duration_ms = %duration_ms,
            "✓ 请求处理完成"
        );
    }
}
