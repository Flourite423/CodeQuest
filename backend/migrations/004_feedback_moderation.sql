DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'feedback_category') THEN
        CREATE TYPE feedback_category AS ENUM ('content', 'problem', 'bug', 'account', 'other');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'feedback_status') THEN
        CREATE TYPE feedback_status AS ENUM ('open', 'in_progress', 'resolved', 'closed');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'moderation_case_type') THEN
        CREATE TYPE moderation_case_type AS ENUM ('nickname', 'avatar', 'feedback');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'moderation_status') THEN
        CREATE TYPE moderation_status AS ENUM ('pending', 'approved', 'rejected');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS feedback_tickets (
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

CREATE INDEX IF NOT EXISTS idx_feedback_learner ON feedback_tickets(learner_id);
CREATE INDEX IF NOT EXISTS idx_feedback_status ON feedback_tickets(status);
CREATE INDEX IF NOT EXISTS idx_feedback_category ON feedback_tickets(category);

CREATE TABLE IF NOT EXISTS moderation_cases (
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

CREATE INDEX IF NOT EXISTS idx_moderation_status ON moderation_cases(status);
CREATE INDEX IF NOT EXISTS idx_moderation_reviewer ON moderation_cases(reviewed_by);
CREATE INDEX IF NOT EXISTS idx_moderation_target ON moderation_cases(target_id);
