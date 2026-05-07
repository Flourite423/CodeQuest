use salvo::prelude::*;
use tracing::info;

#[handler]
pub async fn request_logger(req: &mut Request, depot: &mut Depot, res: &mut Response, ctrl: &mut FlowCtrl) {
    let method = req.method().to_string();
    let path = req.uri().path().to_string();
    let request_id = uuid::Uuid::new_v4().to_string();
    
    info!(request_id = %request_id, method = %method, path = %path, "Incoming request");
    
    depot.insert("request_id", request_id.clone());
    
    ctrl.call_next(req, depot, res).await;
    
    info!(request_id = %request_id, "Request completed");
}
