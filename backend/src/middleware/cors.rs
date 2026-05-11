use salvo::cors::{AllowOrigin, Cors};
use salvo::http::{HeaderValue, Method};
use salvo::prelude::*;

pub fn dev_cors() -> impl Handler {
    Cors::new()
        .allow_origin(AllowOrigin::dynamic(|origin, _req, _depot| {
            let origin = origin?.to_str().ok()?;
            let is_local = origin.starts_with("http://localhost:")
                || origin.starts_with("http://127.0.0.1:")
                || origin.starts_with("https://localhost:")
                || origin.starts_with("https://127.0.0.1:");

            if is_local {
                HeaderValue::from_str(origin).ok()
            } else {
                None
            }
        }))
        .allow_methods(vec![
            Method::GET,
            Method::POST,
            Method::PUT,
            Method::PATCH,
            Method::DELETE,
            Method::OPTIONS,
        ])
        .allow_headers(vec!["authorization", "content-type"])
        .max_age(3600)
        .into_handler()
}
