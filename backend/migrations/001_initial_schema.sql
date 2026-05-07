CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TYPE account_status AS ENUM ('active', 'suspended', 'closed');
CREATE TYPE role_type AS ENUM ('learner', 'admin');
CREATE TYPE role_status AS ENUM ('enabled', 'disabled');

CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    default_role role_type NOT NULL DEFAULT 'learner',
    account_status account_status NOT NULL DEFAULT 'active',
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_accounts_email ON accounts(email);
CREATE INDEX idx_accounts_status ON accounts(account_status);

CREATE TABLE account_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    role role_type NOT NULL,
    role_status role_status NOT NULL DEFAULT 'enabled',
    granted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    revoked_at TIMESTAMPTZ,
    UNIQUE(account_id, role)
);

CREATE INDEX idx_account_roles_account ON account_roles(account_id);

CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    role role_type NOT NULL,
    device_id VARCHAR(255) NOT NULL,
    device_name VARCHAR(255),
    platform VARCHAR(50) NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
    ip_address INET,
    user_agent TEXT,
    refresh_token_hash VARCHAR(255) NOT NULL,
    refresh_expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sessions_account ON sessions(account_id);
CREATE INDEX idx_sessions_refresh_expires ON sessions(refresh_expires_at);
CREATE INDEX idx_sessions_device ON sessions(device_id);

CREATE TYPE theme_mode AS ENUM ('light', 'dark', 'system');

CREATE TABLE learner_profiles (
    account_id UUID PRIMARY KEY REFERENCES accounts(id) ON DELETE CASCADE,
    nickname VARCHAR(24) NOT NULL,
    avatar_url VARCHAR(500),
    bio TEXT,
    theme_mode theme_mode NOT NULL DEFAULT 'system',
    daily_goal_minutes INTEGER NOT NULL DEFAULT 30 CHECK (daily_goal_minutes >= 0),
    streak_days INTEGER NOT NULL DEFAULT 0 CHECK (streak_days >= 0),
    total_xp INTEGER NOT NULL DEFAULT 0 CHECK (total_xp >= 0),
    current_level INTEGER NOT NULL DEFAULT 1 CHECK (current_level >= 1),
    friend_count INTEGER NOT NULL DEFAULT 0 CHECK (friend_count >= 0),
    ai_daily_limit INTEGER NOT NULL DEFAULT 50 CHECK (ai_daily_limit >= 0),
    last_study_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_learner_profiles_nickname ON learner_profiles(nickname);
CREATE INDEX idx_learner_profiles_xp ON learner_profiles(total_xp DESC);

CREATE TABLE admin_profiles (
    account_id UUID PRIMARY KEY REFERENCES accounts(id) ON DELETE CASCADE,
    display_name VARCHAR(100) NOT NULL,
    avatar_url VARCHAR(500),
    admin_status role_status NOT NULL DEFAULT 'enabled',
    last_active_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TYPE course_status AS ENUM ('draft', 'published', 'archived');
CREATE TYPE difficulty_level AS ENUM ('beginner', 'intermediate', 'easy', 'medium', 'hard');
CREATE TYPE unlock_rule AS ENUM ('free', 'after_previous_completed');

CREATE TABLE courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_code VARCHAR(50) NOT NULL UNIQUE,
    title VARCHAR(100) NOT NULL,
    summary VARCHAR(300) NOT NULL,
    description TEXT,
    cover_image_url VARCHAR(500),
    difficulty difficulty_level NOT NULL,
    estimated_minutes INTEGER NOT NULL DEFAULT 0 CHECK (estimated_minutes >= 0),
    status course_status NOT NULL DEFAULT 'draft',
    sort_order INTEGER NOT NULL DEFAULT 0,
    content_version INTEGER NOT NULL DEFAULT 1 CHECK (content_version >= 1),
    created_by UUID NOT NULL REFERENCES accounts(id),
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_courses_status ON courses(status);
CREATE INDEX idx_courses_sort_order ON courses(sort_order);
CREATE INDEX idx_courses_difficulty ON courses(difficulty);

CREATE TABLE chapters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    chapter_code VARCHAR(50) NOT NULL,
    title VARCHAR(100) NOT NULL,
    summary VARCHAR(300) NOT NULL,
    learning_content_markdown TEXT NOT NULL,
    sample_code TEXT,
    estimated_minutes INTEGER NOT NULL DEFAULT 0 CHECK (estimated_minutes >= 0),
    order_index INTEGER NOT NULL DEFAULT 0,
    unlock_rule unlock_rule NOT NULL DEFAULT 'free',
    status course_status NOT NULL DEFAULT 'draft',
    content_version INTEGER NOT NULL DEFAULT 1 CHECK (content_version >= 1),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(course_id, chapter_code)
);

CREATE INDEX idx_chapters_course ON chapters(course_id);
CREATE INDEX idx_chapters_status ON chapters(status);
CREATE INDEX idx_chapters_order ON chapters(course_id, order_index);

CREATE TYPE exercise_type AS ENUM ('single_choice', 'coding');
CREATE TYPE exercise_language AS ENUM ('html_css');
CREATE TYPE case_type AS ENUM ('dom_snapshot', 'css_assert', 'text_match');

CREATE TABLE exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chapter_id UUID NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
    exercise_code VARCHAR(50) NOT NULL,
    title VARCHAR(100) NOT NULL,
    prompt TEXT NOT NULL,
    exercise_type exercise_type NOT NULL,
    starter_code TEXT,
    language exercise_language NOT NULL,
    difficulty difficulty_level NOT NULL,
    pass_score INTEGER NOT NULL DEFAULT 0 CHECK (pass_score >= 0 AND pass_score <= 100),
    max_attempts_per_day INTEGER CHECK (max_attempts_per_day >= 1),
    status course_status NOT NULL DEFAULT 'draft',
    content_version INTEGER NOT NULL DEFAULT 1 CHECK (content_version >= 1),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(chapter_id, exercise_code)
);

