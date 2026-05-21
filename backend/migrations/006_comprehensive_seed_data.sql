-- Comprehensive Seed Data for CodeQuest Learning Platform
-- This migration adds realistic data to simulate an active learning platform

-- ============================================
-- 1. USER ACCOUNTS (10 learners + 2 admins)
-- ============================================

-- Admin accounts
INSERT INTO accounts (id, email, password_hash, default_role, account_status) VALUES
('00000000-0000-0000-0000-000000000010', 'admin1@codequest.com', '$2b$12$LJ3m4ys3Lk0TSwMOPHgXaOEFX.UHQE1jNbOoZfHxDiFmFozJ8K8He', 'admin', 'active'),
('00000000-0000-0000-0000-000000000011', 'admin2@codequest.com', '$2b$12$LJ3m4ys3Lk0TSwMOPHgXaOEFX.UHQE1jNbOoZfHxDiFmFozJ8K8He', 'admin', 'active')
ON CONFLICT (id) DO NOTHING;

INSERT INTO admin_profiles (account_id, display_name, admin_status) VALUES
('00000000-0000-0000-0000-000000000010', '系统管理员', 'enabled'),
('00000000-0000-0000-0000-000000000011', '内容管理员', 'enabled')
ON CONFLICT (account_id) DO NOTHING;

-- Learner accounts with different activity levels
INSERT INTO accounts (id, email, password_hash, default_role, account_status) VALUES
('00000000-0000-0000-0000-000000000020', 'alice@example.com', '$2b$12$LJ3m4ys3Lk0TSwMOPHgXaOEFX.UHQE1jNbOoZfHxDiFmFozJ8K8He', 'learner', 'active'),
('00000000-0000-0000-0000-000000000021', 'bob@example.com', '$2b$12$LJ3m4ys3Lk0TSwMOPHgXaOEFX.UHQE1jNbOoZfHxDiFmFozJ8K8He', 'learner', 'active'),
('00000000-0000-0000-0000-000000000022', 'charlie@example.com', '$2b$12$LJ3m4ys3Lk0TSwMOPHgXaOEFX.UHQE1jNbOoZfHxDiFmFozJ8K8He', 'learner', 'active'),
('00000000-0000-0000-0000-000000000023', 'diana@example.com', '$2b$12$LJ3m4ys3Lk0TSwMOPHgXaOEFX.UHQE1jNbOoZfHxDiFmFozJ8K8He', 'learner', 'active'),
('00000000-0000-0000-0000-000000000024', 'eve@example.com', '$2b$12$LJ3m4ys3Lk0TSwMOPHgXaOEFX.UHQE1jNbOoZfHxDiFmFozJ8K8He', 'learner', 'active'),
('00000000-0000-0000-0000-000000000025', 'frank@example.com', '$2b$12$LJ3m4ys3Lk0TSwMOPHgXaOEFX.UHQE1jNbOoZfHxDiFmFozJ8K8He', 'learner', 'active'),
('00000000-0000-0000-0000-000000000026', 'grace@example.com', '$2b$12$LJ3m4ys3Lk0TSwMOPHgXaOEFX.UHQE1jNbOoZfHxDiFmFozJ8K8He', 'learner', 'active'),
('00000000-0000-0000-0000-000000000027', 'henry@example.com', '$2b$12$LJ3m4ys3Lk0TSwMOPHgXaOEFX.UHQE1jNbOoZfHxDiFmFozJ8K8He', 'learner', 'active'),
('00000000-0000-0000-0000-000000000028', 'ivy@example.com', '$2b$12$LJ3m4ys3Lk0TSwMOPHgXaOEFX.UHQE1jNbOoZfHxDiFmFozJ8K8He', 'learner', 'active'),
('00000000-0000-0000-0000-000000000029', 'jack@example.com', '$2b$12$LJ3m4ys3Lk0TSwMOPHgXaOEFX.UHQE1jNbOoZfHxDiFmFozJ8K8He', 'learner', 'active')
ON CONFLICT (id) DO NOTHING;

-- Learner profiles with varying XP levels and streaks
INSERT INTO learner_profiles (account_id, nickname, bio, daily_goal_minutes, streak_days, total_xp, current_level, friend_count, last_study_at) VALUES
('00000000-0000-0000-0000-000000000020', 'Alice', '热爱前端开发的初学者', 30, 15, 2850, 8, 4, NOW() - INTERVAL '2 hours'),
('00000000-0000-0000-0000-000000000021', 'Bob', '正在学习HTML和CSS', 45, 8, 1920, 6, 3, NOW() - INTERVAL '1 day'),
('00000000-0000-0000-0000-000000000022', 'Charlie', '前端开发爱好者', 60, 22, 4150, 11, 5, NOW() - INTERVAL '3 hours'),
('00000000-0000-0000-0000-000000000023', 'Diana', '每天坚持学习一点', 20, 5, 980, 4, 2, NOW() - INTERVAL '5 hours'),
('00000000-0000-0000-0000-000000000024', 'Eve', '从零开始学前端', 15, 3, 450, 2, 1, NOW() - INTERVAL '2 days'),
('00000000-0000-0000-0000-000000000025', 'Frank', '后端转前端', 40, 12, 2100, 7, 3, NOW() - INTERVAL '4 hours'),
('00000000-0000-0000-0000-000000000026', 'Grace', '学生党，课余学习', 25, 7, 1350, 5, 2, NOW() - INTERVAL '6 hours'),
('00000000-0000-0000-0000-000000000027', 'Henry', '想要做自己的网站', 35, 10, 1680, 6, 2, NOW() - INTERVAL '1 day'),
('00000000-0000-0000-0000-000000000028', 'Ivy', '设计师学前端', 50, 18, 3200, 9, 4, NOW() - INTERVAL '1 hour'),
('00000000-0000-0000-0000-000000000029', 'Jack', '前端新手上路', 10, 1, 120, 1, 0, NOW() - INTERVAL '3 days')
ON CONFLICT (account_id) DO NOTHING;

-- ============================================
-- 2. COURSES (5 courses)
-- ============================================

