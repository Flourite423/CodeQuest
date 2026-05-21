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

        // 1. 获取当前 XP 余额
        let current: (i32,) = sqlx::query_as(
            "SELECT total_xp FROM learner_profiles WHERE account_id = $1",
        )
        .bind(learner_id)
        .fetch_one(pool)
        .await?;

        let balance_after = current.0 + xp_amount;

        // 2. 写入 XP 流水
        sqlx::query(
            "INSERT INTO xp_ledger (learner_id, source_type, source_id, delta_xp, balance_after)
             VALUES ($1, 'exercise', $2, $3, $4)",
        )
        .bind(learner_id)
        .bind(exercise_id)
        .bind(xp_amount)
        .bind(balance_after)
        .execute(pool)
        .await?;

        // 3. 更新 learner_profiles.total_xp
        sqlx::query(
            "UPDATE learner_profiles
             SET total_xp = total_xp + $2, updated_at = NOW()
             WHERE account_id = $1",
        )
        .bind(learner_id)
        .bind(xp_amount)
        .execute(pool)
        .await?;

        // 4. 检查并更新等级
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
        let xp_amount = stars * 50;

        let current: (i32,) = sqlx::query_as(
            "SELECT total_xp FROM learner_profiles WHERE account_id = $1",
        )
        .bind(learner_id)
        .fetch_one(pool)
        .await?;

        let balance_after = current.0 + xp_amount;

        sqlx::query(
            "INSERT INTO xp_ledger (learner_id, source_type, source_id, delta_xp, balance_after)
             VALUES ($1, 'challenge', $2, $3, $4)",
        )
        .bind(learner_id)
        .bind(challenge_id)
        .bind(xp_amount)
        .bind(balance_after)
        .execute(pool)
        .await?;

        sqlx::query(
            "UPDATE learner_profiles
             SET total_xp = total_xp + $2, updated_at = NOW()
             WHERE account_id = $1",
        )
        .bind(learner_id)
        .bind(xp_amount)
        .execute(pool)
        .await?;

        Self::check_level_up(pool, learner_id).await?;

        Ok(())
    }

    /// 每日挑战完成后奖励 XP
    pub async fn reward_daily_challenge_xp(
        pool: &PgPool,
        learner_id: Uuid,
        daily_challenge_id: Uuid,
        reward_xp: i32,
    ) -> Result<(), sqlx::Error> {
        let current: (i32,) = sqlx::query_as(
            "SELECT total_xp FROM learner_profiles WHERE account_id = $1",
        )
        .bind(learner_id)
        .fetch_one(pool)
        .await?;

        let balance_after = current.0 + reward_xp;

        sqlx::query(
            "INSERT INTO xp_ledger (learner_id, source_type, source_id, delta_xp, balance_after)
             VALUES ($1, 'daily', $2, $3, $4)",
        )
        .bind(learner_id)
        .bind(daily_challenge_id)
        .bind(reward_xp)
        .bind(balance_after)
        .execute(pool)
        .await?;

        sqlx::query(
            "UPDATE learner_profiles
             SET total_xp = total_xp + $2, updated_at = NOW()
             WHERE account_id = $1",
        )
        .bind(learner_id)
        .bind(reward_xp)
        .execute(pool)
        .await?;

        Self::check_level_up(pool, learner_id).await?;

        Ok(())
    }

    /// 检查是否升级
    async fn check_level_up(pool: &PgPool, learner_id: Uuid) -> Result<(), sqlx::Error> {
        let (total_xp, current_level): (i32, i32) = sqlx::query_as(
            "SELECT total_xp, current_level FROM learner_profiles WHERE account_id = $1",
        )
        .bind(learner_id)
        .fetch_one(pool)
        .await?;

        let new_level = Self::xp_to_level(total_xp);

        if new_level > current_level {
            sqlx::query(
                "UPDATE learner_profiles
                 SET current_level = $2, updated_at = NOW()
                 WHERE account_id = $1",
            )
            .bind(learner_id)
            .bind(new_level)
            .execute(pool)
            .await?;
        }

        Ok(())
    }

    fn calculate_xp(score: i32) -> i32 {
        (score as f32 * 0.5) as i32 + 10
    }

    fn xp_to_level(total_xp: i32) -> i32 {
        (total_xp / 100) + 1
    }
}
