use salvo::prelude::*;
use tracing::info;
use std::time::Instant;

#[handler]
pub async fn request_logger(req: &mut Request, depot: &mut Depot, res: &mut Response, ctrl: &mut FlowCtrl) {
    let method = req.method().to_string();
    let path = req.uri().path().to_string();
    let request_id = uuid::Uuid::new_v4().to_string();
    let start = Instant::now();

    info!(request_id = %request_id, method = %method, path = %path, "Incoming request");

    depot.insert("request_id", request_id.clone());

    ctrl.call_next(req, depot, res).await;

    let duration_ms = start.elapsed().as_millis() as u64;
    let status = res.status_code.unwrap_or(StatusCode::OK);

    info!(
        request_id = %request_id,
        method = %method,
        path = %path,
        status = %status.as_u16(),
        duration_ms = %duration_ms,
        "Request completed"
    );
}
