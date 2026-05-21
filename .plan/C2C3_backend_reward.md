# 任务 C2 + C3: Backend XP/等级自动计算 + 排行榜实时更新

## 背景
- 提交通过后没有自动计算 XP 和更新等级
- 排行榜依赖 `leaderboard_snapshots` 表，没有实时更新机制

## 目标
1. 提交/挑战完成后自动计算 XP、更新等级、发放徽章（C2）
2. 排行榜数据在关键事件后刷新（C3）

## 修改文件

### C2: 新建 `backend/src/services/xp_service.rs`

```rust
use sqlx::PgPool;
use uuid::Uuid;

pub struct XpService;

impl XpService {
    /// 提交通过后奖励 XP
    pub async fn reward_submission_xp(
        pool: &PgPool,
        learner_id: Uuid,
        exercise_id: Uuid,
        score: i32,
    ) -> Result<(), sqlx::Error> {
        let xp_amount = Self::calculate_xp(score);
        
        // 1. 写入 XP 流水
        sqlx::query(
            "INSERT INTO xp_ledgers (id, learner_id, source_type, source_id, xp_amount, description) 
             VALUES ($1, $2, 'exercise', $3, $4, '练习通过奖励')"
        )
        .bind(Uuid::new_v4())
        .bind(learner_id)
        .bind(exercise_id)
        .bind(xp_amount)
        .execute(pool)
        .await?;
        
        // 2. 更新学习者总 XP
        sqlx::query(
            "UPDATE learner_profiles 
             SET total_xp = total_xp + $2, updated_at = NOW() 
             WHERE id = $1"
        )
        .bind(learner_id)
        .bind(xp_amount)
        .execute(pool)
        .await?;
        
        // 3. 检查并更新等级
        Self::check_level_up(pool, learner_id).await?;
        
        Ok(())
    }
    
    /// 挑战完成后奖励 XP
    pub async fn reward_challenge_xp(
        pool: &PgPool,
        learner_id: Uuid,
        challenge_id: Uuid,
        stars: i32,
    ) -> Result<(), sqlx::Error> {
        let xp_amount = stars * 50; // 每星 50 XP
        
        sqlx::query(
            "INSERT INTO xp_ledgers (id, learner_id, source_type, source_id, xp_amount, description) 
             VALUES ($1, $2, 'challenge', $3, $4, '挑战完成奖励')"
        )
        .bind(Uuid::new_v4())
        .bind(learner_id)
        .bind(challenge_id)
        .bind(xp_amount)
        .execute(pool)
        .await?;
        
        sqlx::query(
            "UPDATE learner_profiles SET total_xp = total_xp + $2, updated_at = NOW() WHERE id = $1"
        )
        .bind(learner_id)
        .bind(xp_amount)
        .execute(pool)
        .await?;
        
        Self::check_level_up(pool, learner_id).await?;
        
        Ok(())
    }
    
    /// 检查是否升级
    async fn check_level_up(pool: &PgPool, learner_id: Uuid) -> Result<(), sqlx::Error> {
        let profile = sqlx::query_as::<_, (i32, i32)>(
            "SELECT total_xp, level FROM learner_profiles WHERE id = $1"
        )
        .bind(learner_id)
        .fetch_one(pool)
        .await?;
        
        let (total_xp, current_level) = profile;
        let new_level = Self::xp_to_level(total_xp);
        
        if new_level > current_level {
            sqlx::query(
                "UPDATE learner_profiles SET level = $2, updated_at = NOW() WHERE id = $1"
            )
            .bind(learner_id)
            .bind(new_level)
            .execute(pool)
            .await?;
            
            // 可在此触发等级提升徽章检查
        }
        
        Ok(())
    }
    
    fn calculate_xp(score: i32) -> i32 {
        // 得分越高 XP 越多
        (score as f32 * 0.5) as i32 + 10
    }
    
    fn xp_to_level(total_xp: i32) -> i32 {
        // 简单公式：每 100 XP 升 1 级
        (total_xp / 100) + 1
    }
}
```

### 修改 `backend/src/services/mod.rs`

添加 `pub mod xp_service;`

### 修改 `backend/src/handlers/submission.rs`

在判题完成后调用 XP 奖励（结合 A2 的判题系统）：

```rust
use crate::services::xp_service::XpService;

// 在判题成功且 status == "passed" 后：
if result.status.as_str() == "passed" {
    let pool_for_xp = pool.clone();
    let learner_id_for_xp = learner_id; // 需要保留
    let exercise_id_for_xp = Uuid::parse_str(&body.exercise_id).unwrap_or_default();
    tokio::spawn(async move {
        let _ = XpService::reward_submission_xp(
            &pool_for_xp,
            learner_id_for_xp,
            exercise_id_for_xp,
            result.score,
        ).await;
    });
}
```

注意：需要确保 `learner_id` 在创建提交时可用。

### C3: 修改 `backend/src/handlers/leaderboard.rs`

当前排行榜查询 `leaderboard_snapshots` 表。改为实时查询：

```rust
// 全球排行榜：直接查询 learner_profiles 按 total_xp 排序
#[handler]
pub async fn get_global_leaderboard(depot: &mut Depot) -> Result<Json<ApiResponse<Vec<LeaderboardEntry>>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    
    let entries = sqlx::query_as::<_, LeaderboardEntry>(
        "SELECT 
            p.id as learner_id,
            p.display_name as learner_name,
            p.total_xp as score,
            p.level,
            RANK() OVER (ORDER BY p.total_xp DESC) as rank
         FROM learner_profiles p
         WHERE p.account_status = 'active'
         ORDER BY p.total_xp DESC
         LIMIT 100"
    )
    .fetch_all(pool)
    .await
    .map_err(|_| StatusError::internal_server_error())?;
    
    Ok(Json(ApiResponse::new(entries)))
}
```

好友排行榜需要关联 `friendships` 表：
```rust
"SELECT 
    p.id as learner_id,
    p.display_name as learner_name,
    p.total_xp as score,
    p.level,
    RANK() OVER (ORDER BY p.total_xp DESC) as rank
 FROM learner_profiles p
 INNER JOIN friendships f ON (f.requester_id = $1 AND f.recipient_id = p.id)
    OR (f.recipient_id = $1 AND f.requester_id = p.id)
 WHERE f.status = 'accepted' AND p.account_status = 'active'
 ORDER BY p.total_xp DESC
 LIMIT 100"
```

### 修改 `backend/src/models.rs`（如需）

确保 `LeaderboardEntry` 模型包含需要的字段。

## 测试验证
- [ ] 提交通过后 `learner_profiles.total_xp` 增加
- [ ] XP 达到阈值后 `level` 自动提升
- [ ] `xp_ledgers` 表有新记录
- [ ] 排行榜数据实时反映最新 XP
- [ ] 好友排行榜只显示已接受的好友

## 注意
- XP 计算逻辑保持简单可调整
- 奖励发放使用 `tokio::spawn` 不阻塞响应
- 排行榜查询添加适当的索引（如 `learner_profiles(total_xp DESC)`）
