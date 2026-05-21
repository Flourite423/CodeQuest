-- Extend ai_request_type enum with three-level hint variants
ALTER TYPE ai_request_type ADD VALUE IF NOT EXISTS 'error_location';
ALTER TYPE ai_request_type ADD VALUE IF NOT EXISTS 'correction_hint';
ALTER TYPE ai_request_type ADD VALUE IF NOT EXISTS 'operation_suggestion';