INSERT INTO courses (id, course_code, title, summary, description, difficulty, estimated_minutes, status, sort_order, created_by, published_at) VALUES
('00000000-0000-0000-0000-000000000101', 'HTML-BASICS', 'HTML基础入门', '学习HTML的基本标签和页面结构', '本课程将带你从零开始学习HTML，掌握网页的基本结构。你将学习到常用的HTML标签、属性以及如何创建简单的网页。', 'beginner', 180, 'published', 1, '00000000-0000-0000-0000-000000000010', NOW() - INTERVAL '30 days'),
('00000000-0000-0000-0000-000000000102', 'CSS-FUNDAMENTALS', 'CSS样式基础', '掌握CSS选择器和基本样式属性', '本课程将帮助你理解CSS的核心概念，包括选择器、盒模型、颜色、字体等基本样式属性。', 'beginner', 240, 'published', 2, '00000000-0000-0000-0000-000000000010', NOW() - INTERVAL '25 days'),
('00000000-0000-0000-0000-000000000103', 'CSS-LAYOUT', 'CSS布局进阶', '学习Flexbox和Grid布局', '本课程将深入讲解现代CSS布局技术，包括Flexbox和Grid，让你能够创建复杂的页面布局。', 'intermediate', 300, 'published', 3, '00000000-0000-0000-0000-000000000010', NOW() - INTERVAL '20 days'),
('00000000-0000-0000-0000-000000000104', 'RESPONSIVE-DESIGN', '响应式网页设计', '创建适配各种设备的网页', '学习如何使用媒体查询和响应式设计原则，创建在手机、平板和桌面设备上都能良好显示的网页。', 'intermediate', 270, 'published', 4, '00000000-0000-0000-0000-000000000010', NOW() - INTERVAL '15 days'),
('00000000-0000-0000-0000-000000000105', 'HTML-SEMANTICS', 'HTML语义化', '使用语义化标签构建更好的网页', '本课程将教你如何使用HTML5语义化标签，提高网页的可访问性和SEO效果。', 'easy', 150, 'published', 5, '00000000-0000-0000-0000-000000000010', NOW() - INTERVAL '10 days')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 3. CHAPTERS (3-4 chapters per course)
-- ============================================

-- HTML Basics chapters
INSERT INTO chapters (id, course_id, chapter_code, title, summary, learning_content_markdown, sample_code, estimated_minutes, order_index, status) VALUES
('00000000-0000-0000-0000-000000000201', '00000000-0000-0000-0000-000000000101', 'CH01', '认识HTML', '了解HTML的基本概念和文档结构', '# 认识HTML\n\nHTML（HyperText Markup Language）是构建网页的基础语言。\n\n## 什么是HTML？\n\nHTML使用标签来描述网页的结构。每个标签都有特定的含义和用途。\n\n## 第一个HTML文档\n\n```html\n<!DOCTYPE html>\n<html>\n<head>\n    <title>我的第一个网页</title>\n</head>\n<body>\n    <h1>Hello, World!</h1>\n</body>\n</html>\n```\n\n## 学习要点\n\n- HTML文档的基本结构\n- DOCTYPE声明的作用\n- html、head、body标签的含义', '<!DOCTYPE html>\n<html>\n<head>\n    <title>示例页面</title>\n</head>\n<body>\n    <h1>欢迎来到我的网页</h1>\n    <p>这是一个段落。</p>\n</body>\n</html>', 30, 1, 'published'),
('00000000-0000-0000-0000-000000000202', '00000000-0000-0000-0000-000000000101', 'CH02', '常用文本标签', '学习标题、段落、列表等文本标签', '# 常用文本标签\n\n## 标题标签\n\nHTML提供了6级标题标签，从h1到h6。\n\n```html\n<h1>一级标题</h1>\n<h2>二级标题</h2>\n<h3>三级标题</h3>\n```\n\n## 段落和换行\n\n```html\n<p>这是一个段落。</p>\n<p>这是另一个段落。</p>\n<br> <!-- 换行 -->\n```\n\n## 列表\n\n### 无序列表\n```html\n<ul>\n    <li>项目1</li>\n    <li>项目2</li>\n</ul>\n```\n\n### 有序列表\n```html\n<ol>\n    <li>第一步</li>\n    <li>第二步</li>\n</ol>\n```', '<h1>标题</h1>\n<p>段落文本</p>\n<ul>\n    <li>列表项</li>\n</ul>', 45, 2, 'published'),
('00000000-0000-0000-0000-000000000203', '00000000-0000-0000-0000-000000000101', 'CH03', '链接和图片', '创建超链接和插入图片', '# 链接和图片\n\n## 超链接\n\n使用a标签创建链接：\n\n```html\n<a href="https://example.com">点击这里</a>\n```\n\n## 图片\n\n使用img标签插入图片：\n\n```html\n<img src="image.jpg" alt="描述文字">\n```\n\n## 图片链接\n\n```html\n<a href="https://example.com">\n    <img src="logo.png" alt="Logo">\n</a>\n```', '<a href="https://example.com">链接</a>\n<img src="image.jpg" alt="图片">', 35, 3, 'published'),
('00000000-0000-0000-0000-000000000204', '00000000-0000-0000-0000-000000000101', 'CH04', '表格和表单', '创建数据表格和用户表单', '# 表格和表单\n\n## 表格\n\n```html\n<table>\n    <tr>\n        <th>姓名</th>\n        <th>年龄</th>\n    </tr>\n    <tr>\n        <td>张三</td>\n        <td>25</td>\n    </tr>\n</table>\n```\n\n## 表单\n\n```html\n<form action="/submit" method="POST">\n    <label for="name">姓名：</label>\n    <input type="text" id="name" name="name">\n    \n    <label for="email">邮箱：</label>\n    <input type="email" id="email" name="email">\n    \n    <button type="submit">提交</button>\n</form>\n```', '<form>\n    <input type="text" placeholder="输入姓名">\n    <button type="submit">提交</button>\n</form>', 40, 4, 'published')
ON CONFLICT (id) DO NOTHING;