CREATE INDEX idx_exercises_chapter ON exercises(chapter_id);
CREATE INDEX idx_exercises_status ON exercises(status);
CREATE INDEX idx_exercises_type ON exercises(exercise_type);

CREATE TABLE exercise_options (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    option_key VARCHAR(50) NOT NULL,
    option_text TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL DEFAULT FALSE,
    order_index INTEGER NOT NULL DEFAULT 0,
    UNIQUE(exercise_id, option_key)
);

CREATE INDEX idx_exercise_options_exercise ON exercise_options(exercise_id);

CREATE TABLE exercise_test_cases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    case_name VARCHAR(100) NOT NULL,
    case_type case_type NOT NULL,
    input_payload_json JSONB,
    expected_payload_json JSONB NOT NULL,
    weight INTEGER NOT NULL DEFAULT 1 CHECK (weight >= 0),
    is_hidden BOOLEAN NOT NULL DEFAULT FALSE,
    order_index INTEGER NOT NULL DEFAULT 0,
    rule_version INTEGER NOT NULL DEFAULT 1 CHECK (rule_version >= 1),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_test_cases_exercise ON exercise_test_cases(exercise_id);
CREATE INDEX idx_test_cases_hidden ON exercise_test_cases(exercise_id, is_hidden);

CREATE TYPE judge_status AS ENUM ('pending', 'running', 'passed', 'failed', 'error');

CREATE TABLE submissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    exercise_id UUID NOT NULL REFERENCES exercises(id),
    learner_id UUID NOT NULL REFERENCES accounts(id),
    chapter_id UUID NOT NULL REFERENCES chapters(id),
    attempt_no INTEGER NOT NULL DEFAULT 1 CHECK (attempt_no >= 1),
    source_code TEXT NOT NULL,
    judge_status judge_status NOT NULL DEFAULT 'pending',
    score INTEGER NOT NULL DEFAULT 0 CHECK (score >= 0 AND score <= 100),
    passed_case_count INTEGER NOT NULL DEFAULT 0,
    total_case_count INTEGER NOT NULL DEFAULT 0,
    error_summary TEXT,
    runtime_ms INTEGER CHECK (runtime_ms >= 0),
    content_version INTEGER NOT NULL DEFAULT 1,
    rule_version INTEGER NOT NULL DEFAULT 1,
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

CREATE INDEX idx_submissions_learner ON submissions(learner_id);
CREATE INDEX idx_submissions_exercise ON submissions(exercise_id);
CREATE INDEX idx_submissions_status ON submissions(judge_status);
CREATE INDEX idx_submissions_submitted ON submissions(submitted_at DESC);

CREATE TABLE challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    challenge_code VARCHAR(50) NOT NULL UNIQUE,
    title VARCHAR(100) NOT NULL,
    summary VARCHAR(300) NOT NULL,
    related_course_id UUID REFERENCES courses(id),
    difficulty difficulty_level NOT NULL,
    reward_xp INTEGER NOT NULL DEFAULT 0 CHECK (reward_xp >= 0),
    status course_status NOT NULL DEFAULT 'draft',
    sort_order INTEGER NOT NULL DEFAULT 0,
    content_version INTEGER NOT NULL DEFAULT 1 CHECK (content_version >= 1),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_challenges_status ON challenges(status);
