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

    let acceptor = TcpListener::new(server_addr).bind().await;
    info!("Server listening");
    Server::new(acceptor).serve(router).await;
}