-- CSS Fundamentals chapters
INSERT INTO chapters (id, course_id, chapter_code, title, summary, learning_content_markdown, sample_code, estimated_minutes, order_index, status) VALUES
('00000000-0000-0000-0000-000000000211', '00000000-0000-0000-0000-000000000102', 'CH01', 'CSS选择器', '学习基础选择器和组合选择器', '# CSS选择器\n\n## 元素选择器\n\n```css\np {\n    color: blue;\n}\n```\n\n## 类选择器\n\n```css\n.highlight {\n    background-color: yellow;\n}\n```\n\n## ID选择器\n\n```css\n#header {\n    font-size: 24px;\n}\n```', 'p { color: blue; }\n.highlight { background: yellow; }', 40, 1, 'published'),
('00000000-0000-0000-0000-000000000212', '00000000-0000-0000-0000-000000000102', 'CH02', '盒模型', '理解CSS盒模型的概念', '# 盒模型\n\n## 什么是盒模型\n\n每个HTML元素都可以看作一个矩形盒子，由内容、内边距、边框和外边距组成。\n\n```css\n.box {\n    width: 200px;\n    padding: 20px;\n    border: 1px solid black;\n    margin: 10px;\n}\n```\n\n## box-sizing\n\n```css\n* {\n    box-sizing: border-box;\n}\n```', '.box { width: 200px; padding: 20px; border: 1px solid black; margin: 10px; }', 45, 2, 'published'),
('00000000-0000-0000-0000-000000000213', '00000000-0000-0000-0000-000000000102', 'CH03', '颜色和背景', '设置颜色和背景样式', '# 颜色和背景\n\n## 颜色值\n\n```css\n.text {\n    color: red;\n    color: #ff0000;\n    color: rgb(255, 0, 0);\n}\n```\n\n## 背景\n\n```css\n.box {\n    background-color: #f0f0f0;\n    background-image: url(\"bg.jpg\");\n    background-size: cover;\n}\n```', '.text { color: #333; }\n.box { background: linear-gradient(to right, #ff0000, #0000ff); }', 35, 3, 'published'),
('00000000-0000-0000-0000-000000000214', '00000000-0000-0000-0000-000000000102', 'CH04', '字体和文本', '设置字体和文本样式', '# 字体和文本\n\n## 字体属性\n\n```css\n.text {\n    font-family: Arial, sans-serif;\n    font-size: 16px;\n    font-weight: bold;\n    line-height: 1.5;\n}\n```\n\n## 文本对齐\n\n```css\n.center {\n    text-align: center;\n}\n```', 'p { font-family: Arial; font-size: 16px; line-height: 1.5; }', 40, 4, 'published')
ON CONFLICT (id) DO NOTHING;

-- CSS Layout chapters
INSERT INTO chapters (id, course_id, chapter_code, title, summary, learning_content_markdown, sample_code, estimated_minutes, order_index, status) VALUES
('00000000-0000-0000-0000-000000000221', '00000000-0000-0000-0000-000000000103', 'CH01', 'Flexbox基础', '学习Flexbox布局的基本概念', '# Flexbox基础\n\n## 什么是Flexbox\n\nFlexbox是一种一维布局模型，适合做组件级别的布局。\n\n```css\n.container {\n    display: flex;\n    justify-content: center;\n    align-items: center;\n}\n```', '.container { display: flex; justify-content: center; align-items: center; }', 50, 1, 'published'),
('00000000-0000-0000-0000-000000000222', '00000000-0000-0000-0000-000000000103', 'CH02', 'Flexbox进阶', '掌握Flexbox的高级用法', '# Flexbox进阶\n\n## flex属性\n\n```css\n.item {\n    flex: 1; /* 等分 */\n    flex: 0 0 200px; /* 固定宽度 */\n}\n```\n\n## 换行\n\n```css\n.container {\n    flex-wrap: wrap;\n}\n```', '.item { flex: 1; }\n.container { flex-wrap: wrap; }', 55, 2, 'published'),
('00000000-0000-0000-0000-000000000223', '00000000-0000-0000-0000-000000000103', 'CH03', 'Grid布局', '学习CSS Grid二维布局', '# Grid布局\n\n## 基础Grid\n\n```css\n.grid {\n    display: grid;\n    grid-template-columns: repeat(3, 1fr);\n    gap: 20px;\n}\n```', '.grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }', 60, 3, 'published')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 4. EXERCISES (2-3 per chapter)
-- ============================================

-- HTML Basics exercises
INSERT INTO exercises (id, chapter_id, exercise_code, title, prompt, exercise_type, starter_code, language, difficulty, pass_score, status) VALUES
('00000000-0000-0000-0000-000000000301', '00000000-0000-0000-0000-000000000201', 'EX01', '创建基本HTML页面', '请创建一个包含标题和段落的基本HTML页面。要求：1) 使用h1标签创建标题"我的主页" 2) 使用p标签创建一段自我介绍', 'coding', '<!DOCTYPE html>\n<html>\n<head>\n    <title>我的主页</title>\n</head>\n<body>\n    <!-- 在这里编写你的代码 -->\n    \n</body>\n</html>', 'html_css', 'beginner', 80, 'published'),
('00000000-0000-0000-0000-000000000302', '00000000-0000-0000-0000-000000000201', 'EX02', 'HTML文档结构', '以下哪个标签用于定义HTML文档的根元素？', 'single_choice', NULL, 'html_css', 'beginner', 100, 'published'),
('00000000-0000-0000-0000-000000000303', '00000000-0000-0000-0000-000000000202', 'EX01', '创建标题层级', '请创建一个包含h1到h3标题的页面，标题内容分别为"一级标题"、"二级标题"、"三级标题"', 'coding', '<!DOCTYPE html>\n<html>\n<body>\n    <!-- 在这里创建标题 -->\n    \n</body>\n</html>', 'html_css', 'beginner', 80, 'published'),
('00000000-0000-0000-0000-000000000304', '00000000-0000-0000-0000-000000000202', 'EX02', '创建列表', '请创建一个无序列表，包含三个列表项：HTML、CSS、JavaScript', 'coding', '<!DOCTYPE html>\n<html>\n<body>\n    <!-- 在这里创建列表 -->\n    \n</body>\n</html>', 'html_css', 'beginner', 80, 'published'),
('00000000-0000-0000-0000-000000000305', '00000000-0000-0000-0000-000000000203', 'EX01', '创建链接', '请创建一个指向"https://example.com"的链接，链接文本为"访问示例网站"', 'coding', '<!DOCTYPE html>\n<html>\n<body>\n    <!-- 在这里创建链接 -->\n    \n</body>\n</html>', 'html_css', 'beginner', 80, 'published'),
('00000000-0000-0000-0000-000000000306', '00000000-0000-0000-0000-000000000203', 'EX02', '插入图片', '请插入一张图片，图片URL为"logo.png"，替代文本为"网站Logo"', 'coding', '<!DOCTYPE html>\n<html>\n<body>\n    <!-- 在这里插入图片 -->\n    \n</body>\n</html>', 'html_css', 'beginner', 80, 'published')
ON CONFLICT (id) DO NOTHING;