CREATE INDEX idx_challenges_sort ON challenges(sort_order);
CREATE INDEX idx_challenges_course ON challenges(related_course_id);

CREATE TABLE challenge_stages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES exercises(id),
    order_index INTEGER NOT NULL CHECK (order_index >= 1),
    star_rule_json JSONB NOT NULL DEFAULT '{}',
    unlock_rule_json JSONB NOT NULL DEFAULT '{}',
    rule_version INTEGER NOT NULL DEFAULT 1 CHECK (rule_version >= 1),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(challenge_id, order_index)
);

CREATE INDEX idx_challenge_stages_challenge ON challenge_stages(challenge_id);
CREATE INDEX idx_challenge_stages_exercise ON challenge_stages(exercise_id);

CREATE TYPE challenge_attempt_status AS ENUM ('locked', 'unlocked', 'in_progress', 'completed');

CREATE TABLE challenge_attempts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    challenge_id UUID NOT NULL REFERENCES challenges(id),
    learner_id UUID NOT NULL REFERENCES accounts(id),
    best_star INTEGER NOT NULL DEFAULT 0 CHECK (best_star >= 0 AND best_star <= 3),
    status challenge_attempt_status NOT NULL DEFAULT 'locked',
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    reward_claimed_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(challenge_id, learner_id)
);

CREATE INDEX idx_challenge_attempts_learner ON challenge_attempts(learner_id);
CREATE INDEX idx_challenge_attempts_challenge ON challenge_attempts(challenge_id);
CREATE INDEX idx_challenge_attempts_status ON challenge_attempts(status);

CREATE TYPE daily_challenge_status AS ENUM ('scheduled', 'active', 'closed');

CREATE TABLE daily_challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    challenge_date DATE NOT NULL UNIQUE,
    title VARCHAR(100) NOT NULL,
    exercise_id UUID NOT NULL REFERENCES exercises(id),
    difficulty difficulty_level NOT NULL,
    time_limit_seconds INTEGER NOT NULL CHECK (time_limit_seconds >= 1),
    reward_xp INTEGER NOT NULL DEFAULT 0 CHECK (reward_xp >= 0),
    status daily_challenge_status NOT NULL DEFAULT 'scheduled',
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_daily_challenges_date ON daily_challenges(challenge_date);
CREATE INDEX idx_daily_challenges_status ON daily_challenges(status);

CREATE TYPE daily_record_status AS ENUM ('not_started', 'passed', 'failed', 'expired');

CREATE TABLE daily_challenge_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    daily_challenge_id UUID NOT NULL REFERENCES daily_challenges(id),
    learner_id UUID NOT NULL REFERENCES accounts(id),
    status daily_record_status NOT NULL DEFAULT 'not_started',
    score INTEGER NOT NULL DEFAULT 0 CHECK (score >= 0),
    elapsed_seconds INTEGER CHECK (elapsed_seconds >= 0),
    streak_after_completion INTEGER NOT NULL DEFAULT 0,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(daily_challenge_id, learner_id)
);

CREATE INDEX idx_daily_records_learner ON daily_challenge_records(learner_id);
CREATE INDEX idx_daily_records_challenge ON daily_challenge_records(daily_challenge_id);

CREATE TYPE xp_source_type AS ENUM ('chapter', 'exercise', 'challenge', 'daily', 'admin_adjustment');

