-- Performance optimization indexes
-- Add composite indexes for common query patterns

-- Friend relations: optimize bidirectional lookups
CREATE INDEX IF NOT EXISTS idx_friends_bidirectional ON friend_relations(requester_id, addressee_id);

-- Social activities: optimize learner feed queries with time sorting
CREATE INDEX IF NOT EXISTS idx_activities_learner_created ON social_activities(learner_id, created_at DESC);

-- Challenge attempts: optimize learner progress lookups
CREATE INDEX IF NOT EXISTS idx_challenge_attempts_learner_challenge ON challenge_attempts(learner_id, challenge_id);

-- Daily challenge records: optimize learner completion lookups  
CREATE INDEX IF NOT EXISTS idx_daily_records_learner_challenge ON daily_challenge_records(learner_id, daily_challenge_id);

-- Submissions: optimize exercise + learner lookups
CREATE INDEX IF NOT EXISTS idx_submissions_exercise_learner ON submissions(exercise_id, learner_id);

-- Courses: optimize published course listings with sort order
CREATE INDEX IF NOT EXISTS idx_courses_published_sort ON courses(status, sort_order) WHERE status = 'published';

-- Accounts: optimize role-based lookups
CREATE INDEX IF NOT EXISTS idx_accounts_role_status ON accounts(default_role, account_status);