-- CSS Fundamentals exercises
INSERT INTO exercises (id, chapter_id, exercise_code, title, prompt, exercise_type, starter_code, language, difficulty, pass_score, status) VALUES
('00000000-0000-0000-0000-000000000311', '00000000-0000-0000-0000-000000000211', 'EX01', '使用类选择器', '请使用CSS类选择器将class为"highlight"的元素背景色设置为黄色', 'coding', '<!DOCTYPE html>\n<html>\n<head>\n    <style>\n        /* 在这里添加CSS */\n        \n    </style>\n</head>\n<body>\n    <p class="highlight">这段文字应该有黄色背景</p>\n</body>\n</html>', 'html_css', 'beginner', 80, 'published'),
('00000000-0000-0000-0000-000000000312', '00000000-0000-0000-0000-000000000211', 'EX02', '选择器优先级', '以下哪个选择器的优先级最高？', 'single_choice', NULL, 'html_css', 'beginner', 100, 'published'),
('00000000-0000-0000-0000-000000000313', '00000000-0000-0000-0000-000000000212', 'EX01', '设置盒模型', '请为class为"box"的元素设置：宽度200px，内边距20px，边框1px solid black，外边距10px', 'coding', '<!DOCTYPE html>\n<html>\n<head>\n    <style>\n        .box {\n            /* 在这里添加样式 */\n            \n        }\n    </style>\n</head>\n<body>\n    <div class="box">盒子模型示例</div>\n</body>\n</html>', 'html_css', 'beginner', 80, 'published')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 5. EXERCISE OPTIONS (for single choice)
-- ============================================

INSERT INTO exercise_options (exercise_id, option_key, option_text, is_correct, order_index) VALUES
('00000000-0000-0000-0000-000000000302', 'A', '<html>', TRUE, 1),
('00000000-0000-0000-0000-000000000302', 'B', '<body>', FALSE, 2),
('00000000-0000-0000-0000-000000000302', 'C', '<head>', FALSE, 3),
('00000000-0000-0000-0000-000000000302', 'D', '<div>', FALSE, 4),
('00000000-0000-0000-0000-000000000312', 'A', '元素选择器', FALSE, 1),
('00000000-0000-0000-0000-000000000312', 'B', '类选择器', FALSE, 2),
('00000000-0000-0000-0000-000000000312', 'C', 'ID选择器', TRUE, 3),
('00000000-0000-0000-0000-000000000312', 'D', '通配符选择器', FALSE, 4)
ON CONFLICT (exercise_id, option_key) DO NOTHING;

-- ============================================
-- 6. EXERCISE TEST CASES
-- ============================================

INSERT INTO exercise_test_cases (exercise_id, case_name, case_type, input_payload_json, expected_payload_json, weight, is_hidden, order_index) VALUES
('00000000-0000-0000-0000-000000000301', '检查h1标签', 'dom_snapshot', '{"selector": "h1"}', '{"exists": true, "text": "我的主页"}', 1, FALSE, 1),
('00000000-0000-0000-0000-000000000301', '检查p标签', 'dom_snapshot', '{"selector": "p"}', '{"exists": true}', 1, FALSE, 2),
('00000000-0000-0000-0000-000000000303', '检查h1标签', 'dom_snapshot', '{"selector": "h1"}', '{"exists": true, "text": "一级标题"}', 1, FALSE, 1),
('00000000-0000-0000-0000-000000000303', '检查h2标签', 'dom_snapshot', '{"selector": "h2"}', '{"exists": true, "text": "二级标题"}', 1, FALSE, 2),
('00000000-0000-0000-0000-000000000303', '检查h3标签', 'dom_snapshot', '{"selector": "h3"}', '{"exists": true, "text": "三级标题"}', 1, FALSE, 3),
('00000000-0000-0000-0000-000000000304', '检查ul标签', 'dom_snapshot', '{"selector": "ul"}', '{"exists": true}', 1, FALSE, 1),
('00000000-0000-0000-0000-000000000304', '检查li数量', 'dom_snapshot', '{"selector": "li"}', '{"count": 3}', 1, FALSE, 2),
('00000000-0000-0000-0000-000000000305', '检查a标签', 'dom_snapshot', '{"selector": "a"}', '{"exists": true, "href": "https://example.com"}', 1, FALSE, 1),
('00000000-0000-0000-0000-000000000306', '检查img标签', 'dom_snapshot', '{"selector": "img"}', '{"exists": true, "src": "logo.png", "alt": "网站Logo"}', 1, FALSE, 1),
('00000000-0000-0000-0000-000000000311', '检查背景色', 'css_assert', '{"selector": ".highlight", "property": "background-color"}', '{"value": "yellow"}', 1, FALSE, 1),
('00000000-0000-0000-0000-000000000313', '检查宽度', 'css_assert', '{"selector": ".box", "property": "width"}', '{"value": "200px"}', 1, FALSE, 1),
('00000000-0000-0000-0000-000000000313', '检查内边距', 'css_assert', '{"selector": ".box", "property": "padding"}', '{"value": "20px"}', 1, FALSE, 2),
('00000000-0000-0000-0000-000000000313', '检查边框', 'css_assert', '{"selector": ".box", "property": "border"}', '{"contains": "1px solid"}', 1, FALSE, 3)
ON CONFLICT DO NOTHING;

-- ============================================
-- 7. CHALLENGES (5 challenges)
-- ============================================

