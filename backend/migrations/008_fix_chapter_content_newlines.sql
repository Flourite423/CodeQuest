-- Fix chapter content: replace literal \n with actual newlines
-- This migration updates the learning_content_markdown field to use actual newlines

UPDATE chapters 
SET learning_content_markdown = REPLACE(learning_content_markdown, '\n', E'\n')
WHERE learning_content_markdown LIKE '%\n%';

-- Also fix sample_code field
UPDATE chapters 
SET sample_code = REPLACE(sample_code, '\n', E'\n')
WHERE sample_code LIKE '%\n%';