CREATE TABLE xp_ledger (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    learner_id UUID NOT NULL REFERENCES accounts(id),
    source_type xp_source_type NOT NULL,
    source_id UUID NOT NULL,
    delta_xp INTEGER NOT NULL,
    balance_after INTEGER NOT NULL CHECK (balance_after >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_xp_ledger_learner ON xp_ledger(learner_id);
CREATE INDEX idx_xp_ledger_source ON xp_ledger(source_type, source_id);
CREATE INDEX idx_xp_ledger_created ON xp_ledger(created_at DESC);

CREATE TYPE badge_rule_type AS ENUM ('streak', 'course', 'challenge', 'manual');

CREATE TABLE badges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    badge_code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    icon_url VARCHAR(500),
    rule_type badge_rule_type NOT NULL,
    rule_config_json JSONB NOT NULL DEFAULT '{}',
    status course_status NOT NULL DEFAULT 'draft',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_badges_status ON badges(status);
CREATE INDEX idx_badges_rule_type ON badges(rule_type);

CREATE TYPE award_source_type AS ENUM ('system', 'manual');

CREATE TABLE learner_badges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    learner_id UUID NOT NULL REFERENCES accounts(id),
    badge_id UUID NOT NULL REFERENCES badges(id),
    award_source_type award_source_type NOT NULL,
    award_source_id UUID,
    awarded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(learner_id, badge_id)
);

CREATE INDEX idx_learner_badges_learner ON learner_badges(learner_id);
CREATE INDEX idx_learner_badges_badge ON learner_badges(badge_id);

CREATE TYPE friend_status AS ENUM ('pending', 'accepted', 'rejected', 'blocked');

CREATE TABLE friend_relations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    requester_id UUID NOT NULL REFERENCES accounts(id),
    addressee_id UUID NOT NULL REFERENCES accounts(id),
    status friend_status NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    responded_at TIMESTAMPTZ,
    CHECK (requester_id != addressee_id),
    UNIQUE(requester_id, addressee_id)
);

CREATE INDEX idx_friends_requester ON friend_relations(requester_id);
CREATE INDEX idx_friends_addressee ON friend_relations(addressee_id);
CREATE INDEX idx_friends_status ON friend_relations(status);

CREATE TYPE activity_type AS ENUM ('challenge_completed', 'badge_earned', 'streak_reached', 'course_completed');
CREATE TYPE visibility_type AS ENUM ('friends_only', 'public_in_app', 'private');

CREATE TABLE social_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    learner_id UUID NOT NULL REFERENCES accounts(id),
    activity_type activity_type NOT NULL,
    visibility visibility_type NOT NULL DEFAULT 'public_in_app',
    payload_json JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_activities_learner ON social_activities(learner_id);
CREATE INDEX idx_activities_type ON social_activities(activity_type);
CREATE INDEX idx_activities_visibility ON social_activities(visibility);
CREATE INDEX idx_activities_created ON social_activities(created_at DESC);

CREATE TYPE board_type AS ENUM ('daily', 'weekly', 'total');

CREATE TABLE leaderboard_snapshots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    board_type board_type NOT NULL,
    period_key VARCHAR(50) NOT NULL,
    learner_id UUID NOT NULL REFERENCES accounts(id),
    score INTEGER NOT NULL DEFAULT 0 CHECK (score >= 0),
    rank_position INTEGER NOT NULL CHECK (rank_position >= 1),
    generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(board_type, period_key, learner_id)
);

CREATE INDEX idx_leaderboard_type_period ON leaderboard_snapshots(board_type, period_key);
CREATE INDEX idx_leaderboard_learner ON leaderboard_snapshots(learner_id);
CREATE INDEX idx_leaderboard_rank ON leaderboard_snapshots(board_type, period_key, rank_position);

CREATE TYPE progress_status AS ENUM ('not_started', 'in_progress', 'completed');

CREATE TABLE course_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    learner_id UUID NOT NULL REFERENCES accounts(id),
    course_id UUID NOT NULL REFERENCES courses(id),
    completed_chapter_count INTEGER NOT NULL DEFAULT 0,
    total_chapter_count INTEGER NOT NULL DEFAULT 0,
    completed_exercise_count INTEGER NOT NULL DEFAULT 0,
    progress_percent INTEGER NOT NULL DEFAULT 0 CHECK (progress_percent >= 0 AND progress_percent <= 100),
    last_studied_chapter_id UUID REFERENCES chapters(id),
    status progress_status NOT NULL DEFAULT 'not_started',
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(learner_id, course_id)
);

CREATE INDEX idx_progress_learner ON course_progress(learner_id);
CREATE INDEX idx_progress_course ON course_progress(course_id);
CREATE INDEX idx_progress_status ON course_progress(status);

CREATE TYPE ai_request_type AS ENUM ('error_explanation', 'hint');
CREATE TYPE ai_request_status AS ENUM ('pending', 'succeeded', 'failed', 'rate_limited');

CREATE TABLE ai_help_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    learner_id UUID NOT NULL REFERENCES accounts(id),
    exercise_id UUID REFERENCES exercises(id),
    submission_id UUID REFERENCES submissions(id),
    request_type ai_request_type NOT NULL,
    source_code TEXT,
    error_context_json JSONB,
    response_text TEXT,
    response_structured_json JSONB,
    provider_name VARCHAR(100) NOT NULL,
    token_usage INTEGER CHECK (token_usage >= 0),
    latency_ms INTEGER CHECK (latency_ms >= 0),
    status ai_request_status NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ai_learner ON ai_help_requests(learner_id);