INSERT INTO challenges (id, challenge_code, title, summary, related_course_id, difficulty, reward_xp, status, sort_order) VALUES
('00000000-0000-0000-0000-000000000401', 'CH-HTML-01', 'HTML新手挑战', '完成基础HTML标签练习', '00000000-0000-0000-0000-000000000101', 'beginner', 100, 'published', 1),
('00000000-0000-0000-0000-000000000402', 'CH-HTML-02', 'HTML进阶挑战', '掌握HTML表格和表单', '00000000-0000-0000-0000-000000000101', 'easy', 150, 'published', 2),
('00000000-0000-0000-0000-000000000403', 'CH-CSS-01', 'CSS基础挑战', '完成CSS选择器练习', '00000000-0000-0000-0000-000000000102', 'beginner', 120, 'published', 3),
('00000000-0000-0000-0000-000000000404', 'CH-CSS-02', 'CSS布局挑战', '使用Flexbox创建布局', '00000000-0000-0000-0000-000000000103', 'intermediate', 200, 'published', 4),
('00000000-0000-0000-0000-000000000405', 'CH-FULL-01', '综合挑战', '创建完整的响应式页面', NULL, 'medium', 300, 'published', 5)
ON CONFLICT (id) DO NOTHING;

-- Challenge stages
INSERT INTO challenge_stages (challenge_id, exercise_id, order_index, star_rule_json) VALUES
('00000000-0000-0000-0000-000000000401', '00000000-0000-0000-0000-000000000301', 1, '{"min_score": 80}'),
('00000000-0000-0000-0000-000000000401', '00000000-0000-0000-0000-000000000303', 2, '{"min_score": 80}'),
('00000000-0000-0000-0000-000000000401', '00000000-0000-0000-0000-000000000304', 3, '{"min_score": 80}'),
('00000000-0000-0000-0000-000000000402', '00000000-0000-0000-0000-000000000305', 1, '{"min_score": 80}'),
('00000000-0000-0000-0000-000000000402', '00000000-0000-0000-0000-000000000306', 2, '{"min_score": 80}'),
('00000000-0000-0000-0000-000000000403', '00000000-0000-0000-0000-000000000311', 1, '{"min_score": 80}'),
('00000000-0000-0000-0000-000000000403', '00000000-0000-0000-0000-000000000313', 2, '{"min_score": 80}')
ON CONFLICT DO NOTHING;

-- ============================================
-- 8. DAILY CHALLENGES (7 days)
-- ============================================

INSERT INTO daily_challenges (id, challenge_date, title, exercise_id, difficulty, time_limit_seconds, reward_xp, status, published_at) VALUES
('00000000-0000-0000-0000-000000000501', CURRENT_DATE, '今日HTML挑战', '00000000-0000-0000-0000-000000000301', 'beginner', 300, 50, 'active', NOW()),
('00000000-0000-0000-0000-000000000502', CURRENT_DATE - INTERVAL '1 day', '昨日CSS挑战', '00000000-0000-0000-0000-000000000311', 'beginner', 300, 50, 'closed', NOW() - INTERVAL '1 day'),
('00000000-0000-0000-0000-000000000503', CURRENT_DATE - INTERVAL '2 days', '前天链接挑战', '00000000-0000-0000-0000-000000000305', 'beginner', 240, 40, 'closed', NOW() - INTERVAL '2 days'),
('00000000-0000-0000-0000-000000000504', CURRENT_DATE - INTERVAL '3 days', '大前天列表挑战', '00000000-0000-0000-0000-000000000304', 'beginner', 240, 40, 'closed', NOW() - INTERVAL '3 days'),
('00000000-0000-0000-0000-000000000505', CURRENT_DATE + INTERVAL '1 day', '明日图片挑战', '00000000-0000-0000-0000-000000000306', 'beginner', 300, 50, 'scheduled', NULL),
('00000000-0000-0000-0000-000000000506', CURRENT_DATE + INTERVAL '2 days', '后天盒模型挑战', '00000000-0000-0000-0000-000000000313', 'easy', 360, 60, 'scheduled', NULL),
('00000000-0000-0000-0000-000000000507', CURRENT_DATE + INTERVAL '3 days', '大后天选择器挑战', '00000000-0000-0000-0000-000000000311', 'beginner', 300, 50, 'scheduled', NULL)
ON CONFLICT (challenge_date) DO NOTHING;

-- ============================================
-- 9. BADGES (10 badges)
-- ============================================

INSERT INTO badges (id, badge_code, name, description, rule_type, rule_config_json, status) VALUES
('00000000-0000-0000-0000-000000000601', 'FIRST_LOGIN', '初来乍到', '完成首次登录', 'manual', '{}', 'published'),
('00000000-0000-0000-0000-000000000602', 'STREAK_3', '三日打卡', '连续学习3天', 'streak', '{"days": 3}', 'published'),
('00000000-0000-0000-0000-000000000603', 'STREAK_7', '一周坚持', '连续学习7天', 'streak', '{"days": 7}', 'published'),
('00000000-0000-0000-0000-000000000604', 'STREAK_14', '两周不辍', '连续学习14天', 'streak', '{"days": 14}', 'published'),
('00000000-0000-0000-0000-000000000605', 'COURSE_COMPLETE', '课程达人', '完成一门课程', 'course', '{"count": 1}', 'published'),
('00000000-0000-0000-0000-000000000606', 'CHALLENGE_3STAR', '三星通关', '在挑战中获得三星', 'challenge', '{"stars": 3}', 'published'),
('00000000-0000-0000-0000-000000000607', 'XP_1000', '千分学者', '累计获得1000经验值', 'manual', '{"xp": 1000}', 'published'),
('00000000-0000-0000-0000-000000000608', 'XP_5000', '五千大师', '累计获得5000经验值', 'manual', '{"xp": 5000}', 'published'),
('00000000-0000-0000-0000-000000000609', 'LEVEL_5', '五级学者', '达到5级', 'manual', '{"level": 5}', 'published'),
('00000000-0000-0000-0000-000000000610', 'LEVEL_10', '十级大师', '达到10级', 'manual', '{"level": 10}', 'published')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 10. LEARNER BADGES (awarded to users)
-- ============================================

