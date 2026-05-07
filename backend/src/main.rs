use salvo::prelude::*;
use salvo::affix_state;
use sqlx::PgPool;
use tracing::info;

mod config;
mod db;
mod handlers;
mod middleware;
mod models;
mod routes;

use config::AppConfig;

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::EnvFilter::from_default_env())
        .init();

    let cfg = AppConfig::from_env().expect("Failed to load configuration");
    info!("Starting Learning App Backend on {}", cfg.server_addr);

    let pool = db::create_pool(&cfg.database_url)
        .await
        .expect("Failed to create database pool");

    let router = routes::create_router()
        .hoop(affix_state::inject(pool))
        .hoop(middleware::logging::request_logger());

    let acceptor = TcpListener::new(&cfg.server_addr).bind().await;
    Server::new(acceptor).serve(router).await;
}
