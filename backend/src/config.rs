use config::{Config, ConfigError, Environment, File};
use serde::Deserialize;

#[derive(Debug, Deserialize, Clone)]
pub struct AiConfig {
    pub provider: String,
    pub api_key: Option<String>,
    pub model: String,
    pub temperature: f64,
    pub max_tokens: u32,
    pub mock_response: String,
}

#[derive(Debug, Deserialize, Clone)]
pub struct AppConfig {
    pub server_addr: String,
    pub database_url: String,
    pub jwt_secret: String,
    pub jwt_expiration: i64,
    #[serde(default)]
    pub auto_run_migrations: bool,
    #[serde(default)]
    pub seed_dev_accounts: bool,
    pub ai: AiConfig,
}

impl AppConfig {
    pub fn from_env() -> Result<Self, ConfigError> {
        let cfg = Config::builder()
            .add_source(File::with_name("config/default").required(false))
            .add_source(File::with_name("config/local").required(false))
            .add_source(Environment::with_prefix("APP").separator("__"))
            .build()?;

        cfg.try_deserialize()
    }
}