INSERT INTO learner_badges (learner_id, badge_id, award_source_type) VALUES
('00000000-0000-0000-0000-000000000020', '00000000-0000-0000-0000-000000000601', 'system'),
('00000000-0000-0000-0000-000000000020', '00000000-0000-0000-0000-000000000602', 'system'),
('00000000-0000-0000-0000-000000000020', '00000000-0000-0000-0000-000000000603', 'system'),
('00000000-0000-0000-0000-000000000020', '00000000-0000-0000-0000-000000000605', 'system'),
('00000000-0000-0000-0000-000000000020', '00000000-0000-0000-0000-000000000607', 'system'),
('00000000-0000-0000-0000-000000000021', '00000000-0000-0000-0000-000000000601', 'system'),
('00000000-0000-0000-0000-000000000021', '00000000-0000-0000-0000-000000000602', 'system'),
('00000000-0000-0000-0000-000000000022', '00000000-0000-0000-0000-000000000601', 'system'),
('00000000-0000-0000-0000-000000000022', '00000000-0000-0000-0000-000000000602', 'system'),
('00000000-0000-0000-0000-000000000022', '00000000-0000-0000-0000-000000000603', 'system'),
('00000000-0000-0000-0000-000000000022', '00000000-0000-0000-0000-000000000604', 'system'),
('00000000-0000-0000-0000-000000000022', '00000000-0000-0000-0000-000000000605', 'system'),
('00000000-0000-0000-0000-000000000022', '00000000-0000-0000-0000-000000000606', 'system'),
('00000000-0000-0000-0000-000000000022', '00000000-0000-0000-0000-000000000607', 'system'),
('00000000-0000-0000-0000-000000000022', '00000000-0000-0000-0000-000000000609', 'system'),
('00000000-0000-0000-0000-000000000028', '00000000-0000-0000-0000-000000000601', 'system'),
('00000000-0000-0000-0000-000000000028', '00000000-0000-0000-0000-000000000602', 'system'),
('00000000-0000-0000-0000-000000000028', '00000000-0000-0000-0000-000000000603', 'system'),
('00000000-0000-0000-0000-000000000028', '00000000-0000-0000-0000-000000000604', 'system'),
('00000000-0000-0000-0000-000000000028', '00000000-0000-0000-0000-000000000607', 'system')
ON CONFLICT (learner_id, badge_id) DO NOTHING;

-- ============================================
-- 11. COURSE PROGRESS
-- ============================================

INSERT INTO course_progress (learner_id, course_id, completed_chapter_count, total_chapter_count, completed_exercise_count, progress_percent, status, started_at) VALUES
('00000000-0000-0000-0000-000000000020', '00000000-0000-0000-0000-000000000101', 4, 4, 6, 100, 'completed', NOW() - INTERVAL '20 days'),
('00000000-0000-0000-0000-000000000020', '00000000-0000-0000-0000-000000000102', 3, 4, 4, 75, 'in_progress', NOW() - INTERVAL '10 days'),
('00000000-0000-0000-0000-000000000021', '00000000-0000-0000-0000-000000000101', 3, 4, 4, 75, 'in_progress', NOW() - INTERVAL '15 days'),
('00000000-0000-0000-0000-000000000022', '00000000-0000-0000-0000-000000000101', 4, 4, 6, 100, 'completed', NOW() - INTERVAL '25 days'),
('00000000-0000-0000-0000-000000000022', '00000000-0000-0000-0000-000000000102', 4, 4, 5, 100, 'completed', NOW() - INTERVAL '18 days'),
('00000000-0000-0000-0000-000000000022', '00000000-0000-0000-0000-000000000103', 2, 3, 2, 67, 'in_progress', NOW() - INTERVAL '5 days'),
('00000000-0000-0000-0000-000000000023', '00000000-0000-0000-0000-000000000101', 2, 4, 2, 50, 'in_progress', NOW() - INTERVAL '8 days'),
('00000000-0000-0000-0000-000000000025', '00000000-0000-0000-0000-000000000101', 4, 4, 6, 100, 'completed', NOW() - INTERVAL '22 days'),
('00000000-0000-0000-0000-000000000025', '00000000-0000-0000-0000-000000000102', 2, 4, 2, 50, 'in_progress', NOW() - INTERVAL '12 days'),
('00000000-0000-0000-0000-000000000028', '00000000-0000-0000-0000-000000000101', 4, 4, 6, 100, 'completed', NOW() - INTERVAL '28 days'),
('00000000-0000-0000-0000-000000000028', '00000000-0000-0000-0000-000000000102', 4, 4, 5, 100, 'completed', NOW() - INTERVAL '20 days'),
('00000000-0000-0000-0000-000000000028', '00000000-0000-0000-0000-000000000103', 3, 3, 3, 100, 'completed', NOW() - INTERVAL '10 days'),
('00000000-0000-0000-0000-000000000028', '00000000-0000-0000-0000-000000000104', 1, 3, 1, 33, 'in_progress', NOW() - INTERVAL '3 days')
ON CONFLICT (learner_id, course_id) DO NOTHING;

-- ============================================
-- 12. SUBMISSIONS (exercise attempts)
-- ============================================

