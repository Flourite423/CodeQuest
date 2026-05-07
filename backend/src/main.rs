use salvo::prelude::*;
use salvo::affix_state;
use salvo::oapi::{OpenApi, Info, Contact, License};
use tracing::info;

mod config;
mod db;
mod handlers;
mod middleware;
mod models;
mod routes;
mod services;

use config::AppConfig;

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
    
    info!("Database connected successfully");

    let router = routes::create_router()
        .hoop(affix_state::inject(pool))
        .hoop(affix_state::inject(cfg))
        .hoop(middleware::logging::request_logger);

    let doc = OpenApi::new("Learning App API", "1.0.0")
        .info(
            Info::new("Learning App API", "1.0.0")
                .description("A comprehensive learning application API with courses, challenges, exercises, and gamification features")
                .contact(Contact::new().name("API Support").email("support@learningapp.com"))
                .license(License::new("MIT")),
        )
        .merge_router(&router);

    let router = router
        .unshift(doc.into_router("/api-doc/openapi.json"))
        .unshift(SwaggerUi::new("/api-doc/openapi.json").into_router("/swagger-ui"));

    let acceptor = TcpListener::new(server_addr).bind().await;
    info!("Server listening");
    Server::new(acceptor).serve(router).await;
}
