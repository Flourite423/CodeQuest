use salvo::prelude::*;
use salvo::affix_state;
use tracing::info;

mod config;
mod db;
mod handlers;
mod middleware;
mod models;
mod routes;
mod services;

use config::AppConfig;

#[handler]
async fn serve_openapi(res: &mut Response) {
    let manifest_dir = env!("CARGO_MANIFEST_DIR");
    let openapi_path = std::path::Path::new(manifest_dir).join("../contracts/openapi/openapi.yaml");
    match tokio::fs::read_to_string(openapi_path).await {
        Ok(content) => {
            res.add_header("content-type", "application/yaml", true).unwrap();
            res.write_body(content).unwrap();
        }
        Err(e) => {
            res.status_code(StatusCode::INTERNAL_SERVER_ERROR);
            res.render(format!("Failed to read openapi.yaml: {}", e));
        }
    }
}

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::EnvFilter::from_default_env())
        .init();

    let cfg = AppConfig::from_env().expect("Failed to load configuration");
    let server_addr = cfg.server_addr.clone();
    info!("Starting Learning App Backend on {}", server_addr);

    let pool = db::create_pool(&cfg.database_url)
        .await
        .expect("Failed to create database pool");

    if cfg.auto_run_migrations {
        db::run_migrations(&pool)
            .await
            .expect("Failed to run database migrations");
        info!("Database migrations completed");
    }

    if cfg.seed_dev_accounts {
        db::seed_dev_accounts(&pool)
            .await
            .expect("Failed to seed development accounts");
        info!("Development accounts are ready");
    }
    
    info!("Database connected successfully");

    let router = routes::create_router()
        .hoop(middleware::cors::dev_cors())
        .hoop(affix_state::inject(pool))
        .hoop(affix_state::inject(cfg))
        .hoop(middleware::logging::request_logger);

    let router = router
        .unshift(Router::with_path("api-doc/openapi.yaml").get(serve_openapi))
        .unshift(SwaggerUi::new("/api-doc/openapi.yaml").into_router("/swagger-ui"));

    let acceptor = TcpListener::new(server_addr).bind().await;
    info!("Server listening");
    Server::new(acceptor).serve(router).await;
}