CREATE INDEX idx_ai_exercise ON ai_help_requests(exercise_id);
CREATE INDEX idx_ai_status ON ai_help_requests(status);
CREATE INDEX idx_ai_created ON ai_help_requests(created_at DESC);

CREATE TYPE feedback_category AS ENUM ('content', 'problem', 'bug', 'account', 'other');
CREATE TYPE feedback_status AS ENUM ('open', 'in_progress', 'resolved', 'closed');

CREATE TABLE feedback_tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    learner_id UUID NOT NULL REFERENCES accounts(id),
    category feedback_category NOT NULL,
    content TEXT NOT NULL,
    screenshot_urls JSONB DEFAULT '[]',
    status feedback_status NOT NULL DEFAULT 'open',
    admin_reply TEXT,
    replied_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_feedback_learner ON feedback_tickets(learner_id);
CREATE INDEX idx_feedback_status ON feedback_tickets(status);
CREATE INDEX idx_feedback_category ON feedback_tickets(category);

CREATE TYPE moderation_case_type AS ENUM ('nickname', 'avatar', 'feedback');
CREATE TYPE moderation_status AS ENUM ('pending', 'approved', 'rejected');

CREATE TABLE moderation_cases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_type moderation_case_type NOT NULL,
    target_id UUID NOT NULL,
    target_snapshot_json JSONB NOT NULL DEFAULT '{}',
    status moderation_status NOT NULL DEFAULT 'pending',
    decision_reason TEXT,
    reviewed_by UUID REFERENCES accounts(id),
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_moderation_status ON moderation_cases(status);
CREATE INDEX idx_moderation_reviewer ON moderation_cases(reviewed_by);
CREATE INDEX idx_moderation_target ON moderation_cases(target_id);

CREATE TYPE announcement_audience AS ENUM ('all_learners', 'all_admins', 'all');
CREATE TYPE announcement_status AS ENUM ('draft', 'published', 'expired');

CREATE TABLE announcements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(120) NOT NULL,
    body_markdown TEXT NOT NULL,
    audience announcement_audience NOT NULL,
    status announcement_status NOT NULL DEFAULT 'draft',
    published_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    created_by UUID NOT NULL REFERENCES accounts(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_announcements_status ON announcements(status);
CREATE INDEX idx_announcements_audience ON announcements(audience);
CREATE INDEX idx_announcements_dates ON announcements(published_at, expires_at);

CREATE TYPE config_scope AS ENUM ('system', 'ai', 'challenge', 'reward');
CREATE TYPE config_status AS ENUM ('active', 'inactive');

CREATE TABLE system_configs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    config_key VARCHAR(100) NOT NULL UNIQUE,
    config_scope config_scope NOT NULL,
    value_json JSONB NOT NULL DEFAULT '{}',
    status config_status NOT NULL DEFAULT 'active',
    updated_by UUID NOT NULL REFERENCES accounts(id),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_configs_scope ON system_configs(config_scope);
CREATE INDEX idx_configs_status ON system_configs(status);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID REFERENCES accounts(id),
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id UUID,
    old_value_json JSONB,
    new_value_json JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_actor ON audit_logs(actor_id);
CREATE INDEX idx_audit_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DO $$
DECLARE
    t text;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.columns 
        WHERE column_name = 'updated_at' 
        AND table_schema = 'public'
    LOOP
        EXECUTE format('CREATE TRIGGER IF NOT EXISTS trg_%I_updated_at 
            BEFORE UPDATE ON %I 
            FOR EACH ROW 
            EXECUTE FUNCTION update_updated_at_column()', t, t);
    END LOOP;
END $$;

INSERT INTO system_configs (config_key, config_scope, value_json, updated_by) VALUES
('max_friends_per_learner', 'system', '{"value": 50}', '00000000-0000-0000-0000-000000000000'),
('ai_daily_limit_default', 'ai', '{"value": 50}', '00000000-0000-0000-0000-000000000000'),
('challenge_max_attempts_default', 'challenge', '{"value": 3}', '00000000-0000-0000-0000-000000000000'),
('streak_bonus_xp_multiplier', 'reward', '{"value": 1.5}', '00000000-0000-0000-0000-000000000000')
ON CONFLICT (config_key) DO NOTHING;