INSERT INTO submissions (id, exercise_id, learner_id, chapter_id, attempt_no, source_code, judge_status, score, passed_case_count, total_case_count, submitted_at, completed_at) VALUES
('00000000-0000-0000-0000-000000000701', '00000000-0000-0000-0000-000000000301', '00000000-0000-0000-0000-000000000020', '00000000-0000-0000-0000-000000000201', 1, '<!DOCTYPE html>\n<html>\n<body>\n<h1>我的主页</h1>\n<p>大家好，我是Alice</p>\n</body>\n</html>', 'passed', 100, 2, 2, NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days'),
('00000000-0000-0000-0000-000000000702', '00000000-0000-0000-0000-000000000303', '00000000-0000-0000-0000-000000000020', '00000000-0000-0000-0000-000000000202', 1, '<h1>一级标题</h1>\n<h2>二级标题</h2>\n<h3>三级标题</h3>', 'passed', 100, 3, 3, NOW() - INTERVAL '19 days', NOW() - INTERVAL '19 days'),
('00000000-0000-0000-0000-000000000703', '00000000-0000-0000-0000-000000000301', '00000000-0000-0000-0000-000000000022', '00000000-0000-0000-0000-000000000201', 1, '<h1>我的主页</h1>\n<p>Charlie的学习页面</p>', 'passed', 100, 2, 2, NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days'),
('00000000-0000-0000-0000-000000000704', '00000000-0000-0000-0000-000000000311', '00000000-0000-0000-0000-000000000022', '00000000-0000-0000-0000-000000000211', 1, '.highlight { background-color: yellow; }', 'passed', 100, 1, 1, NOW() - INTERVAL '18 days', NOW() - INTERVAL '18 days'),
('00000000-0000-0000-0000-000000000705', '00000000-0000-0000-0000-000000000301', '00000000-0000-0000-0000-000000000029', '00000000-0000-0000-0000-000000000201', 1, '<h1>Hello</h1>', 'failed', 50, 1, 2, NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 13. XP LEDGER (experience points history)
-- ============================================

INSERT INTO xp_ledger (learner_id, source_type, source_id, delta_xp, balance_after, created_at) VALUES
('00000000-0000-0000-0000-000000000020', 'chapter', '00000000-0000-0000-0000-000000000201', 50, 50, NOW() - INTERVAL '20 days'),
('00000000-0000-0000-0000-000000000020', 'exercise', '00000000-0000-0000-0000-000000000301', 100, 150, NOW() - INTERVAL '20 days'),
('00000000-0000-0000-0000-000000000020', 'chapter', '00000000-0000-0000-0000-000000000202', 50, 200, NOW() - INTERVAL '19 days'),
('00000000-0000-0000-0000-000000000020', 'exercise', '00000000-0000-0000-0000-000000000303', 100, 300, NOW() - INTERVAL '19 days'),
('00000000-0000-0000-0000-000000000020', 'daily', '00000000-0000-0000-0000-000000000502', 50, 2850, NOW() - INTERVAL '1 day'),
('00000000-0000-0000-0000-000000000022', 'chapter', '00000000-0000-0000-0000-000000000201', 50, 50, NOW() - INTERVAL '25 days'),
('00000000-0000-0000-0000-000000000022', 'exercise', '00000000-0000-0000-0000-000000000301', 100, 150, NOW() - INTERVAL '25 days'),
('00000000-0000-0000-0000-000000000022', 'challenge', '00000000-0000-0000-0000-000000000401', 100, 4150, NOW() - INTERVAL '10 days'),
('00000000-0000-0000-0000-000000000028', 'chapter', '00000000-0000-0000-0000-000000000201', 50, 50, NOW() - INTERVAL '28 days'),
('00000000-0000-0000-0000-000000000028', 'exercise', '00000000-0000-0000-0000-000000000301', 100, 150, NOW() - INTERVAL '28 days'),
('00000000-0000-0000-0000-000000000028', 'daily', '00000000-0000-0000-0000-000000000501', 50, 3200, NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- 14. FRIEND RELATIONS
-- ============================================

INSERT INTO friend_relations (requester_id, addressee_id, status, created_at, responded_at) VALUES
('00000000-0000-0000-0000-000000000020', '00000000-0000-0000-0000-000000000022', 'accepted', NOW() - INTERVAL '20 days', NOW() - INTERVAL '19 days'),
('00000000-0000-0000-0000-000000000020', '00000000-0000-0000-0000-000000000028', 'accepted', NOW() - INTERVAL '15 days', NOW() - INTERVAL '14 days'),
('00000000-0000-0000-0000-000000000021', '00000000-0000-0000-0000-000000000022', 'accepted', NOW() - INTERVAL '18 days', NOW() - INTERVAL '17 days'),
('00000000-0000-0000-0000-000000000022', '00000000-0000-0000-0000-000000000025', 'accepted', NOW() - INTERVAL '16 days', NOW() - INTERVAL '15 days'),
('00000000-0000-0000-0000-000000000023', '00000000-0000-0000-0000-000000000026', 'accepted', NOW() - INTERVAL '10 days', NOW() - INTERVAL '9 days'),
('00000000-0000-0000-0000-000000000028', '00000000-0000-0000-0000-000000000022', 'accepted', NOW() - INTERVAL '12 days', NOW() - INTERVAL '11 days'),
('00000000-0000-0000-0000-000000000029', '00000000-0000-0000-0000-000000000020', 'pending', NOW() - INTERVAL '1 day', NULL)
ON CONFLICT (requester_id, addressee_id) DO NOTHING;

-- ============================================
-- 15. SOCIAL ACTIVITIES
-- ============================================

INSERT INTO social_activities (learner_id, activity_type, visibility, payload_json, created_at) VALUES
('00000000-0000-0000-0000-000000000020', 'course_completed', 'public_in_app', '{"course_title": "HTML基础入门", "summary": "完成了HTML基础课程"}', NOW() - INTERVAL '18 days'),
('00000000-0000-0000-0000-000000000020', 'streak_reached', 'public_in_app', '{"days": 7, "summary": "连续学习7天"}', NOW() - INTERVAL '8 days'),
('00000000-0000-0000-0000-000000000022', 'course_completed', 'public_in_app', '{"course_title": "HTML基础入门", "summary": "完成了HTML基础课程"}', NOW() - INTERVAL '22 days'),
('00000000-0000-0000-0000-000000000022', 'course_completed', 'public_in_app', '{"course_title": "CSS样式基础", "summary": "完成了CSS基础课程"}', NOW() - INTERVAL '15 days'),
('00000000-0000-0000-0000-000000000022', 'challenge_completed', 'public_in_app', '{"challenge_title": "HTML新手挑战", "stars": 3, "summary": "在HTML挑战中获得三星"}', NOW() - INTERVAL '10 days'),
('00000000-0000-0000-0000-000000000022', 'streak_reached', 'public_in_app', '{"days": 14, "summary": "连续学习14天"}', NOW() - INTERVAL '6 days'),
('00000000-0000-0000-0000-000000000028', 'course_completed', 'public_in_app', '{"course_title": "CSS布局进阶", "summary": "完成了CSS布局课程"}', NOW() - INTERVAL '8 days'),
('00000000-0000-0000-0000-000000000028', 'badge_earned', 'public_in_app', '{"badge_name": "两周不辍", "summary": "获得连续学习14天徽章"}', NOW() - INTERVAL '5 days')
ON CONFLICT DO NOTHING;

-- ============================================
-- 16. LEADERBOARD SNAPSHOTS
-- ============================================

INSERT INTO leaderboard_snapshots (board_type, period_key, learner_id, score, rank_position, generated_at) VALUES
('total', 'all', '00000000-0000-0000-0000-000000000022', 4150, 1, NOW()),
('total', 'all', '00000000-0000-0000-0000-000000000028', 3200, 2, NOW()),
('total', 'all', '00000000-0000-0000-0000-000000000020', 2850, 3, NOW()),
('total', 'all', '00000000-0000-0000-0000-000000000025', 2100, 4, NOW()),
('total', 'all', '00000000-0000-0000-0000-000000000021', 1920, 5, NOW()),
('total', 'all', '00000000-0000-0000-0000-000000000027', 1680, 6, NOW()),
('total', 'all', '00000000-0000-0000-0000-000000000026', 1350, 7, NOW()),
('total', 'all', '00000000-0000-0000-0000-000000000023', 980, 8, NOW()),
('total', 'all', '00000000-0000-0000-0000-000000000024', 450, 9, NOW()),
('total', 'all', '00000000-0000-0000-0000-000000000029', 120, 10, NOW()),
('weekly', '2026-W20', '00000000-0000-0000-0000-000000000022', 450, 1, NOW()),
('weekly', '2026-W20', '00000000-0000-0000-0000-000000000028', 380, 2, NOW()),
('weekly', '2026-W20', '00000000-0000-0000-0000-000000000020', 320, 3, NOW())
ON CONFLICT (board_type, period_key, learner_id) DO NOTHING;

-- ============================================
-- 17. CHALLENGE ATTEMPTS
-- ============================================

INSERT INTO challenge_attempts (challenge_id, learner_id, best_star, status, started_at, completed_at, reward_claimed_at) VALUES
('00000000-0000-0000-0000-000000000401', '00000000-0000-0000-0000-000000000020', 3, 'completed', NOW() - INTERVAL '18 days', NOW() - INTERVAL '18 days', NOW() - INTERVAL '18 days'),
('00000000-0000-0000-0000-000000000401', '00000000-0000-0000-0000-000000000022', 3, 'completed', NOW() - INTERVAL '22 days', NOW() - INTERVAL '22 days', NOW() - INTERVAL '22 days'),
('00000000-0000-0000-0000-000000000402', '00000000-0000-0000-0000-000000000022', 2, 'completed', NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days'),
('00000000-0000-0000-0000-000000000403', '00000000-0000-0000-0000-000000000022', 3, 'completed', NOW() - INTERVAL '12 days', NOW() - INTERVAL '12 days', NOW() - INTERVAL '12 days'),
('00000000-0000-0000-0000-000000000401', '00000000-0000-0000-0000-000000000028', 3, 'completed', NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days'),
('00000000-0000-0000-0000-000000000401', '00000000-0000-0000-0000-000000000025', 2, 'completed', NOW() - INTERVAL '16 days', NOW() - INTERVAL '16 days', NOW() - INTERVAL '16 days')
ON CONFLICT (challenge_id, learner_id) DO NOTHING;

-- ============================================
-- 18. DAILY CHALLENGE RECORDS
-- ============================================

INSERT INTO daily_challenge_records (daily_challenge_id, learner_id, status, score, elapsed_seconds, streak_after_completion, completed_at) VALUES
('00000000-0000-0000-0000-000000000502', '00000000-0000-0000-0000-000000000020', 'passed', 100, 180, 15, NOW() - INTERVAL '1 day'),
('00000000-0000-0000-0000-000000000503', '00000000-0000-0000-0000-000000000020', 'passed', 90, 200, 14, NOW() - INTERVAL '2 days'),
('00000000-0000-0000-0000-000000000504', '00000000-0000-0000-0000-000000000020', 'passed', 85, 220, 13, NOW() - INTERVAL '3 days'),
('00000000-0000-0000-0000-000000000502', '00000000-0000-0000-0000-000000000022', 'passed', 100, 150, 22, NOW() - INTERVAL '1 day'),
('00000000-0000-0000-0000-000000000503', '00000000-0000-0000-0000-000000000022', 'passed', 100, 160, 21, NOW() - INTERVAL '2 days'),
('00000000-0000-0000-0000-000000000502', '00000000-0000-0000-0000-000000000028', 'passed', 95, 190, 18, NOW() - INTERVAL '1 day'),
('00000000-0000-0000-0000-000000000501', '00000000-0000-0000-0000-000000000029', 'failed', 40, 300, 0, NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- 19. AI HELP REQUESTS
-- ============================================

INSERT INTO ai_help_requests (id, learner_id, exercise_id, submission_id, request_type, source_code, response_text, provider_name, status, created_at) VALUES
('00000000-0000-0000-0000-000000000801', '00000000-0000-0000-0000-000000000029', '00000000-0000-0000-0000-000000000301', '00000000-0000-0000-0000-000000000705', 'hint', '<h1>Hello</h1>', '请检查你的代码是否包含了p标签来添加自我介绍内容。题目要求使用p标签创建一段自我介绍。', 'deepseek-chat', 'succeeded', NOW() - INTERVAL '3 days')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 20. ANNOUNCEMENTS
-- ============================================

INSERT INTO announcements (id, title, body_markdown, audience, status, published_at, expires_at, created_by) VALUES
('00000000-0000-0000-0000-000000000901', '欢迎来到CodeQuest', '欢迎使用CodeQuest学习平台！在这里你可以学习HTML、CSS等前端技术。', 'all_learners', 'published', NOW() - INTERVAL '30 days', NOW() + INTERVAL '30 days', '00000000-0000-0000-0000-000000000010'),
('00000000-0000-0000-0000-000000000902', '新课程上线', 'CSS布局进阶课程已上线，快来学习Flexbox和Grid布局吧！', 'all_learners', 'published', NOW() - INTERVAL '20 days', NOW() + INTERVAL '10 days', '00000000-0000-0000-0000-000000000010'),
('00000000-0000-0000-0000-000000000903', '每日挑战开启', '每日挑战功能已上线，每天完成挑战可以获得额外经验值！', 'all_learners', 'published', NOW() - INTERVAL '7 days', NOW() + INTERVAL '60 days', '00000000-0000-0000-0000-000000000010')
ON CONFLICT (id) DO NOTHING;

-- Update learner_profiles with correct friend counts
UPDATE learner_profiles SET friend_count = (
    SELECT COUNT(*) FROM friend_relations 
    WHERE (requester_id = learner_profiles.account_id OR addressee_id = learner_profiles.account_id) 
    AND status = 'accepted'
) WHERE account_id IN (
    '00000000-0000-0000-0000-000000000020',
    '00000000-0000-0000-0000-000000000021',
    '00000000-0000-0000-0000-000000000022',
    '00000000-0000-0000-0000-000000000023',
    '00000000-0000-0000-0000-000000000025',
    '00000000-0000-0000-0000-000000000026',
    '00000000-0000-0000-0000-000000000028',
    '00000000-0000-0000-0000-000000000029'
);
