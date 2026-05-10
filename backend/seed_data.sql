--
-- PostgreSQL database dump
--

\restrict YT4Cikz5xV2xOww5TPbgiQdY3MAgkdslfbCRaLq8EYb3mL0K0oU12g2mqh8vEwq

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: _sqlx_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public._sqlx_migrations VALUES (1, 'initial schema', '2026-05-10 21:35:28.156781+08', true, '\x0c77030138006641c4ac0090052f2c1d1cc6a10edfff0c690becf36f8af5f26d78b6998ebe1c5a7be800a0de97c9d33a', 117488000);
INSERT INTO public._sqlx_migrations VALUES (2, 'increase refresh token length', '2026-05-10 21:35:28.279807+08', true, '\x1c268ec66fa735bf3dafac722c5ad8dc9ff8df12cc9ea3f7670e3af1259695f038318eddb75caf6773e8153f507b6da2', 3799768);
INSERT INTO public._sqlx_migrations VALUES (3, 'add performance indexes', '2026-05-10 21:35:28.285852+08', true, '\x70b76069df2ccb810b420a506ecfe00730a31cdfabe318ebde5818d4270ddb059e7151c469284b52e9d29f49d0003068', 8052955);
INSERT INTO public._sqlx_migrations VALUES (4, 'feedback moderation', '2026-05-10 21:35:28.297804+08', true, '\x345a250025fd188df556aee11804250a03992339af48c1494c5bcba782c2e0e6152fdd6da5162bf2eead0e7a5866fd78', 3975203);


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.accounts VALUES ('5d036eff-e26b-4782-a8f0-eefa53038c58', 'test@example.com', '$2b$12$hebfdgyJ3ICODGdm7N9oNOhhGnC0e9xBfV9uZ/DwPLtECP1gcwYju', 'learner', 'active', '2026-05-11 02:53:57.372715+08', '2026-05-11 02:53:57.312432+08', '2026-05-11 02:53:57.372715+08');
INSERT INTO public.accounts VALUES ('f2cedc3c-6bb6-460e-9a07-1467d8530399', 'admin2@codequest.dev', '$2b$12$wffKd08aFBRNzFhALE7sx.iUV4iM3R37pyafuUdpry.yV8svDAHc2', 'learner', 'active', '2026-05-11 02:54:45.786904+08', '2026-05-11 02:54:45.724401+08', '2026-05-11 02:54:45.786904+08');
INSERT INTO public.accounts VALUES ('ae44b7e0-600f-4743-9ad4-7a1e59734e3c', 'learner2@codequest.dev', '$2b$12$bNycS6ztZjmuTyCYl44q3elRez6I68YNv3GulBpd/79S2TZCceqmu', 'learner', 'active', '2026-05-11 04:24:44.730286+08', '2026-05-11 04:24:44.672947+08', '2026-05-11 04:24:44.730286+08');
INSERT INTO public.accounts VALUES ('6392737f-e239-45ac-b472-b74f35f25a12', 'test2@example.com', '$2b$12$RlM5vUHuMDjK4DbndoNS9uZgfUA/7qkTGKsnZNGE9vpvO3et9aute', 'learner', 'active', '2026-05-11 04:27:07.402709+08', '2026-05-11 03:51:21.872866+08', '2026-05-11 04:27:07.402709+08');
INSERT INTO public.accounts VALUES ('94fdf828-ccfb-436d-9683-8dbbd5000da5', 'admin@codequest.dev', '$2b$12$wffKd08aFBRNzFhALE7sx.iUV4iM3R37pyafuUdpry.yV8svDAHc2', 'admin', 'active', '2026-05-11 04:28:05.380294+08', '2026-05-10 23:31:11.476137+08', '2026-05-11 04:28:05.380294+08');
INSERT INTO public.accounts VALUES ('48eb082f-53d8-4929-b107-10b3b296fa6d', 'learner2@example.com', '$2b$12$bNycS6ztZjmuTyCYl44q3elRez6I68YNv3GulBpd/79S2TZCceqmu', 'learner', 'active', '2026-05-11 04:28:41.716396+08', '2026-05-10 23:31:11.478796+08', '2026-05-11 04:28:41.716396+08');
INSERT INTO public.accounts VALUES ('22a2c7da-e77f-4a25-b79e-b3deed9ad839', 'learner3@example.com', '$2b$12$bNycS6ztZjmuTyCYl44q3elRez6I68YNv3GulBpd/79S2TZCceqmu', 'learner', 'active', '2026-05-11 04:28:45.095596+08', '2026-05-10 23:31:11.478796+08', '2026-05-11 04:28:45.095596+08');
INSERT INTO public.accounts VALUES ('e3e99fda-c2ea-4170-a5a7-d30c1a95531d', 'learner1@example.com', '$2b$12$bNycS6ztZjmuTyCYl44q3elRez6I68YNv3GulBpd/79S2TZCceqmu', 'learner', 'active', '2026-05-11 04:29:04.819496+08', '2026-05-10 23:31:11.478796+08', '2026-05-11 04:29:04.819496+08');


--
-- Data for Name: account_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.account_roles VALUES ('a2dfef91-b30f-4d88-bc9b-0544175f889d', '94fdf828-ccfb-436d-9683-8dbbd5000da5', 'admin', 'enabled', '2026-05-10 23:31:11.488696+08', NULL);
INSERT INTO public.account_roles VALUES ('3cf9f5a6-d390-4706-a498-1963bcb9b167', '94fdf828-ccfb-436d-9683-8dbbd5000da5', 'learner', 'enabled', '2026-05-10 23:31:11.488696+08', NULL);
INSERT INTO public.account_roles VALUES ('66e18af0-4879-4e25-b5a9-8c3a148baf86', 'e3e99fda-c2ea-4170-a5a7-d30c1a95531d', 'learner', 'enabled', '2026-05-10 23:31:11.488696+08', NULL);
INSERT INTO public.account_roles VALUES ('e121e596-f9d9-42f1-b734-04e8b48324fd', '48eb082f-53d8-4929-b107-10b3b296fa6d', 'learner', 'enabled', '2026-05-10 23:31:11.488696+08', NULL);
INSERT INTO public.account_roles VALUES ('73c56187-3372-4a9d-b9af-91fd3c39854a', '22a2c7da-e77f-4a25-b79e-b3deed9ad839', 'learner', 'enabled', '2026-05-10 23:31:11.488696+08', NULL);


--
-- Data for Name: admin_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.admin_profiles VALUES ('94fdf828-ccfb-436d-9683-8dbbd5000da5', '系统管理员', NULL, 'enabled', NULL, '2026-05-10 23:31:11.480723+08', '2026-05-10 23:31:11.480723+08');


--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.courses VALUES ('4b73f529-755c-41ab-876d-12d148b05149', 'html-basics', 'HTML 基础入门', '从零基础学习 HTML，掌握网页标记语言的核心语法、语义化标签和表单构建', '本课程基于 MDN Web Docs 官方学习路径，系统讲解 HTML5 的核心概念。你将从最简单的文档结构开始，逐步学习文本处理、超链接、图片多媒体、表格和表单等完整内容。课程包含大量编码练习和选择题，帮助你建立扎实的 HTML 基础。', NULL, 'beginner', 180, 'published', 0, 1, '94fdf828-ccfb-436d-9683-8dbbd5000da5', '2026-05-11 03:07:51.116731+08', '2026-05-10 23:31:11.494987+08', '2026-05-11 03:07:51.116731+08');
INSERT INTO public.courses VALUES ('6e4b7972-943e-443e-a502-e7e2a8c338b7', 'css-basics', 'CSS 样式基础', '掌握 CSS 选择器、盒模型、颜色、字体和背景等核心样式技能', '本课程基于 MDN CSS 学习路径，系统讲解 CSS 的核心概念。你将学习如何选择元素、理解盒模型、设置颜色和字体、控制背景和边框等。课程采用理论与实践结合的方式，通过大量编码练习帮助你建立扎实的 CSS 基础。', NULL, 'beginner', 200, 'published', 0, 1, '94fdf828-ccfb-436d-9683-8dbbd5000da5', '2026-05-11 03:07:51.116731+08', '2026-05-10 23:31:11.494987+08', '2026-05-11 03:07:51.116731+08');
INSERT INTO public.courses VALUES ('68eeb1fe-fe3d-4669-b98c-fb1815316739', 'css-layout', 'CSS 布局精通', '深入学习 Flexbox 弹性布局和 Grid 网格布局，掌握响应式设计', '本课程专注于 CSS 现代布局技术，系统讲解 Flexbox 和 CSS Grid 两种强大的布局方式。你将学习如何使用 Flexbox 处理一维布局，使用 Grid 处理二维布局，以及如何通过媒体查询实现响应式设计。课程包含大量实战练习，帮助你成为 CSS 布局高手。', NULL, 'intermediate', 220, 'published', 0, 1, '94fdf828-ccfb-436d-9683-8dbbd5000da5', '2026-05-11 03:07:51.116731+08', '2026-05-10 23:31:11.494987+08', '2026-05-11 03:07:51.116731+08');
INSERT INTO public.courses VALUES ('e1b4e11d-a8cd-4ac6-bb63-0179f2d337fc', 'js-basics', 'JavaScript 基础入门', '掌握 JavaScript 核心语法，从变量函数到 DOM 操作与事件处理', '本课程基于 MDN JavaScript 学习路径，系统讲解 JS 的核心概念。你将学习变量与数据类型、运算符、条件循环、函数、数组、对象等基础语法，最终掌握 DOM 操作和事件处理，为网页添加交互功能。课程包含丰富的编码练习和选择题，帮助你建立扎实的 JavaScript 编程基础。', NULL, 'beginner', 240, 'published', 0, 1, '94fdf828-ccfb-436d-9683-8dbbd5000da5', '2026-05-11 03:07:51.116731+08', '2026-05-10 23:31:11.494987+08', '2026-05-11 03:07:51.116731+08');


--
-- Data for Name: chapters; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.chapters VALUES ('fa69b96b-c26a-4ae0-b2d1-d6a960dfb7ed', '4b73f529-755c-41ab-876d-12d148b05149', 'html-ch1-doc-structure', 'HTML 文档结构', '学习 HTML 基础语法、文档类型声明和页面基本结构', '# HTML 文档结构

## 什么是 HTML

HTML（HyperText Markup Language，超文本标记语言）是构建 Web 的标准标记语言。它由一系列**元素（elements）**组成，用于描述网页的结构和内容。

## HTML 元素的剖析

一个完整的 HTML 元素通常包含：
- **开始标签**：如 `<p>`
- **内容**：标签之间的文本或其他内容
- **结束标签**：如 `</p>`

```html
<p>这是一个段落元素</p>
```

**空元素**（void elements）不需要结束标签，如 `<img>`、`<br>`、`<input>`。

## HTML 属性

属性为元素提供额外信息：
```html
<a href="https://example.com">链接文本</a>
<img src="photo.jpg" alt="描述文字">
```

属性语法：`name="value"`。布尔属性如 `disabled`、`required` 无需值。

## HTML 文档基本结构

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>页面标题</title>
</head>
<body>
    <!-- 可见内容放在这里 -->
</body>
</html>
```

## head 中的元信息

- `<title>`：页面标题，显示在浏览器标签页
- `<meta charset="UTF-8">`：字符编码
- `<meta name="description">`：页面描述，用于 SEO
- `<meta name="viewport">`：响应式视口设置
- `<link rel="stylesheet">`：引入 CSS 文件', NULL, 25, 0, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('3710dfb3-b172-4a3c-9ba3-0301822867ce', '4b73f529-755c-41ab-876d-12d148b05149', 'html-ch2-text-formatting', '文本处理与格式', '掌握标题、段落、列表和文本强调元素的使用', '# 文本处理与格式

## 标题元素 h1 ~ h6

HTML 提供六级标题，h1 为最高级别，h6 为最低。每个页面应只使用一个 h1。

```html
<h1>主标题（文章标题）</h1>
<h2>二级标题（章节标题）</h2>
<h3>三级标题（小节标题）</h3>
```

## 段落 p

```html
<p>这是一个段落。浏览器会自动在段落之间添加间距。</p>
```

## 强调元素

- `<strong>`：表示强烈重要性（默认粗体）
- `<em>`：表示强调（默认斜体）
- `<b>` / `<i>`：仅视觉样式，无语义

```html
<p><strong>警告：</strong>请勿在 <em>生产环境</em> 中调试代码。</p>
```

## 列表

**无序列表**（项目符号）：
```html
<ul>
  <li>HTML</li>
  <li>CSS</li>
  <li>JavaScript</li>
</ul>
```

**有序列表**（编号）：
```html
<ol>
  <li>第一步：安装编辑器</li>
  <li>第二步：创建项目文件夹</li>
  <li>第三步：编写代码</li>
</ol>
```

**定义列表**：
```html
<dl>
  <dt>HTML</dt><dd>超文本标记语言</dd>
  <dt>CSS</dt><dd>层叠样式表</dd>
</dl>
```

## 其他文本元素

- `<mark>`：高亮标记文本
- `<small>`：小号字体/法律声明
- `<sub>` / `<sup>`：下标/上标
- `<del>` / `<ins>`：删除/插入文本
- `<code>`：行内代码
- `<pre>`：预格式化文本
- `<blockquote>`：块级引用', NULL, 20, 1, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('b40f8541-b062-42ca-8845-617fa4042a0a', '4b73f529-755c-41ab-876d-12d148b05149', 'html-ch3-semantic', '语义化与文档结构', '学习语义化 HTML5 标签和页面区域划分', '# 语义化与文档结构

## 为什么要语义化

语义化 HTML 指的是使用恰当的标签来描述内容的含义，而非仅仅关注视觉效果。语义化的好处：

- **可访问性**：屏幕阅读器能正确解读页面结构
- **SEO**：搜索引擎更容易理解页面内容
- **维护性**：代码更易读、更易维护

## HTML5 语义化结构元素

```html
<body>
  <header>
    <h1>网站标题</h1>
    <nav>
      <ul>
        <li><a href="/">首页</a></li>
        <li><a href="/about">关于</a></li>
      </ul>
    </nav>
  </header>

  <main>
    <article>
      <header>
        <h2>文章标题</h2>
        <time datetime="2025-01-15">2025年1月15日</time>
      </header>
      <section>
        <h3>第一节</h3>
        <p>内容...</p>
      </section>
      <section>
        <h3>第二节</h3>
        <p>内容...</p>
      </section>
    </article>

    <aside>
      <h3>相关推荐</h3>
      <ul>...</ul>
    </aside>
  </main>

  <footer>
    <p>&copy; 2025 我的网站</p>
  </footer>
</body>
```

## 语义化元素详解

| 元素 | 用途 |
|------|------|
| `<header>` | 页面或区块的头部，通常包含标题和导航 |
| `<nav>` | 导航链接区域 |
| `<main>` | 页面主要内容（每个页面仅一个） |
| `<article>` | 独立可复用的内容块，如博客文章 |
| `<section>` | 文档中的主题性分组 |
| `<aside>` | 侧边栏或间接相关内容 |
| `<footer>` | 页面或区块的底部 |
| `<time>` | 日期/时间，datetime 属性提供机器可读格式 |

## div vs 语义化标签

- `<div>`：无语义，仅作为通用容器
- 语义化标签：有明确含义，优先使用
- 仅在无合适语义标签时使用 div', NULL, 25, 2, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('5b39d870-b8e5-426d-a128-d598968ab6d5', '4b73f529-755c-41ab-876d-12d148b05149', 'html-ch4-links-images', '超链接与图片', '学习创建超链接、导航菜单和插入图片', '# 超链接与图片

## 创建超链接

使用 `<a>` 标签创建超链接：

```html
<!-- 链接到其他页面 -->
<a href="https://developer.mozilla.org">MDN Web Docs</a>

<!-- 链接到页面内锚点 -->
<a href="#section2">跳转到第二节</a>
<section id="section2">...</section>

<!-- 邮件链接 -->
<a href="mailto:contact@example.com">发送邮件</a>

<!-- 电话链接 -->
<a href="tel:+8613800138000">拨打电话</a>
```

## 链接属性

| 属性 | 说明 |
|------|------|
| `href` | 目标地址（必需） |
| `target="_blank"` | 在新标签页打开 |
| `rel="noopener noreferrer"` | 安全属性，配合 target="_blank" 使用 |
| `download` | 提示下载链接目标 |

## 图片 img

```html
<img src="photo.jpg" alt="照片描述" width="400" height="300">
```

**重要属性**：
- `src`：图片路径（必需）
- `alt`：替代文本（必需，用于可访问性和图片加载失败时）
- `width` / `height`：尺寸（建议设置防止布局偏移）

## 响应式图片

```html
<picture>
  <source srcset="large.jpg" media="(min-width: 800px)">
  <source srcset="medium.jpg" media="(min-width: 400px)">
  <img src="small.jpg" alt="响应式图片">
</picture>
```

## 导航菜单

使用 nav 包裹导航链接：

```html
<nav>
  <ul>
    <li><a href="/">首页</a></li>
    <li><a href="/about">关于我们</a></li>
    <li><a href="/contact">联系方式</a></li>
  </ul>
</nav>
```

## 图片格式

| 格式 | 特点 | 适用场景 |
|------|------|----------|
| JPEG | 有损压缩，文件小 | 照片 |
| PNG | 支持透明，无损 | 图标、截图 |
| WebP | 压缩率高，现代格式 | 推荐用于 Web |
| SVG | 矢量，缩放不失真 | 图标、Logo |', NULL, 20, 3, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('ed1f58bb-0056-42e2-aae2-92c01d032cf8', '4b73f529-755c-41ab-876d-12d148b05149', 'html-ch5-tables', '表格基础', '学习创建语义化的 HTML 表格', '# 表格基础

## 基本表格结构

```html
<table>
  <caption>学生成绩表</caption>
  <thead>
    <tr>
      <th scope="col">姓名</th>
      <th scope="col">数学</th>
      <th scope="col">英语</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">张三</th>
      <td>90</td>
      <td>85</td>
    </tr>
    <tr>
      <th scope="row">李四</th>
      <td>78</td>
      <td>92</td>
    </tr>
  </tbody>
</table>
```

## 表格元素

| 元素 | 说明 |
|------|------|
| `<table>` | 表格容器 |
| `<caption>` | 表格标题 |
| `<thead>` | 表头区域 |
| `<tbody>` | 表体区域 |
| `<tfoot>` | 表尾区域（可选） |
| `<tr>` | 表格行 |
| `<th>` | 表头单元格（默认粗体居中） |
| `<td>` | 数据单元格 |

## 表格属性

- `colspan`：跨列合并
- `rowspan`：跨行合并
- `scope="col/row"`：表头作用范围（可访问性）

## 表格最佳实践

1. 始终使用 caption 描述表格内容
2. 使用 thead/tbody 分区
3. 为 th 添加 scope 属性
4. **不要使用表格进行页面布局**，应使用 CSS Flexbox/Grid', NULL, 15, 4, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('e2423900-0c96-460b-91ab-84e09ee6d8af', '4b73f529-755c-41ab-876d-12d148b05149', 'html-ch6-forms', '表单与输入控件', '掌握 HTML 表单元素、输入类型和客户端验证', '# 表单与输入控件

## form 元素

```html
<form action="/submit" method="POST">
  <!-- 表单控件放在这里 -->
</form>
```

- `action`：表单提交目标 URL
- `method`：HTTP 方法（GET 或 POST）

## 常用 input 类型

```html
<!-- 文本输入 -->
<input type="text" name="username" placeholder="请输入用户名">

<!-- 邮箱（自动验证格式） -->
<input type="email" name="email" required>

<!-- 密码（隐藏输入） -->
<input type="password" name="password" minlength="8">

<!-- 数字 -->
<input type="number" name="age" min="1" max="120">

<!-- 日期 -->
<input type="date" name="birthday">

<!-- 复选框 -->
<input type="checkbox" name="hobby" value="reading"> 阅读
<input type="checkbox" name="hobby" value="sports"> 运动

<!-- 单选按钮 -->
<input type="radio" name="gender" value="male"> 男
<input type="radio" name="gender" value="female"> 女
```

## label 元素

label 用于描述表单控件，提升可访问性：

```html
<label for="username">用户名：</label>
<input type="text" id="username" name="username">

<!-- 或使用隐式关联 -->
<label>
  <input type="checkbox" name="agree"> 我同意服务条款
</label>
```

## 其他表单控件

```html
<!-- 下拉选择 -->
<select name="city">
  <option value="">请选择城市</option>
  <option value="beijing">北京</option>
  <option value="shanghai">上海</option>
</select>

<!-- 多行文本 -->
<textarea name="message" rows="4" cols="50" placeholder="请输入留言..."></textarea>

<!-- 按钮 -->
<button type="submit">提交</button>
<button type="reset">重置</button>
<button type="button">普通按钮</button>
```

## 表单验证属性

| 属性 | 说明 |
|------|------|
| `required` | 必填字段 |
| `minlength` / `maxlength` | 字符长度限制 |
| `min` / `max` | 数值范围 |
| `pattern` | 正则表达式验证 |
| `placeholder` | 输入提示 |

```html
<input type="text" pattern="[A-Za-z]{3}" title="三个字母">
```', NULL, 30, 5, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('2dd916e9-6662-473d-b07d-2c983ad677a0', '6e4b7972-943e-443e-a502-e7e2a8c338b7', 'css-ch1-selectors', 'CSS 选择器与优先级', '学习基础选择器、组合器和选择器优先级的计算', '# CSS 选择器与优先级

## 什么是 CSS

CSS（Cascading Style Sheets，层叠样式表）用于控制 HTML 元素的视觉呈现，实现了内容（HTML）与表现（CSS）的分离。

```css
/* 选择器 { 属性: 值; } */
h1 {
  color: blue;
  font-size: 24px;
}
```

## CSS 引入方式

1. **外部样式表**（推荐）：`<link rel="stylesheet" href="style.css">`
2. **内部样式表**：`<style>` 标签
3. **内联样式**：`style` 属性（不推荐，优先级最高）

## 基础选择器

```css
/* 元素选择器 */
p { color: black; }

/* 类选择器 */
.highlight { background-color: yellow; }

/* ID 选择器 */
#header { height: 60px; }

/* 通用选择器 */
* { margin: 0; padding: 0; }
```

## 关系选择器（组合器）

```css
/* 后代选择器：nav 内的所有 a */
nav a { text-decoration: none; }

/* 子选择器：ul 的直接子元素 li */
ul > li { list-style: none; }

/* 相邻兄弟选择器：紧跟 h2 的第一个 p */
h2 + p { font-weight: bold; }

/* 通用兄弟选择器：h2 之后的所有 p */
h2 ~ p { color: gray; }
```

## 伪类

```css
/* 链接状态 */
a:link { color: blue; }      /* 未访问 */
a:visited { color: purple; } /* 已访问 */
a:hover { color: red; }      /* 悬停 */
a:active { color: green; }   /* 激活 */

/* 结构伪类 */
li:first-child { font-weight: bold; }
li:last-child { color: gray; }
li:nth-child(odd) { background: #f5f5f5; }

/* 表单伪类 */
input:focus { outline: 2px solid blue; }
input:valid { border-color: green; }
input:invalid { border-color: red; }
```

## 伪元素

```css
/* 在元素前后插入内容 */
.quote::before { content: ''"''; }
.quote::after { content: ''"''; }

/* 首行/首字 */
p::first-line { font-weight: bold; }
p::first-letter { font-size: 2em; }
```

## 选择器优先级（Specificity）

优先级权重计算：`行内 > ID > 类/伪类/属性 > 元素/伪元素`

| 选择器 | 权重值 |
|--------|--------|
| `p` | 0-0-1 |
| `.nav` | 0-1-0 |
| `#logo` | 1-0-0 |
| `#nav .item a:hover` | 1-2-1 |

!important 可覆盖所有规则，应谨慎使用。', NULL, 25, 0, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('6c7b3f65-f05e-4e29-80fd-fe200f9eb7cd', '6e4b7972-943e-443e-a502-e7e2a8c338b7', 'css-ch2-box-model', 'CSS 盒模型', '深入理解盒模型、box-sizing 和常见布局模式', '# CSS 盒模型

## 盒模型的组成

每个 HTML 元素都可以看作一个盒子，由以下部分组成：

```
┌─────────────────────────────┐
│          Margin（外边距）     │  ← 盒子与其他盒子之间的距离
│   ┌─────────────────────┐   │
│   │     Border（边框）   │   │  ← 盒子的边界
│   │   ┌─────────────┐   │   │
│   │   │  Padding（内边距）│   │   │  ← 内容与边框之间的距离
│   │   │   ┌─────┐   │   │   │
│   │   │   │Content│   │   │   │  ← 实际内容区域
│   │   │   └─────┘   │   │   │
│   │   └─────────────┘   │   │
│   └─────────────────────┘   │
└─────────────────────────────┘
```

## 尺寸计算

默认情况下（content-box）：
```
总宽度 = width + padding-left + padding-right + border-left + border-right + margin-left + margin-right
总高度 = height + padding-top + padding-bottom + border-top + border-bottom + margin-top + margin-bottom
```

## box-sizing

```css
/* 默认值：width/height 只包含 content */
.box1 { box-sizing: content-box; }

/* 推荐值：width/height 包含 content + padding + border */
.box2 { box-sizing: border-box; }
```

**推荐使用 border-box**，这样设置 width 就是最终可见宽度。

```css
/* 全局设置 */
*, *::before, *::after {
  box-sizing: border-box;
}
```

## margin 和 padding

```css
.box {
  /* 四个方向相同 */
  margin: 20px;
  padding: 10px;

  /* 上下 | 左右 */
  margin: 10px 20px;

  /* 上 | 右 | 下 | 左 */
  padding: 10px 15px 10px 15px;

  /* 单独设置 */
  margin-top: 10px;
  padding-left: 20px;
}
```

## 边框

```css
.border-demo {
  border-width: 2px;
  border-style: solid;   /* solid | dashed | dotted | double */
  border-color: #333;

  /* 简写 */
  border: 2px solid #333;

  /* 单独设置边 */
  border-top: 1px dashed red;

  /* 圆角 */
  border-radius: 8px;        /* 四个角 */
  border-radius: 8px 16px;   /* 左上右下 | 右上左下 */

  /* 圆形 */
  border-radius: 50%;
}
```

## margin 塌陷

垂直相邻的两个块级元素，margin 会合并（取最大值）：

```html
<style>
  .box1 { margin-bottom: 20px; }
  .box2 { margin-top: 30px; }  /* 实际间距是 30px，不是 50px */
</style>
<div class="box1">Box 1</div>
<div class="box2">Box 2</div>
```

**解决方法**：使用 padding 代替 margin，或创建 BFC。', NULL, 25, 1, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('63d43de0-7bfd-4ea8-82a6-cad76000309c', '6e4b7972-943e-443e-a502-e7e2a8c338b7', 'css-ch3-text-font', '文字样式与排版', '学习字体、颜色、行高和文字装饰等排版属性', '# 文字样式与排版

## 颜色设置

```css
/* 颜色名称 */
h1 { color: red; }

/* 十六进制 */
p { color: #333333; }  /* 可简写为 #333 */
a { color: #3498db; }

/* RGB / RGBA */
.button {
  color: rgb(52, 152, 219);
  background-color: rgba(52, 152, 219, 0.1);  /* 10% 不透明度 */
}

/* HSL / HSLA */
.alert {
  color: hsl(0, 80%, 50%);
  background-color: hsla(0, 80%, 50%, 0.1);
}
```

## 字体设置

```css
body {
  /* 字体栈：优先使用前面的字体 */
  font-family: -apple-system, BlinkMacSystemFont, ''Segoe UI'', Roboto,
               ''Helvetica Neue'', Arial, sans-serif;

  /* 字体大小 */
  font-size: 16px;

  /* 行高：无单位数值是相对于字体大小的倍数 */
  line-height: 1.6;

  /* 字体粗细 */
  font-weight: 400;  /* normal = 400, bold = 700 */

  /* 字体样式 */
  font-style: italic;
}
```

## 文本对齐与装饰

```css
.text-demo {
  /* 对齐方式 */
  text-align: center;  /* left | right | center | justify */

  /* 文字装饰 */
  text-decoration: none;      /* underline | overline | line-through */

  /* 文字转换 */
  text-transform: uppercase;  /* lowercase | capitalize */

  /* 文字阴影 */
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
  /* 水平偏移 垂直偏移 模糊半径 颜色 */

  /* 字母/单词间距 */
  letter-spacing: 1px;
  word-spacing: 2px;
}
```

## 单位

### 绝对单位
- `px`：像素，最常用的单位

### 相对单位
- `em`：相对于父元素的字体大小
- `rem`：相对于根元素（html）的字体大小，推荐用于字体
- `%`：相对于父元素的百分比
- `vw` / `vh`：视口宽度/高度的百分比

```css
html { font-size: 16px; }
.parent { font-size: 20px; }

.em-demo {
  font-size: 1.5em;    /* 相对于父元素 = 30px */
  padding: 1em;        /* 30px */
}

.rem-demo {
  font-size: 1.25rem;  /* 相对于根元素 = 20px */
  margin: 1rem;        /* 16px */
}
```

## font 简写

```css
/* font: style weight size/line-height family */
.title {
  font: italic 700 24px/1.5 Arial, sans-serif;
}
```

## Google Fonts 使用

```html
<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
```

```css
body {
  font-family: ''Roboto'', sans-serif;
}
```', NULL, 20, 2, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('52f87a47-445e-45b3-83c8-7b96f37a883e', '6e4b7972-943e-443e-a502-e7e2a8c338b7', 'css-ch4-background-border', '背景与边框效果', '学习背景颜色、图片、渐变和边框效果的实现', '# 背景与边框效果

## 背景颜色

```css
.box {
  background-color: #f5f5f5;
  background-color: rgba(0, 0, 0, 0.05);
}
```

## 背景图片

```css
.hero {
  /* 图片地址 */
  background-image: url(''bg.jpg'');

  /* 不重复 */
  background-repeat: no-repeat;  /* repeat | repeat-x | repeat-y */

  /* 图片位置 */
  background-position: center;    /* top | bottom | left | right | center */

  /* 图片大小 */
  background-size: cover;         /* contain | cover | 100% 100% */

  /* 简写 */
  background: url(''bg.jpg'') no-repeat center/cover;
}
```

## 渐变背景

```css
/* 线性渐变 */
.gradient-1 {
  background: linear-gradient(to right, #3498db, #2ecc71);
}

.gradient-2 {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

/* 多色渐变 */
.gradient-3 {
  background: linear-gradient(to right, red, yellow, green);
}

/* 径向渐变 */
.radial {
  background: radial-gradient(circle, #fff, #ddd);
}
```

## 边框进阶

```css
.border-advanced {
  /* 分别设置四个角 */
  border-radius: 10px 20px 30px 40px;
  /* 左上 右上 右下 左下 */

  /* 椭圆角 */
  border-radius: 50% 20% / 10% 40%;
}

/* 圆形头像 */
.avatar {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  object-fit: cover;
}

/* 圆角按钮 */
.btn {
  padding: 10px 24px;
  border: none;
  border-radius: 25px;  /* 药丸形状 */
  background: linear-gradient(to right, #3498db, #2980b9);
  color: white;
  cursor: pointer;
}
```

## 阴影效果

```css
/* 盒子阴影 */
.card {
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  /* 水平偏移 垂直偏移 模糊半径 扩散半径 颜色 */
}

.card-hover:hover {
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
}

/* 多层阴影 */
.layered {
  box-shadow: 
    0 1px 2px rgba(0,0,0,0.1),
    0 4px 8px rgba(0,0,0,0.1),
    0 8px 16px rgba(0,0,0,0.1);
}

/* 内阴影 */
.inset {
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.1);
}
```

## outline 轮廓

```css
input:focus {
  outline: 2px solid #3498db;
  outline-offset: 2px;  /* 轮廓与边框的距离 */
}
```

outline 不占据空间，不影响布局。', NULL, 25, 3, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('d31949c6-3603-48ce-9cad-a4a4bf71186c', '6e4b7972-943e-443e-a502-e7e2a8c338b7', 'css-ch5-positioning', '定位与层叠', '掌握 position 属性和 z-index 层叠控制', '# 定位与层叠

## position 属性

```css
.element {
  position: static;     /* 默认值，正常文档流 */
  position: relative;   /* 相对定位 */
  position: absolute;   /* 绝对定位 */
  position: fixed;      /* 固定定位 */
  position: sticky;     /* 粘性定位 */
}
```

## relative 相对定位

相对于元素在文档流中的原始位置进行偏移：

```css
.box {
  position: relative;
  top: 10px;      /* 向下移动 10px */
  left: 20px;     /* 向右移动 20px */
}
```

**特点**：
- 保留原位置空间（不脱离文档流）
- 常用于作为 absolute 子元素的定位上下文

## absolute 绝对定位

相对于最近的非 static 定位祖先元素：

```css
.parent {
  position: relative;  /* 创建定位上下文 */
}

.child {
  position: absolute;
  top: 0;
  right: 0;  /* 定位在父元素右上角 */
}
```

**特点**：
- 脱离文档流（不占据空间）
- 若无定位祖先，则相对于初始包含块（html）

## fixed 固定定位

相对于视口定位，滚动时保持不动：

```css
.back-to-top {
  position: fixed;
  bottom: 20px;
  right: 20px;
}

.navbar {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
}
```

## sticky 粘性定位

relative 和 fixed 的混合，滚动到阈值时固定：

```css
.section-header {
  position: sticky;
  top: 0;  /* 滚动到视口顶部时粘住 */
  background: white;
}
```

## z-index 层叠

控制定位元素的层叠顺序（值越大越在上层）：

```css
.modal {
  position: fixed;
  z-index: 1000;  /* 在最上层 */
}

.overlay {
  position: fixed;
  z-index: 999;   /* 在 modal 下层 */
}
```

**注意**：z-index 只对定位元素（非 static）有效。

## 实用定位模式

### 模态框居中

```css
.modal {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 1000;
}

.overlay {
  position: fixed;
  inset: 0;  /* top:0 right:0 bottom:0 left:0 */
  background: rgba(0, 0, 0, 0.5);
  z-index: 999;
}
```

### 角标

```css
.badge {
  position: absolute;
  top: -8px;
  right: -8px;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: red;
  color: white;
  font-size: 12px;
  text-align: center;
  line-height: 20px;
}
```', NULL, 25, 4, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('d61650d4-3162-48bb-bfa3-71401ead5115', '68eeb1fe-fe3d-4669-b98c-fb1815316739', 'layout-ch1-flexbox-basics', 'Flexbox 弹性盒子基础', '学习 Flexbox 的核心概念、容器属性和项目属性', '# Flexbox 弹性盒子基础

## 什么是 Flexbox

Flexbox（弹性盒子布局）是一种一维布局模型，非常适合处理行或列方向上的布局。

```css
.container {
  display: flex;         /* 块级弹性容器 */
  display: inline-flex;  /* 行内弹性容器 */
}
```

## Flex 容器属性

### flex-direction 主轴方向

```css
.container {
  flex-direction: row;            /* 水平排列（默认） */
  flex-direction: row-reverse;    /* 水平反向 */
  flex-direction: column;         /* 垂直排列 */
  flex-direction: column-reverse; /* 垂直反向 */
}
```

### flex-wrap 换行

```css
.container {
  flex-wrap: nowrap;         /* 不换行（默认） */
  flex-wrap: wrap;           /* 允许换行 */
  flex-wrap: wrap-reverse;   /* 反向换行 */
}

/* 简写 */
flex-flow: row wrap;
```

### justify-content 主轴对齐

```css
.container {
  justify-content: flex-start;     /* 起点对齐（默认） */
  justify-content: flex-end;       /* 终点对齐 */
  justify-content: center;         /* 居中对齐 */
  justify-content: space-between;  /* 两端对齐，中间等分 */
  justify-content: space-around;   /* 每项两侧等距 */
  justify-content: space-evenly;   /* 所有间距相等 */
}
```

### align-items 交叉轴对齐

```css
.container {
  align-items: stretch;       /* 拉伸填满（默认） */
  align-items: flex-start;    /* 起点对齐 */
  align-items: flex-end;      /* 终点对齐 */
  align-items: center;        /* 居中对齐 */
  align-items: baseline;      /* 基线对齐 */
}
```

### gap 间距

```css
.container {
  gap: 16px;              /* 行和列间距 */
  row-gap: 16px;          /* 行间距 */
  column-gap: 24px;       /* 列间距 */
}
```

## Flex 项目属性

### flex-grow 增长比例

```css
.item {
  flex-grow: 0;   /* 不增长（默认） */
  flex-grow: 1;   /* 等分剩余空间 */
  flex-grow: 2;   /* 获得2倍剩余空间 */
}
```

### flex-shrink 收缩比例

```css
.item {
  flex-shrink: 1;   /* 允许收缩（默认） */
  flex-shrink: 0;   /* 不收缩 */
}
```

### flex-basis 基础大小

```css
.item {
  flex-basis: auto;     /* 根据内容大小（默认） */
  flex-basis: 200px;    /* 固定基础大小 */
  flex-basis: 30%;      /* 百分比基础大小 */
}
```

### flex 简写

```css
/* flex: grow shrink basis */
.item {
  flex: 1;            /* 1 1 0% */
  flex: auto;         /* 1 1 auto */
  flex: none;         /* 0 0 auto */
  flex: 0 1 200px;    /* 明确指定 */
}
```

### align-self 单独对齐

```css
.item {
  align-self: center;   /* 覆盖容器的 align-items */
}
```

## 常见 Flexbox 布局模式

### 水平垂直居中

```css
.center {
  display: flex;
  justify-content: center;
  align-items: center;
}
```

### 侧边栏 + 主内容

```css
.layout {
  display: flex;
}
.sidebar {
  width: 250px;
  flex-shrink: 0;  /* 侧边栏不收缩 */
}
.main {
  flex: 1;         /* 主内容占据剩余空间 */
}
```

### 等分布局

```css
.equal {
  display: flex;
}
.equal > * {
  flex: 1;
}
```', NULL, 35, 0, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('fd17c6d3-9bb1-43ac-a2d6-9ae0c144b16c', '68eeb1fe-fe3d-4669-b98c-fb1815316739', 'layout-ch2-flexbox-patterns', 'Flexbox 实战布局模式', '学习常见的 Flexbox 布局模式和实际应用场景', '# Flexbox 实战布局模式

## 导航栏布局

```css
.navbar {
  display: flex;
  justify-content: space-between;  /* 两端对齐 */
  align-items: center;             /* 垂直居中 */
  padding: 0 20px;
  height: 60px;
  background: #333;
}

.nav-links {
  display: flex;
  gap: 24px;
  list-style: none;
}

.nav-links a {
  color: white;
  text-decoration: none;
}
```

## 卡片列表布局

```css
.card-list {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
}

.card {
  flex: 1 1 300px;  /* 可增长、可收缩、基础300px */
  /* 等效于：flex-basis: 300px; flex-grow: 1; */
}
```

这样卡片至少 300px 宽，空间充足时等分，不足时换行。

## 底部固定布局

```css
body {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

main {
  flex: 1;  /* 主内容占据剩余空间 */
}

footer {
  /* footer 始终在底部 */
}
```

## 居中布局的多种方式

```css
/* 方式1：Flexbox */
.flex-center {
  display: flex;
  justify-content: center;
  align-items: center;
}

/* 方式2：Flexbox + margin */
.auto-center {
  display: flex;
}
.auto-center .item {
  margin: auto;
}

/* 方式3：Grid */
.grid-center {
  display: grid;
  place-items: center;
}
```

## 顺序控制

```css
.item1 { order: 3; }
.item2 { order: 1; }
.item3 { order: 2; }
```

所有项目默认 order: 0，值小的排在前面。

## 自适应导航

```css
.nav {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.nav-item {
  flex: 1 1 auto;  /* 自动适应内容 */
  white-space: nowrap;
}
```

## 表单标签对齐

```css
.form-row {
  display: flex;
  align-items: center;
  gap: 16px;
}

.form-row label {
  width: 100px;
  flex-shrink: 0;  /* 标签宽度固定 */
  text-align: right;
}

.form-row input {
  flex: 1;  /* 输入框占据剩余空间 */
}
```', NULL, 25, 1, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('47ffbf2d-798f-47bf-9d3b-996ba9c99f72', '68eeb1fe-fe3d-4669-b98c-fb1815316739', 'layout-ch3-grid-basics', 'CSS Grid 网格布局', '学习 CSS Grid 的核心概念和二维布局技术', '# CSS Grid 网格布局

## 什么是 Grid

CSS Grid 是一种二维布局系统，可以同时处理行和列，非常适合复杂的页面布局。

```css
.container {
  display: grid;          /* 块级网格容器 */
  display: inline-grid;   /* 行内网格容器 */
}
```

## 定义网格

### grid-template-columns 定义列

```css
.container {
  /* 三列，每列等宽 */
  grid-template-columns: 1fr 1fr 1fr;

  /* 使用 repeat 简写 */
  grid-template-columns: repeat(3, 1fr);

  /* 不同宽度 */
  grid-template-columns: 200px 1fr 2fr;

  /* 自适应列数 */
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
}
```

### grid-template-rows 定义行

```css
.container {
  grid-template-rows: 100px 1fr 80px;
  /* 第一行 100px，中间行自适应，最后一行 80px */
}
```

### fr 单位

fr（fraction）表示剩余空间的比例分配：

```css
grid-template-columns: 1fr 2fr;  /* 第二列是第一列的两倍宽 */
```

### minmax() 函数

```css
grid-template-columns: repeat(3, minmax(200px, 1fr));
/* 每列至少 200px，最大等分剩余空间 */
```

## 间距

```css
.container {
  gap: 20px;           /* 行和列间距 */
  row-gap: 16px;       /* 行间距 */
  column-gap: 24px;    /* 列间距 */
}
```

## 项目放置

### grid-column 和 grid-row

```css
.item1 {
  grid-column: 1 / 3;  /* 从第1列线到第3列线，横跨2列 */
  grid-row: 1 / 2;     /* 在第1行 */
}

/* 使用 span */
.item2 {
  grid-column: span 2; /* 横跨2列 */
}
```

### grid-area 命名区域

```css
.container {
  grid-template-areas:
    "header header header"
    "sidebar main main"
    "footer footer footer";
  grid-template-columns: 200px 1fr 1fr;
  grid-template-rows: auto 1fr auto;
}

.header { grid-area: header; }
.sidebar { grid-area: sidebar; }
.main { grid-area: main; }
.footer { grid-area: footer; }
```

## 对齐

### 项目对齐（单个项目）

```css
.item {
  justify-self: center;   /* 水平方向：start | end | center | stretch */
  align-self: center;     /* 垂直方向：start | end | center | stretch */
}
```

### 批量对齐（所有项目）

```css
.container {
  justify-items: center;  /* 水平方向 */
  align-items: center;    /* 垂直方向 */
  place-items: center;    /* 两者简写 */
}
```

### 网格整体对齐

```css
.container {
  justify-content: center;  /* 网格在容器内水平对齐 */
  align-content: center;    /* 网格在容器内垂直对齐 */
}
```

## 隐式网格

```css
.container {
  grid-auto-rows: 200px;     /* 自动行的尺寸 */
  grid-auto-columns: 100px;  /* 自动列的尺寸 */
  grid-auto-flow: row;       /* 放置方向：row | column | dense */
}
```', NULL, 35, 2, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('7878f3db-a944-419d-a63d-b357d94fc775', '68eeb1fe-fe3d-4669-b98c-fb1815316739', 'layout-ch4-responsive', '响应式设计与媒体查询', '学习使用媒体查询创建适配不同设备的响应式布局', '# 响应式设计与媒体查询

## 视口设置

首先需要在 HTML head 中添加 viewport meta 标签：

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

## 媒体查询语法

```css
/* 基本语法 */
@media media-type and (media-feature) {
  /* CSS 规则 */
}

/* 常见断点 */
@media (max-width: 576px) { /* 手机 */ }
@media (min-width: 577px) and (max-width: 768px) { /* 平板 */ }
@media (min-width: 769px) and (max-width: 992px) { /* 小型桌面 */ }
@media (min-width: 993px) { /* 大型桌面 */ }
```

## 常用媒体特性

| 特性 | 说明 | 示例 |
|------|------|------|
| width | 视口宽度 | `(min-width: 768px)` |
| height | 视口高度 | `(max-height: 600px)` |
| orientation | 方向 | `(orientation: landscape)` |
| prefers-color-scheme | 暗色模式 | `(prefers-color-scheme: dark)` |

## 移动优先写法

推荐从小屏幕开始，逐步增强：

```css
/* 基础样式（手机） */
.card {
  width: 100%;
  margin-bottom: 16px;
}

/* 平板 */
@media (min-width: 768px) {
  .card {
    width: 48%;
  }
}

/* 桌面 */
@media (min-width: 1024px) {
  .card {
    width: 31%;
  }
}
```

## 响应式 Grid

```css
.grid {
  display: grid;
  gap: 20px;
  /* 手机：单列 */
  grid-template-columns: 1fr;
}

@media (min-width: 768px) {
  .grid {
    /* 平板：两列 */
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1024px) {
  .grid {
    /* 桌面：三列 */
    grid-template-columns: repeat(3, 1fr);
  }
}
```

## 响应式 Flexbox

```css
.navbar {
  display: flex;
  flex-direction: column;  /* 手机：垂直堆叠 */
}

@media (min-width: 768px) {
  .navbar {
    flex-direction: row;   /* 平板及以上：水平排列 */
    justify-content: space-between;
  }
}
```

## 响应式图片

```css
img {
  max-width: 100%;   /* 图片不超过容器宽度 */
  height: auto;      /* 高度自动调整 */
}
```

## 隐藏/显示元素

```css
.desktop-only {
  display: none;
}

@media (min-width: 1024px) {
  .desktop-only {
    display: block;
  }
  .mobile-only {
    display: none;
  }
}
```', NULL, 30, 3, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('2bdb12cd-b53b-4c37-b0fc-c7f2e6a82125', '68eeb1fe-fe3d-4669-b98c-fb1815316739', 'layout-ch5-holy-grail', '圣杯布局实战', '综合运用 Flexbox 和 Grid 实现经典圣杯布局', '# 圣杯布局实战

## 什么是圣杯布局

圣杯布局（Holy Grail Layout）是 Web 开发中最经典的页面布局模式，包含：
- 顶部 Header
- 左侧 Sidebar
- 中间 Main Content
- 右侧 Aside
- 底部 Footer

## 使用 Grid 实现

```css
.layout {
  display: grid;
  min-height: 100vh;
  grid-template-columns: 250px 1fr 200px;
  grid-template-rows: auto 1fr auto;
  grid-template-areas:
    "header header header"
    "sidebar main aside"
    "footer footer footer";
}

.header { grid-area: header; background: #333; color: white; padding: 1rem; }
.sidebar { grid-area: sidebar; background: #f0f0f0; padding: 1rem; }
.main { grid-area: main; padding: 1rem; }
.aside { grid-area: aside; background: #f0f0f0; padding: 1rem; }
.footer { grid-area: footer; background: #333; color: white; padding: 1rem; }
```

## 响应式改造

```css
@media (max-width: 768px) {
  .layout {
    grid-template-columns: 1fr;
    grid-template-rows: auto auto 1fr auto auto;
    grid-template-areas:
      "header"
      "sidebar"
      "main"
      "aside"
      "footer";
  }
}
```

## 使用 Flexbox 实现

```css
.flex-layout {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.flex-layout > * {
  padding: 1rem;
}

.content-wrapper {
  display: flex;
  flex: 1;
}

.sidebar { width: 250px; background: #f0f0f0; }
.main { flex: 1; }
.aside { width: 200px; background: #f0f0f0; }

@media (max-width: 768px) {
  .content-wrapper {
    flex-direction: column;
  }
  .sidebar, .aside {
    width: auto;
  }
}
```

## 现代 Grid 简写

```css
.modern-layout {
  display: grid;
  grid-template:
    "header header" auto
    "sidebar main" 1fr
    "footer footer" auto
    / 250px 1fr;
  min-height: 100vh;
  gap: 1rem;
}
```

使用 `grid-template` 可以同时定义行和列。', NULL, 30, 4, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('62e5043a-bafb-4249-827b-0c80d54bb18c', 'e1b4e11d-a8cd-4ac6-bb63-0179f2d337fc', 'js-ch1-variables-types', '变量与数据类型', '学习 JavaScript 变量声明、基本数据类型和类型转换', '# 变量与数据类型

## JavaScript 是什么

JavaScript 是 Web 的编程语言，与 HTML（结构）和 CSS（样式）协同工作，实现网页的动态交互功能。

## 变量声明

JavaScript 有三种声明变量的方式：

```javascript
// let - 可重新赋值的变量（块级作用域，推荐）
let name = "Alice";
name = "Bob";  // ✓ 可以重新赋值

// const - 常量，声明时必须初始化（块级作用域，推荐）
const PI = 3.14159;
// PI = 3.14;  // ✗ 错误！不能重新赋值

// var - 函数作用域（旧用法，不推荐）
var age = 25;
```

**最佳实践**：默认使用 `const`，需要重新赋值时使用 `let`，避免使用 `var`。

## 数据类型

### 基本类型（Primitive）

```javascript
// String - 字符串
let username = "CodeQuest";

// Number - 数字（包括整数和浮点数）
let score = 95;
let price = 19.99;

// Boolean - 布尔值
let isActive = true;   // 或 false

// Undefined - 未定义
let data;              // 声明但未赋值，值为 undefined

// Null - 空值
let user = null;       // 表示"无"或"空"

// Symbol - 唯一标识（ES6）
let id = Symbol("id");
```

### 引用类型

```javascript
// Object - 对象
let person = { name: "Tom", age: 25 };

// Array - 数组
let fruits = ["apple", "banana", "cherry"];

// Function - 函数
function greet() { return "Hello"; }
```

## typeof 操作符

用于检测数据类型：

```javascript
typeof "hello";      // "string"
typeof 42;           // "number"
typeof true;         // "boolean"
typeof undefined;    // "undefined"
typeof null;         // "object" （历史 bug，需注意）
typeof {};           // "object"
typeof [];           // "object" （数组也是对象）
typeof function(){}; // "function"
```

## 类型转换

```javascript
// 显式转换
Number("42");        // 42
String(123);         // "123"
Boolean(1);          // true

// 模板字符串（推荐）
let name = "Alice";
let age = 25;
console.log(`我叫 ${name}，今年 ${age} 岁`);
// 输出：我叫 Alice，今年 25 岁
```

## 命名规范

- 使用驼峰命名法：`userName`, `totalScore`
- 常量全大写下划线：`MAX_SIZE`
- 变量名要有意义，避免单字母（循环中除外）
- 不能以数字开头，不能是保留字', NULL, 25, 0, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('983c24d0-c813-4c51-a86c-f03e6a6f7e26', 'e1b4e11d-a8cd-4ac6-bb63-0179f2d337fc', 'js-ch2-operators', '运算符与表达式', '掌握算术、比较、逻辑和赋值运算符的使用', '# 运算符与表达式

## 算术运算符

```javascript
let a = 10, b = 3;

console.log(a + b);   // 13 - 加法
console.log(a - b);   // 7  - 减法
console.log(a * b);   // 30 - 乘法
console.log(a / b);   // 3.333... - 除法
console.log(a % b);   // 1  - 取模（余数）
console.log(a ** b);  // 1000 - 幂运算（10的3次方）

// 自增/自减
let count = 0;
count++;  // 先使用，后加1
++count;  // 先加1，后使用
```

## 比较运算符

```javascript
// === 严格相等（值和类型都相同，推荐）
5 === 5;     // true
5 === "5";   // false（类型不同）

// !== 严格不等
5 !== "5";   // true

// == 松散相等（会进行类型转换，避免使用）
5 == "5";    // true（不推荐）
0 == false;  // true（不推荐）
"" == false; // true（不推荐）

// 大小比较
10 > 5;      // true
10 <= 10;    // true
```

**黄金法则**：始终使用 `===` 和 `!==`，避免 `==` 和 `!=` 带来的类型转换陷阱。

## 逻辑运算符

```javascript
// && 与（AND）- 两个都为真才为真
true && true;   // true
true && false;  // false

// || 或（OR）- 至少一个为真就为真
true || false;  // true
false || false; // false

// ! 非（NOT）- 取反
!true;          // false
!false;         // true

// 短路求值
let name = userName || "访客";  // 如果 userName 为假值，使用默认值
let result = isValid && submit(); // 如果 isValid 为 false，不执行 submit
```

## 赋值运算符

```javascript
let x = 10;
x += 5;   // x = x + 5;  → 15
x -= 3;   // x = x - 3;  → 12
x *= 2;   // x = x * 2;  → 24
x /= 4;   // x = x / 4;  → 6
x %= 4;   // x = x % 4;  → 2
```

## 运算符优先级

```javascript
// 1. 括号 () 最高
// 2. 自增/自减 ++ --
// 3. 乘除取模 * / %
// 4. 加减 + -
// 5. 比较 > < >= <=
// 6. 相等 === !== == !=
// 7. 逻辑与 &&
// 8. 逻辑或 ||
// 9. 赋值 = 最低

let result = 2 + 3 * 4;      // 14（先乘后加）
let result2 = (2 + 3) * 4;   // 20（括号优先）
```

## 真值与假值

在条件判断中，以下值被视为**假值**（falsy）：
- `false`
- `0`
- `""`（空字符串）
- `null`
- `undefined`
- `NaN`

**其余所有值都是真值**（truthy），包括 `[]`、`{}`、`"0"`、`"false"`。', NULL, 20, 1, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('514fc8b4-ba8d-47ef-932a-85fc41894bf4', 'e1b4e11d-a8cd-4ac6-bb63-0179f2d337fc', 'js-ch3-conditionals', '条件语句', '学习 if/else、switch 和三元运算符进行条件判断', '# 条件语句

## if...else 语句

```javascript
let score = 85;

if (score >= 90) {
  console.log("优秀");
} else if (score >= 80) {
  console.log("良好");
} else if (score >= 70) {
  console.log("中等");
} else if (score >= 60) {
  console.log("及格");
} else {
  console.log("不及格");
}
```

## 三元运算符

简单的二选一，语法更简洁：

```javascript
let age = 18;
let status = age >= 18 ? "成年人" : "未成年人";

// 嵌套三元（不推荐过多嵌套）
let label = score >= 90 ? "A" : score >= 80 ? "B" : "C";
```

## switch 语句

用于多值匹配的场景：

```javascript
let day = 1;

switch (day) {
  case 1:
    console.log("星期一");
    break;  // 不要忘记 break，否则会穿透到下一个 case
  case 2:
    console.log("星期二");
    break;
  case 3:
    console.log("星期三");
    break;
  case 4:
    console.log("星期四");
    break;
  case 5:
    console.log("星期五");
    break;
  default:
    console.log("周末");
}

// 多个 case 共享代码
switch (fruit) {
  case "apple":
  case "pear":
  case "peach":
    console.log("蔷薇科水果");
    break;
  case "orange":
  case "lemon":
    console.log("柑橘类水果");
    break;
}
```

## 条件中的常见模式

```javascript
// 检查变量是否有值
if (name) { ... }  // 等价于 if (name !== "" && name !== null && name !== undefined)

// 使用逻辑或设置默认值
let username = input || "匿名用户";

// 可选执行（条件为真时才执行）
isLoggedIn && showUserProfile();

// 检查数组非空
if (items.length > 0) { ... }
// 或
if (items.length) { ... }
```

## 注意事项

```javascript
// 常见陷阱：== 的类型转换
if (0 == false) { ... }   // true！使用 === 避免

// 正确做法
if (isValid === true) { ... }  // 明确比较
if (isValid) { ... }           // 隐式转换，简洁但需理解真值假值

// 检查 null 或 undefined
if (value == null) { ... }  // 同时匹配 null 和 undefined（唯一适合用 == 的场景）
if (value === null || value === undefined) { ... }  // 等价的严格比较写法
```', NULL, 20, 2, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('7c9997a5-d58c-418f-b45c-cd4e07a4f787', 'e1b4e11d-a8cd-4ac6-bb63-0179f2d337fc', 'js-ch4-loops', '循环语句', '学习 for、while、for...of 循环和循环控制', '# 循环语句

## for 循环

适合已知循环次数的场景：

```javascript
// 基本语法
for (初始化; 条件; 增量) {
  // 循环体
}

// 示例：打印 1 到 5
for (let i = 1; i <= 5; i++) {
  console.log(i);
}

// 倒序
for (let i = 5; i >= 1; i--) {
  console.log(i);
}

// 步长为 2
for (let i = 0; i < 10; i += 2) {
  console.log(i);  // 0, 2, 4, 6, 8
}
```

## while 循环

条件为真时持续执行：

```javascript
let count = 0;
while (count < 5) {
  console.log(count);
  count++;
}

// do...while 至少执行一次
let num = 0;
do {
  console.log(num);
  num++;
} while (num < 0);  // 条件为假，但已执行了一次
```

## for...of 循环

遍历可迭代对象（数组、字符串等）：

```javascript
let fruits = ["apple", "banana", "cherry"];

for (let fruit of fruits) {
  console.log(fruit);
}
// 输出: apple, banana, cherry

let message = "Hello";
for (let char of message) {
  console.log(char);
}
// 输出: H, e, l, l, o
```

## for...in 循环

遍历对象的属性键（不推荐用于数组）：

```javascript
let person = { name: "Alice", age: 25, city: "Beijing" };

for (let key in person) {
  console.log(`${key}: ${person[key]}`);
}
// 输出: name: Alice, age: 25, city: Beijing
```

## 循环控制

```javascript
// break - 终止整个循环
for (let i = 0; i < 10; i++) {
  if (i === 5) break;  // 当 i 为 5 时退出循环
  console.log(i);       // 输出: 0, 1, 2, 3, 4
}

// continue - 跳过当前迭代
for (let i = 0; i < 5; i++) {
  if (i === 2) continue;  // 跳过 i=2
  console.log(i);          // 输出: 0, 1, 3, 4
}
```

## 嵌套循环

```javascript
// 打印乘法表
for (let i = 1; i <= 3; i++) {
  for (let j = 1; j <= 3; j++) {
    console.log(`${i} × ${j} = ${i * j}`);
  }
}
```

## 循环选择指南

| 场景 | 推荐循环 |
|------|----------|
| 已知次数 | `for` |
| 条件控制 | `while` / `do...while` |
| 遍历数组 | `for...of` |
| 遍历对象属性 | `for...in` |
| 需要索引 | `for` 或 `forEach` |
| 需要中途退出 | `for` / `while` + `break` |', NULL, 20, 3, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('4eba55dd-9eb7-49b7-8a25-c67c7d981fd0', 'e1b4e11d-a8cd-4ac6-bb63-0179f2d337fc', 'js-ch5-functions', '函数定义与调用', '学习函数声明、表达式、箭头函数和作用域', '# 函数定义与调用

## 函数声明

使用 `function` 关键字声明，会**提升**（hoisting）：

```javascript
function greet(name) {
  return `Hello, ${name}!`;
}

console.log(greet("Alice"));  // "Hello, Alice!"
```

## 函数表达式

将函数赋值给变量，**不会提升**：

```javascript
const greet = function(name) {
  return `Hello, ${name}!`;
};
```

## 箭头函数（推荐）

更简洁的语法：

```javascript
// 完整写法
const greet = (name) => {
  return `Hello, ${name}!`;
};

// 简化写法：单参数可省略括号
const greet = name => {
  return `Hello, ${name}!`;
};

// 极简写法：单表达式可省略 {} 和 return
const greet = name => `Hello, ${name}!`;

// 多参数
const add = (a, b) => a + b;

// 无参数
const sayHi = () => console.log("Hi!");

// 返回对象需要用括号包裹
const getUser = name => ({ name: name, role: "user" });
```

## 默认参数

```javascript
function greet(name = "访客") {
  return `你好，${name}！`;
}

greet();         // "你好，访客！"
greet("Alice");  // "你好，Alice！"
```

## 剩余参数

```javascript
function sum(...numbers) {
  let total = 0;
  for (let num of numbers) {
    total += num;
  }
  return total;
}

sum(1, 2, 3, 4, 5);  // 15
```

## 作用域

### 全局作用域

在函数外部声明的变量，可在整个脚本中访问：

```javascript
let globalVar = "我是全局变量";

function test() {
  console.log(globalVar);  // 可以访问
}
```

### 局部（函数）作用域

在函数内部声明的变量，只能在函数内访问：

```javascript
function test() {
  let localVar = "我是局部变量";
  console.log(localVar);   // ✓ 可以
}
// console.log(localVar);  // ✗ 报错！
```

### 块级作用域

`let` 和 `const` 在 `{}` 块内有效：

```javascript
if (true) {
  let blockVar = "块级变量";
  const PI = 3.14;
}
// console.log(blockVar);  // ✗ 报错！
```

## 箭头函数的 this

箭头函数没有自己的 `this`，继承外层的 `this`：

```javascript
const person = {
  name: "Alice",
  regularFunc: function() {
    console.log(this.name);  // "Alice"（this 指向 person）
  },
  arrowFunc: () => {
    console.log(this.name);  // undefined（this 继承外层，不是 person）
  }
};
```

**规则**：需要 `this` 时用普通函数，不需要时用箭头函数。', NULL, 30, 4, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('c0c4f157-e3d2-4597-9ad8-47ab28028f71', 'e1b4e11d-a8cd-4ac6-bb63-0179f2d337fc', 'js-ch6-arrays', '数组操作', '掌握数组的创建、遍历和常用方法', '# 数组操作

## 数组创建

```javascript
// 字面量创建（推荐）
let fruits = ["apple", "banana", "cherry"];

// 空数组
let empty = [];

// Array 构造函数
let numbers = new Array(1, 2, 3);

// 不同数据类型混合
let mixed = ["text", 42, true, null, { key: "value" }];
```

## 访问和修改元素

```javascript
let colors = ["red", "green", "blue"];

// 访问（索引从 0 开始）
colors[0];    // "red"
colors[2];    // "blue"
colors[10];   // undefined（越界）

// 修改
colors[1] = "yellow";  // ["red", "yellow", "blue"]

// 获取长度
colors.length;  // 3

// 访问最后一个元素
colors[colors.length - 1];  // "blue"
```

## 常用数组方法

### 添加/删除元素

```javascript
let arr = [1, 2, 3];

arr.push(4);        // [1,2,3,4] - 尾部添加
arr.pop();          // [1,2,3]   - 尾部删除
arr.unshift(0);     // [0,1,2,3] - 头部添加
arr.shift();        // [1,2,3]   - 头部删除
arr.splice(1, 1);   // [1,3]     - 从索引1删除1个元素
arr.splice(1, 0, "a"); // [1,"a",3] - 在索引1插入"a"
```

### 查找元素

```javascript
let nums = [10, 20, 30, 40, 50];

nums.indexOf(30);      // 2 - 返回索引，找不到返回 -1
nums.includes(30);     // true - 是否包含
nums.find(n => n > 25);     // 30 - 返回第一个满足条件的元素
nums.findIndex(n => n > 25); // 2 - 返回第一个满足条件的索引
```

### 遍历数组

```javascript
let items = ["a", "b", "c"];

// forEach - 遍历每个元素
items.forEach((item, index) => {
  console.log(`${index}: ${item}`);
});

// map - 映射每个元素，返回新数组
let upper = items.map(item => item.toUpperCase());
// ["A", "B", "C"]

// filter - 筛选满足条件的元素
let nums = [1, 2, 3, 4, 5, 6];
let evens = nums.filter(n => n % 2 === 0);
// [2, 4, 6]

// reduce - 累计计算
let sum = nums.reduce((total, n) => total + n, 0);
// 21
```

### 数组转换

```javascript
let words = ["Hello", "World"];

words.join(" ");       // "Hello World" - 合并为字符串
words.slice(0, 2);     // ["Hello", "World"] - 提取子数组
words.reverse();       // ["World", "Hello"] - 反转（修改原数组）
words.concat(["!"]);   // ["World", "Hello", "!"] - 合并数组
```

## 数组解构

```javascript
let [first, second] = ["apple", "banana"];
console.log(first);   // "apple"

// 跳过元素
let [, , third] = [1, 2, 3, 4];
console.log(third);   // 3

// 剩余元素
let [head, ...tail] = [1, 2, 3, 4];
console.log(head);    // 1
console.log(tail);    // [2, 3, 4]
```', NULL, 30, 5, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('f56161a6-3c6f-4fb0-84bd-86a64d9d4c84', 'e1b4e11d-a8cd-4ac6-bb63-0179f2d337fc', 'js-ch7-objects', '对象与类', '学习对象创建、属性操作和 ES6 Class', '# 对象与类

## 对象基础

对象用于存储键值对数据：

```javascript
// 字面量创建（推荐）
let person = {
  name: "Alice",
  age: 25,
  city: "Beijing"
};

// 构造函数创建
let user = new Object();
user.name = "Bob";
user.age = 30;
```

## 属性访问和修改

```javascript
let person = { name: "Alice", age: 25 };

// 点表示法
person.name;        // "Alice"
person.age = 26;    // 修改

// 方括号表示法（适用于变量或特殊字符键）
person["name"];     // "Alice"
let key = "age";
person[key];        // 26

// 添加属性
person.email = "alice@example.com";

// 删除属性
delete person.age;
```

## 对象方法

```javascript
let person = {
  name: "Alice",
  greet() {
    return `你好，我是 ${this.name}`;
  }
};

person.greet();  // "你好，我是 Alice"
```

## ES6 Class

```javascript
class Animal {
  // 构造函数
  constructor(name) {
    this.name = name;
  }

  // 方法
  speak() {
    console.log(`${this.name} 发出声音`);
  }

  // 静态方法
  static isAnimal(obj) {
    return obj instanceof Animal;
  }
}

// 继承
class Dog extends Animal {
  constructor(name, breed) {
    super(name);  // 调用父类构造函数
    this.breed = breed;
  }

  speak() {
    console.log(`${this.name} 汪汪叫`);
  }
}

let dog = new Dog("旺财", "金毛");
dog.speak();  // "旺财 汪汪叫"
```

## 对象常用方法

```javascript
let person = { name: "Alice", age: 25, city: "Beijing" };

Object.keys(person);    // ["name", "age", "city"]
Object.values(person);  // ["Alice", 25, "Beijing"]
Object.entries(person); // [["name","Alice"],["age",25],["city","Beijing"]]

// 检查属性
"name" in person;              // true
person.hasOwnProperty("name"); // true

// 合并对象
let defaults = { theme: "light", lang: "zh" };
let settings = { lang: "en" };
let merged = Object.assign({}, defaults, settings);
// { theme: "light", lang: "en" }

// 展开运算符合并
let merged2 = { ...defaults, ...settings };
```

## 对象解构

```javascript
let person = { name: "Alice", age: 25, city: "Beijing" };

// 解构
let { name, age } = person;
console.log(name);  // "Alice"

// 重命名
let { name: userName } = person;
console.log(userName);  // "Alice"

// 设置默认值
let { name, role = "user" } = person;

// 解构函数参数
function greet({ name, age }) {
  return `${name} 今年 ${age} 岁`;
}
```

## JSON

```javascript
// 对象转 JSON 字符串
let jsonStr = JSON.stringify({ name: "Alice", age: 25 });
// ''{"name":"Alice","age":25}''

// JSON 字符串转对象
let obj = JSON.parse(''{"name":"Alice","age":25}'');
// { name: "Alice", age: 25 }
```', NULL, 25, 6, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');
INSERT INTO public.chapters VALUES ('3b9c644d-39c5-4fb2-b4a6-9a34a40a5e4d', 'e1b4e11d-a8cd-4ac6-bb63-0179f2d337fc', 'js-ch8-dom-events', 'DOM 操作与事件处理', '学习选择元素、修改内容和响应用户交互', '# DOM 操作与事件处理

## 什么是 DOM

DOM（Document Object Model，文档对象模型）将 HTML 文档表示为树形结构，JavaScript 可以通过 DOM API 访问和修改页面内容。

```
Document
 └── html
      ├── head
      │    └── title
      └── body
           ├── h1
           ├── p
           └── button
```

## 选择元素

```javascript
// 通过 ID 选择（单个元素）
let heading = document.getElementById("title");

// 通过 CSS 选择器选择第一个匹配
let btn = document.querySelector(".submit-btn");

// 通过 CSS 选择器选择所有匹配
let items = document.querySelectorAll(".item");  // 返回 NodeList

// 通过类名选择
let boxes = document.getElementsByClassName("box");  // 返回 HTMLCollection

// 通过标签名选择
let paragraphs = document.getElementsByTagName("p");
```

## 修改元素

```javascript
let heading = document.querySelector("h1");

// 修改文本内容（安全，不会解析 HTML）
heading.textContent = "新标题";

// 修改 HTML 内容（注意 XSS 风险）
heading.innerHTML = "<span>新标题</span>";

// 修改属性
heading.setAttribute("class", "main-title");
heading.getAttribute("class");  // "main-title"

// 修改样式（行内样式）
heading.style.color = "red";
heading.style.fontSize = "24px";  // CSS 属性名改为驼峰式

// 修改类名
heading.classList.add("highlight");      // 添加类
heading.classList.remove("highlight");   // 删除类
heading.classList.toggle("hidden");      // 切换类
heading.classList.contains("hidden");    // 是否包含类 → true/false
```

## 创建和添加元素

```javascript
// 创建新元素
let newDiv = document.createElement("div");
newDiv.textContent = "我是新元素";
newDiv.className = "box";

// 添加到父元素末尾
parentElement.appendChild(newDiv);

// 在参考元素前插入
parentElement.insertBefore(newDiv, referenceElement);

// 现代方法（更灵活）
parentElement.append(newDiv);           // 末尾添加
parentElement.prepend(newDiv);          // 开头添加
element.before(newDiv);                  // 在 element 前添加
element.after(newDiv);                   // 在 element 后添加
element.replaceWith(newDiv);             // 替换 element

// 删除元素
element.remove();
```

## 事件处理

### addEventListener

```javascript
let btn = document.querySelector("#myBtn");

// 添加点击事件监听
btn.addEventListener("click", function() {
  console.log("按钮被点击了！");
});

// 使用箭头函数
btn.addEventListener("click", () => {
  console.log("按钮被点击了！");
});

// 事件对象
btn.addEventListener("click", (event) => {
  console.log(event.target);  // 被点击的元素
  event.preventDefault();      // 阻止默认行为
});
```

### 常见事件类型

| 事件 | 说明 |
|------|------|
| `click` | 点击 |
| `dblclick` | 双击 |
| `mouseenter` / `mouseleave` | 鼠标进入/离开 |
| `keydown` / `keyup` | 按键按下/释放 |
| `submit` | 表单提交 |
| `input` | 输入值变化 |
| `change` | 值改变（失焦后） |
| `focus` / `blur` | 获得/失去焦点 |
| `DOMContentLoaded` | DOM 加载完成 |

### 事件委托

利用事件冒泡机制，父元素统一处理子元素事件：

```javascript
// 不要这样做：为每个按钮添加监听器（性能差）
document.querySelectorAll("button").forEach(btn => {
  btn.addEventListener("click", handleClick);
});

// 推荐：事件委托（性能好，动态元素也有效）
document.querySelector("#list").addEventListener("click", (event) => {
  if (event.target.tagName === "BUTTON") {
    handleClick(event.target);
  }
});
```', NULL, 35, 7, 'free', 'published', 1, '2026-05-10 23:31:11.500808+08', '2026-05-10 23:31:11.500808+08');


--
-- Data for Name: exercises; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.exercises VALUES ('b793abc0-2496-4e3a-b444-2f2254c9913b', 'fa69b96b-c26a-4ae0-b2d1-d6a960dfb7ed', 'html-ex1-hello-world', '创建你的第一个 HTML 页面', '创建一个包含完整文档结构的 HTML 页面。要求：
1. 添加正确的 DOCTYPE 声明
2. html 标签设置 lang="zh-CN"
3. head 区域包含 charset=UTF-8、viewport meta 标签和 title（内容为''我的第一个网页''）
4. body 中包含一个 h1 标题（内容为''你好，HTML!''）和一个 p 段落（内容为''这是我创建的第一个网页。''）', 'coding', '<!DOCTYPE html>
<html>
<head>
  <!-- 在这里添加 meta 标签和标题 -->
</head>
<body>
  <!-- 在这里添加 h1 标题和段落 -->
</body>
</html>', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('48b259dc-8b5f-450a-91ce-4e9ccfa1ab82', 'fa69b96b-c26a-4ae0-b2d1-d6a960dfb7ed', 'html-ex1-quiz-elements', 'HTML 元素与属性小测验', '回答以下关于 HTML 元素和属性的问题：', 'single_choice', '', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('b6bf5c42-3520-4953-9e33-91339e31e903', '3710dfb3-b172-4a3c-9ba3-0301822867ce', 'html-ex2-article-structure', '文章结构标记练习', '为一篇技术博客文章添加正确的 HTML 标记。要求：
1. 一个 h1 标题：''HTML 入门指南''
2. 一个引言段落，其中''重要''一词使用 strong 强调
3. 一个 h2 子标题：''学习路径''
4. 在 h2 下方创建一个无序列表，包含3项：''HTML 基础语法''、''CSS 样式设计''、''JavaScript 交互''
5. 一个 h2 子标题：''准备工作''
6. 在第二个 h2 下方创建一个有序列表，包含2项：''安装 VS Code 编辑器''、''创建项目文件夹''', 'coding', '<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <title>文章结构练习</title>
</head>
<body>
  <!-- 在这里添加文章结构 -->
</body>
</html>', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('5228bafd-9435-42de-865d-98a25ffb587b', '3710dfb3-b172-4a3c-9ba3-0301822867ce', 'html-ex2-quiz-semantics', '文本语义化选择', '选择最适合的标签来完成以下文本标记任务：', 'single_choice', '', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('63b00b44-a4fa-4263-a5f7-996160fccf46', 'b40f8541-b062-42ca-8845-617fa4042a0a', 'html-ex3-blog-layout', '博客页面语义化结构', '创建一个语义化的博客文章页面。要求：
1. 使用 header 包裹 h1 标题''我的博客''和 nav 导航（包含2个链接：首页 / 关于）
2. 使用 main 包裹主要内容
3. 在 main 中使用 article 包裹文章，article 内包含 h2 标题''HTML5 语义化指南''
4. 使用 section 将文章分为两节（每节有 h3 子标题和 p 段落）
5. 使用 aside 创建侧边栏，包含 h3''相关文章''和一个 ul 列表（2个 li）
6. 使用 footer 创建页脚，包含 p 标签和版权信息''© 2025 我的博客''', 'coding', '<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <title>语义化博客</title>
</head>
<body>
  <!-- 在这里构建语义化博客页面 -->
</body>
</html>', 'html_css', 'intermediate', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('83651de8-d2ba-4623-86cc-8e15dff47f0d', 'b40f8541-b062-42ca-8845-617fa4042a0a', 'html-ex3-quiz-semantic', '语义化标签选择', '为以下场景选择最合适的 HTML5 语义化标签：', 'single_choice', '', 'html_css', 'intermediate', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('ef7bfc65-ea82-4aea-93b9-75706f232cdc', '5b39d870-b8e5-426d-a128-d598968ab6d5', 'html-ex4-personal-site', '创建个人网站导航', '创建一个包含导航菜单的图片画廊页面。要求：
1. 使用 nav 包含一个无序列表，列表中有4个 li，每个 li 包含一个 a 链接
2. 4个链接分别是：首页(href=''/'')、关于(href=''/about'')、作品集(href=''/portfolio'')、联系(href=''#contact'')
3. 在 nav 下方创建一个 h1 标题''我的作品集''
4. 创建一个 div，内部使用 img 插入两张图片
5. 第一张图片：src=''https://picsum.photos/300/200?random=1''，alt=''项目截图1''
6. 第二张图片：src=''https://picsum.photos/300/200?random=2''，alt=''项目截图2''
7. 在页面底部创建一个 id=''contact'' 的 div，内部包含一个邮件链接 mailto:hello@example.com', 'coding', '<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <title>个人网站</title>
</head>
<body>
  <!-- 在这里添加导航和图片 -->
</body>
</html>', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('16518b1b-90e6-4ef3-892a-190f0492b5cb', 'ed1f58bb-0056-42e2-aae2-92c01d032cf8', 'html-ex5-student-table', '创建学生信息表', '创建一个完整的学生信息表格。要求：
1. table 标签内包含 caption''2025年春季学生成绩表''
2. 使用 thead 包含表头行，3列：姓名(scope=col)、数学(scope=col)、英语(scope=col)
3. 使用 tbody 包含2行数据
4. 第一行：张三(行头，scope=row)、90、85
5. 第二行：李四(行头，scope=row)、78、92
6. 为表格添加 border="1" 属性', 'coding', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>学生成绩表</title>
</head>
<body>
  <!-- 在这里创建表格 -->
</body>
</html>', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('6f44bcaf-6334-4cb5-881d-0a11a8cde744', 'ed1f58bb-0056-42e2-aae2-92c01d032cf8', 'html-ex5-quiz-table', '表格知识测验', '回答以下关于 HTML 表格的问题：', 'single_choice', '', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('6ce8865f-2269-409e-87c2-85619c99871a', 'e2423900-0c96-460b-91ab-84e09ee6d8af', 'html-ex6-register-form', '用户注册表单', '创建一个完整的用户注册表单。要求：
1. form 标签设置 method="POST"，action="/register"
2. 用户名输入：type=text，name=username，required，placeholder=''请输入用户名''
3. 邮箱输入：type=email，name=email，required
4. 密码输入：type=password，name=password，required，minlength=8
5. 性别选择：两个 radio，name=gender，value 分别为 male 和 female，使用 label 包裹
6. 兴趣复选框：name=hobby，三个选项 value 分别为 coding、music、sports
7. 城市下拉：select name=city，包含3个 option（北京、上海、广州）
8. 个人简介：textarea name=bio，rows=3
9. 提交按钮：type=submit，文字''注册''', 'coding', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>用户注册</title>
</head>
<body>
  <h1>用户注册</h1>
  <!-- 在这里创建表单 -->
</body>
</html>', 'html_css', 'intermediate', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('10213507-7f83-4974-8ab8-ab1bc8d29c76', 'e2423900-0c96-460b-91ab-84e09ee6d8af', 'html-ex6-quiz-forms', '表单控件测验', '回答以下关于 HTML 表单的问题：', 'single_choice', '', 'html_css', 'intermediate', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('5e4d6abc-81c7-4207-b2e1-93d5cd53dab8', '2dd916e9-6662-473d-b07d-2c983ad677a0', 'css-ex1-selector-practice', '导航菜单样式设计', '为一个导航菜单编写 CSS 样式。HTML 结构已给定，请添加 style 标签完成以下样式：
1. nav 元素内的所有 a 标签：去掉下划线(text-decoration: none)，颜色为 #333
2. nav 元素内 a 标签的悬停状态：颜色变为 #007bff
3. class 为 active 的 a 标签：颜色为 #007bff，字体加粗(font-weight: bold)
4. nav 的直接子元素 ul：去掉列表符号(list-style: none)，内边距为 0
5. nav 内的 li 元素：display 设置为 inline-block，右边距 20px', 'coding', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>导航样式</title>
  <!-- 在这里添加 style 标签 -->
</head>
<body>
  <nav>
    <ul>
      <li><a href="#">首页</a></li>
      <li><a href="#" class="active">课程</a></li>
      <li><a href="#">练习</a></li>
      <li><a href="#">关于</a></li>
    </ul>
  </nav>
</body>
</html>', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('1861e14c-77fc-4f86-845d-1368c152945e', '2dd916e9-6662-473d-b07d-2c983ad677a0', 'css-ex1-quiz-specificity', '选择器优先级计算', '计算以下选择器的优先级权重，并回答相关问题：', 'single_choice', '', 'html_css', 'intermediate', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('872db405-81f1-45fa-bb23-f7e42a9ae516', '6c7b3f65-f05e-4e29-80fd-fe200f9eb7cd', 'css-ex2-card-component', '产品卡片组件', '创建一个精美的产品卡片组件。HTML 结构已给定，请添加 style 标签完成以下样式：
1. .card 类：宽度 300px，边框 1px solid #ddd，圆角 12px
2. .card-image：宽度 100%，高度 180px，背景色 #f0f0f0
3. .card-body：内边距 16px
4. .card-title：字体大小 20px，底部外边距 8px，颜色 #333
5. .card-price：颜色 #e74c3c，字体大小 18px，字体加粗
6. .card-button：宽度 100%，背景色 #3498db，文字颜色白色，边框无，内边距 10px，圆角 6px
7. 全局设置 box-sizing: border-box', 'coding', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>产品卡片</title>
  <!-- 在这里添加 style 标签 -->
</head>
<body>
  <div class="card">
    <div class="card-image"></div>
    <div class="card-body">
      <h3 class="card-title">无线蓝牙耳机</h3>
      <p class="card-price">¥299</p>
      <button class="card-button">加入购物车</button>
    </div>
  </div>
</body>
</html>', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('bcc98785-7e52-48f2-8565-f76dc6829ee0', '6c7b3f65-f05e-4e29-80fd-fe200f9eb7cd', 'css-ex2-quiz-boxmodel', '盒模型知识测验', '回答以下关于 CSS 盒模型的问题：', 'single_choice', '', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('971655af-6ef3-4ce9-8cc4-e83db1907ee4', '63d43de0-7bfd-4ea8-82a6-cad76000309c', 'css-ex3-article-typography', '文章排版设计', '为一篇博客文章设计排版样式。HTML 结构已给定，请添加 style 标签：
1. body：字体栈 ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif，字体大小 16px，行高 1.8，颜色 #333
2. h1：字体大小 32px，底部外边距 16px，颜色 #2c3e50，文字居中对齐
3. h2：字体大小 24px，底部外边距 12px，顶部外边距 32px，颜色 #34495e
4. p：底部外边距 16px，文本对齐 justify
5. .author：文字颜色 #7f8c8d，字体大小 14px，文字居中对齐
6. .highlight：背景色 #fff3cd，内边距 2px 4px
7. .intro：字体大小 18px，颜色 #555，左侧边框 4px solid #3498db，左侧内边距 16px，斜体', 'coding', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>文章排版</title>
  <!-- 在这里添加 style 标签 -->
</head>
<body>
  <h1>深入理解 CSS 盒模型</h1>
  <p class="author">作者：前端小白 | 2025年3月15日</p>
  <p class="intro">CSS 盒模型是前端开发中最基础也是最重要的概念之一，理解它对于页面布局至关重要。</p>
  <h2>什么是盒模型</h2>
  <p>每个 HTML 元素都可以看作一个<span class="highlight">矩形盒子</span>，这个盒子由内容区、内边距、边框和外边距组成。</p>
  <h2>box-sizing 属性</h2>
  <p>通过设置 box-sizing 属性，我们可以改变宽度的计算方式，让布局更加直观。</p>
</body>
</html>', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('c080c963-600b-4f6f-9564-22d80873dd3e', '52f87a47-445e-45b3-83c8-7b96f37a883e', 'css-ex4-gradient-btn', '渐变按钮与卡片', '创建一组使用渐变和阴影效果的 UI 元素。请添加 style 标签：
1. .gradient-btn：背景为 linear-gradient(to right, #667eea, #764ba2)，文字颜色白色，边框无，内边距 12px 32px，字体大小 16px，圆角 25px
2. .gradient-btn:hover：鼠标悬停时 box-shadow 为 0 4px 15px rgba(102, 126, 234, 0.4)
3. .card-gradient：宽度 300px，高度 200px，背景为 linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%)，圆角 16px
4. .card-gradient 的 box-shadow 为 0 10px 30px rgba(0,0,0,0.1)
5. body 使用 flex 布局使所有元素水平和垂直居中，高度 100vh，背景色 #f0f2f5，gap 40px', 'coding', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>渐变效果</title>
  <!-- 在这里添加 style 标签 -->
</head>
<body>
  <button class="gradient-btn">立即开始</button>
  <div class="card-gradient"></div>
</body>
</html>', 'html_css', 'intermediate', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('ef69f995-c3e4-43a5-866a-e931e5f2a34e', '52f87a47-445e-45b3-83c8-7b96f37a883e', 'css-ex4-quiz-background', '背景与边框测验', '回答以下关于 CSS 背景和边框的问题：', 'single_choice', '', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('7a0ff6bb-a2ab-43a3-85ef-6839df8c7a12', 'd31949c6-3603-48ce-9cad-a4a4bf71186c', 'css-ex5-modal', '居中模态框', '创建一个居中的模态框和背景遮罩。请添加 style 标签：
1. .overlay：position fixed，inset 0（即 top/right/bottom/left 都是 0），背景色 rgba(0,0,0,0.5)
2. .modal：position fixed，top 50%，left 50%，宽度 400px，内边距 24px，背景色白色，圆角 12px
3. .modal 使用 transform: translate(-50%, -50%) 实现完美居中
4. .modal 的 z-index 为 1000，.overlay 的 z-index 为 999
5. .close-btn：position absolute，top 16px，right 16px，背景无边框，字体大小 20px，光标 pointer', 'coding', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>模态框</title>
  <!-- 在这里添加 style 标签 -->
</head>
<body>
  <div class="overlay"></div>
  <div class="modal">
    <button class="close-btn">&times;</button>
    <h2>提示</h2>
    <p>这是一个模态框示例！</p>
  </div>
</body>
</html>', 'html_css', 'intermediate', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('7bd62366-dc6a-4e42-841a-7bf009f03af0', 'd61650d4-3162-48bb-bfa3-71401ead5115', 'layout-ex1-flex-center', 'Flexbox 完美居中', '使用 Flexbox 创建一个水平垂直居中的登录卡片。请添加 style 标签：
1. body：display flex，justify-content center，align-items center，高度 100vh，背景色 #f0f2f5，margin 0
2. .login-card：宽度 360px，内边距 40px，背景色白色，圆角 12px
3. .login-card 的 box-shadow 为 0 4px 20px rgba(0,0,0,0.08)
4. .input-group：display flex，flex-direction column，底部外边距 20px
5. .input-group 的 label：底部外边距 8px，颜色 #555，字体大小 14px
6. .input-group 的 input：内边距 12px，边框 1px solid #ddd，圆角 6px，字体大小 14px
7. button[type=submit]：宽度 100%，内边距 12px，背景色 #4a90d9，颜色白色，边框无，圆角 6px，字体大小 16px
8. button 的 margin-top 为 8px', 'coding', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>登录卡片</title>
  <!-- 在这里添加 style 标签 -->
</head>
<body>
  <div class="login-card">
    <h2>欢迎登录</h2>
    <div class="input-group">
      <label>邮箱</label>
      <input type="email" placeholder="请输入邮箱">
    </div>
    <div class="input-group">
      <label>密码</label>
      <input type="password" placeholder="请输入密码">
    </div>
    <button type="submit">登录</button>
  </div>
</body>
</html>', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('3b899010-4726-49c4-9592-4a35c843a5f8', 'd61650d4-3162-48bb-bfa3-71401ead5115', 'layout-ex1-quiz-flexbox', 'Flexbox 知识测验', '回答以下关于 Flexbox 的问题：', 'single_choice', '', 'html_css', 'intermediate', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('8f8496d1-22c4-4271-94b7-82dd29208721', 'fd17c6d3-9bb1-43ac-a2d6-9ae0c144b16c', 'layout-ex2-navbar', '响应式导航栏', '创建一个响应式导航栏。请添加 style 标签：
1. .navbar：display flex，justify-content space-between，align-items center，高度 64px，内边距 0 32px，背景色 #2c3e50
2. .logo：颜色白色，字体大小 22px，字体加粗
3. .nav-links：display flex，列表样式 none，gap 32px，margin 0，padding 0
4. .nav-links 的 a 链接：颜色 rgba(255,255,255,0.85)，文字装饰 none，字体大小 15px
5. .nav-links 的 a:hover：颜色白色
6. .cta-btn：背景色 #3498db，颜色白色，内边距 8px 20px，圆角 6px，文字装饰 none
7. body 的 margin 设为 0，字体栈 system-ui, -apple-system, sans-serif', 'coding', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>导航栏</title>
  <!-- 在这里添加 style 标签 -->
</head>
<body>
  <nav class="navbar">
    <div class="logo">CodeQuest</div>
    <ul class="nav-links">
      <li><a href="#">课程</a></li>
      <li><a href="#">练习</a></li>
      <li><a href="#">社区</a></li>
      <li><a href="#" class="cta-btn">开始学习</a></li>
    </ul>
  </nav>
</body>
</html>', 'html_css', 'intermediate', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('e224d144-1ab7-4375-bb5d-452c0a6902b0', '47ffbf2d-798f-47bf-9d3b-996ba9c99f72', 'layout-ex3-grid-gallery', '照片墙网格布局', '创建一个响应式照片墙网格。请添加 style 标签：
1. .gallery：display grid，grid-template-columns 为 repeat(auto-fill, minmax(200px, 1fr))，gap 16px，最大宽度 1200px，水平居中（margin 0 auto），内边距 20px
2. .gallery-item：圆角 12px，overflow hidden，box-shadow 为 0 2px 8px rgba(0,0,0,0.1)
3. .gallery-item 的 img：宽度 100%，高度 200px，object-fit cover，显示 block
4. 第一个 .gallery-item（使用 .featured 类）：grid-column 为 span 2，grid-row 为 span 2
5. body 背景色 #f5f5f5', 'coding', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>照片墙</title>
  <!-- 在这里添加 style 标签 -->
</head>
<body>
  <div class="gallery">
    <div class="gallery-item featured">
      <img src="https://picsum.photos/400/400?random=1" alt="Featured">
    </div>
    <div class="gallery-item">
      <img src="https://picsum.photos/200/200?random=2" alt="Photo 2">
    </div>
    <div class="gallery-item">
      <img src="https://picsum.photos/200/200?random=3" alt="Photo 3">
    </div>
    <div class="gallery-item">
      <img src="https://picsum.photos/200/200?random=4" alt="Photo 4">
    </div>
    <div class="gallery-item">
      <img src="https://picsum.photos/200/200?random=5" alt="Photo 5">
    </div>
    <div class="gallery-item">
      <img src="https://picsum.photos/200/200?random=6" alt="Photo 6">
    </div>
  </div>
</body>
</html>', 'html_css', 'intermediate', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('9477228f-3234-45a3-9bfc-29a621ad5cdf', '47ffbf2d-798f-47bf-9d3b-996ba9c99f72', 'layout-ex3-quiz-grid', 'Grid 知识测验', '回答以下关于 CSS Grid 的问题：', 'single_choice', '', 'html_css', 'intermediate', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('f65ab5d7-697b-4c5a-9d94-43e3edf470f2', '7878f3db-a944-419d-a63d-b357d94fc775', 'layout-ex4-responsive-cards', '响应式卡片布局', '创建一个响应式卡片布局。请添加 style 标签：
1. .container：display grid，gap 20px，最大宽度 1200px，margin 0 auto，内边距 20px
2. 默认（手机）：grid-template-columns 1fr
3. @media (min-width: 600px)：grid-template-columns repeat(2, 1fr)
4. @media (min-width: 900px)：grid-template-columns repeat(3, 1fr)
5. .card：背景色白色，圆角 12px，overflow hidden，box-shadow 0 2px 12px rgba(0,0,0,0.08)
6. .card-body：内边距 20px
7. .card-title：margin 0 0 12px，颜色 #2c3e50，字体大小 20px
8. .card-text：颜色 #666，行高 1.6，margin 0
9. body 背景色 #f0f2f5，字体 system-ui', 'coding', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>响应式卡片</title>
  <!-- 在这里添加 style 标签 -->
</head>
<body>
  <div class="container">
    <div class="card">
      <div class="card-body">
        <h3 class="card-title">HTML 基础</h3>
        <p class="card-text">学习 HTML 标签和页面结构，从零开始构建网页。</p>
      </div>
    </div>
    <div class="card">
      <div class="card-body">
        <h3 class="card-title">CSS 样式</h3>
        <p class="card-text">掌握 CSS 选择器和盒模型，美化你的网页。</p>
      </div>
    </div>
    <div class="card">
      <div class="card-body">
        <h3 class="card-title">响应式设计</h3>
        <p class="card-text">让你的网站在手机、平板和电脑上都能完美显示。</p>
      </div>
    </div>
  </div>
</body>
</html>', 'html_css', 'intermediate', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('ca60b1cf-2071-4e05-b17a-b30bb70c0068', '7878f3db-a944-419d-a63d-b357d94fc775', 'layout-ex4-quiz-responsive', '响应式设计测验', '回答以下关于响应式设计的问题：', 'single_choice', '', 'html_css', 'intermediate', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('432d7044-d4f6-4f91-a1da-bd3eebe0af22', '2bdb12cd-b53b-4c37-b0fc-c7f2e6a82125', 'layout-ex5-holy-grail', 'Grid 圣杯布局', '使用 CSS Grid 创建圣杯布局。请添加 style 标签：
1. .layout：display grid，min-height 100vh，grid-template-columns 240px 1fr 200px，grid-template-rows auto 1fr auto，gap 0
2. .layout 的 grid-template-areas 为：''header header header'' ''nav main aside'' ''footer footer footer''
3. .header：grid-area header，背景色 #2c3e50，颜色白色，内边距 16px 24px
4. .nav：grid-area nav，背景色 #ecf0f1，内边距 20px
5. .main：grid-area main，内边距 24px，背景色白色
6. .aside：grid-area aside，背景色 #ecf0f1，内边距 20px
7. .footer：grid-area footer，背景色 #34495e，颜色白色，内边距 16px 24px，文字居中
8. body 的 margin 0，字体 system-ui
9. @media (max-width: 768px)：grid-template-columns 1fr，grid-template-rows auto auto 1fr auto auto，areas 改为垂直排列的五行', 'coding', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>圣杯布局</title>
  <!-- 在这里添加 style 标签 -->
</head>
<body>
  <div class="layout">
    <header class="header">
      <h1>CodeQuest 学习平台</h1>
    </header>
    <nav class="nav">
      <h3>导航</h3>
      <p>HTML 基础</p>
      <p>CSS 样式</p>
      <p>JavaScript</p>
    </nav>
    <main class="main">
      <h2>欢迎来到 CodeQuest</h2>
      <p>这里是你学习前端开发的最佳平台。</p>
    </main>
    <aside class="aside">
      <h3>推荐课程</h3>
      <p>Flexbox 布局指南</p>
    </aside>
    <footer class="footer">
      <p>&copy; 2025 CodeQuest. All rights reserved.</p>
    </footer>
  </div>
</body>
</html>', 'html_css', 'intermediate', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('37e02f09-9288-4a19-8de0-bec3aa5809dc', '62e5043a-bafb-4249-827b-0c80d54bb18c', 'js-ex1-variable-types', '变量声明与类型检测', '在 script 标签中完成以下任务：
1. 使用 const 声明变量 siteName，值为 ''CodeQuest''
2. 使用 let 声明变量 userCount，值为 1000
3. 使用 let 声明变量 isOnline，值为 true
4. 使用 let 声明变量 nextLesson（不赋值）
5. 使用 const 声明变量 admin，值为 null
6. 在 console.log 中输出这5个变量的 typeof 结果，用逗号分隔
   格式：typeof(siteName), typeof(userCount), typeof(isOnline), typeof(nextLesson), typeof(admin)', 'coding', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>变量与类型</title>
</head>
<body>
  <script>
    // 在这里声明变量

    // 在这里输出 typeof 结果
  </script>
</body>
</html>', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('bf449955-addb-4c62-8a82-e09e27c30174', '62e5043a-bafb-4249-827b-0c80d54bb18c', 'js-ex1-quiz-variables', '变量与数据类型测验', '回答以下关于 JavaScript 变量和数据类型的问题：', 'single_choice', '', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('04099d40-2444-4011-89dd-a7c4dfe59740', '983c24d0-c813-4c51-a86c-f03e6a6f7e26', 'js-ex2-temperature-converter', '温度转换器', '在 script 标签中编写一个温度转换器：
1. 使用 const 声明 celsius，值为 25
2. 使用公式 fahrenheit = celsius * 9 / 5 + 32 计算华氏温度
3. 使用 console.log 输出：''25°C = 77°F''（使用模板字符串和变量，不要硬编码数字）
4. 然后添加一行：比较 fahrenheit === 77 的结果，输出 ''温度相等: true''', 'coding', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>温度转换</title>
</head>
<body>
  <script>
    // 在这里编写温度转换器
  </script>
</body>
</html>', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('5016741b-19b0-4878-96b0-fa2ea3cea76f', '983c24d0-c813-4c51-a86c-f03e6a6f7e26', 'js-ex2-quiz-operators', '运算符测验', '回答以下关于 JavaScript 运算符的问题：', 'single_choice', '', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('b0fc3659-0bce-4668-a997-3dae2866456f', '514fc8b4-ba8d-47ef-932a-85fc41894bf4', 'js-ex3-grade-calculator', '成绩等级计算器', '在 script 标签中编写成绩评级函数：
1. 使用 const 声明 score，值为 82
2. 使用 if/else if/else 判断等级：
   - score >= 90 → ''A''
   - score >= 80 → ''B''
   - score >= 70 → ''C''
   - score >= 60 → ''D''
   - 否则 → ''F''
3. 将结果存入变量 grade
4. 使用 console.log 输出：''成绩: 82, 等级: B''（使用模板字符串和变量）', 'coding', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>成绩计算</title>
</head>
<body>
  <script>
    // 在这里编写成绩评级
  </script>
</body>
</html>', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('cc241837-7a9e-4766-ad53-f9293fa2138a', '514fc8b4-ba8d-47ef-932a-85fc41894bf4', 'js-ex3-quiz-conditionals', '条件语句测验', '回答以下关于 JavaScript 条件语句的问题：', 'single_choice', '', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('71f1d9b3-b5e5-4b97-81f7-4d83e2f83dd2', '7c9997a5-d58c-418f-b45c-cd4e07a4f787', 'js-ex4-sum-even', '偶数求和', '在 script 标签中编写偶数求和程序：
1. 声明变量 sum，初始值为 0
2. 使用 for 循环，从 1 遍历到 20（包含 20）
3. 在循环中，如果当前数字是偶数（i % 2 === 0），则加到 sum
4. 循环结束后，使用 console.log 输出：''1到20的偶数之和: 110''（使用模板字符串和 sum 变量）', 'coding', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>偶数求和</title>
</head>
<body>
  <script>
    // 在这里编写求和程序
  </script>
</body>
</html>', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('44179f63-3600-4603-bb22-ca1bd8152cf1', '7c9997a5-d58c-418f-b45c-cd4e07a4f787', 'js-ex4-quiz-loops', '循环测验', '回答以下关于 JavaScript 循环的问题：', 'single_choice', '', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('4d8fdc42-cfd9-4f73-8e84-86e61f065775', '4eba55dd-9eb7-49b7-8a25-c67c7d981fd0', 'js-ex5-calculator', '简易计算器函数', '在 script 标签中实现一个计算器：
1. 用箭头函数定义 add，接收 a 和 b，返回 a + b
2. 用箭头函数定义 subtract，接收 a 和 b，返回 a - b
3. 用箭头函数定义 multiply，接收 a 和 b，返回 a * b
4. 用箭头函数定义 divide，接收 a 和 b，如果 b === 0 返回 ''不能除以零''，否则返回 a / b
5. 使用 console.log 输出 add(10, 5)、subtract(10, 5)、multiply(10, 5)、divide(10, 0) 的结果（分4行输出，每行使用模板字符串）', 'coding', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>计算器</title>
</head>
<body>
  <script>
    // 在这里定义计算函数

    // 在这里输出结果
  </script>
</body>
</html>', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('cc64706b-f3c9-4042-82c5-4f4f413852ab', '4eba55dd-9eb7-49b7-8a25-c67c7d981fd0', 'js-ex5-quiz-functions', '函数知识测验', '回答以下关于 JavaScript 函数的问题：', 'single_choice', '', 'html_css', 'beginner', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('cd6d2038-ab8d-4cec-90e2-a38b04a7b403', 'c0c4f157-e3d2-4597-9ad8-47ab28028f71', 'js-ex6-array-methods', '数组方法实战', '在 script 标签中完成数组操作：
1. 声明数组 scores，值为 [78, 92, 85, 64, 88, 91]
2. 使用 filter 方法筛选出所有 >= 80 的分数，存入 passed 变量
3. 使用 map 方法将 passed 数组中每个分数乘以 1.1（加分10%），存入 bonus 变量
4. 使用 reduce 方法计算 bonus 数组的总和，存入 total 变量
5. 使用 console.log 输出 passed、bonus 和 total（分3行）
   预期输出：[92, 85, 88, 91]、[101.2, 93.5, 96.8, 100.1]、391.6', 'coding', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>数组操作</title>
</head>
<body>
  <script>
    // 在这里编写数组操作
  </script>
</body>
</html>', 'html_css', 'intermediate', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('a2595c3e-aafe-48c1-941b-1a5313bb20fb', 'c0c4f157-e3d2-4597-9ad8-47ab28028f71', 'js-ex6-quiz-arrays', '数组知识测验', '回答以下关于 JavaScript 数组的问题：', 'single_choice', '', 'html_css', 'intermediate', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('428ec03b-67fa-41a0-b2c4-db9759f2b0d6', 'f56161a6-3c6f-4fb0-84bd-86a64d9d4c84', 'js-ex7-book-class', '图书类设计', '在 script 标签中完成以下任务：
1. 定义 Book 类，构造函数接收 title 和 author 两个参数，保存到 this.title 和 this.author
2. Book 类添加 getInfo 方法，返回模板字符串：''《title》 by author''（使用 this.title 和 this.author）
3. 创建 book1 实例：new Book(''JavaScript 高级程序设计'', ''Matt Frisbie'')
4. 创建 book2 实例：new Book(''深入理解 TypeScript'', ''Basarat Ali Syed'')
5. 使用 console.log 输出 book1.getInfo() 和 book2.getInfo()（分2行）', 'coding', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>图书类</title>
</head>
<body>
  <script>
    // 在这里定义 Book 类

    // 在这里创建实例并输出
  </script>
</body>
</html>', 'html_css', 'intermediate', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('f749cf5e-1041-4be8-ae2a-c475f6cd49e5', 'f56161a6-3c6f-4fb0-84bd-86a64d9d4c84', 'js-ex7-quiz-objects', '对象与类测验', '回答以下关于 JavaScript 对象和类的问题：', 'single_choice', '', 'html_css', 'intermediate', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('4c09ab2c-6436-48dd-adf8-499c5bee4f7c', '3b9c644d-39c5-4fb2-b4a6-9a34a40a5e4d', 'js-ex8-todo-dom', '动态待办列表', '实现一个动态待办事项列表。HTML 结构已给定，请在 script 标签中完成：
1. 获取 addBtn 元素（querySelector(''#addBtn'')），为其添加 click 事件监听器
2. 获取 input 元素（querySelector(''#todoInput'')）和 list 元素（querySelector(''#todoList'')）
3. 在点击事件处理函数中：
   a. 获取 input.value，如果为空字符串则直接 return
   b. 使用 document.createElement(''li'') 创建新 li
   c. 设置 li.textContent 为 input.value
   d. 使用 list.appendChild(li) 添加到列表末尾
   e. 将 input.value 设为空字符串（清空输入框）
4. 同时给 input 添加 keydown 事件监听，如果 event.key === ''Enter''，执行相同的添加逻辑', 'coding', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>待办列表</title>
  <style>
    body { font-family: system-ui; max-width: 400px; margin: 50px auto; }
    .input-group { display: flex; gap: 8px; margin-bottom: 16px; }
    input { flex: 1; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
    button { padding: 8px 16px; background: #3498db; color: white; border: none; border-radius: 4px; cursor: pointer; }
    li { padding: 8px; border-bottom: 1px solid #eee; }
  </style>
</head>
<body>
  <h2>我的待办</h2>
  <div class="input-group">
    <input type="text" id="todoInput" placeholder="输入待办事项...">
    <button id="addBtn">添加</button>
  </div>
  <ul id="todoList"></ul>
  <script>
    // 在这里编写 DOM 操作代码
  </script>
</body>
</html>', 'html_css', 'intermediate', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');
INSERT INTO public.exercises VALUES ('c27582c4-53cf-4f28-a8b1-f504a447be4b', '3b9c644d-39c5-4fb2-b4a6-9a34a40a5e4d', 'js-ex8-quiz-dom', 'DOM 与事件测验', '回答以下关于 JavaScript DOM 操作和事件处理的问题：', 'single_choice', '', 'html_css', 'intermediate', 0, NULL, 'published', 1, '2026-05-10 23:31:11.507163+08', '2026-05-10 23:31:11.507163+08');


--
-- Data for Name: submissions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: ai_help_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: announcements; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.announcements VALUES ('d9ee6165-135e-4cf8-a7e0-6435cb5ff295', '欢迎使用 CodeQuest 前端学习平台！', '# 欢迎来到 CodeQuest

CodeQuest 是一个专为前端初学者设计的交互式学习平台。在这里，你将通过动手实践掌握 HTML、CSS 和 JavaScript 的核心技能。

## 平台特色

- **即时反馈**：编写代码后立即看到效果和测试结果
- **渐进式学习**：从基础概念到实战项目，循序渐进
- **游戏化体验**：通过挑战、徽章和积分保持学习动力
- **每日挑战**：每天都有新的练习等你来完成

## 开始学习

1. 从 **HTML 基础入门** 课程开始
2. 完成每个章节的编码练习和选择题
3. 挑战 **HTML 标签大师** 挑战测试你的知识
4. 保持每日学习习惯，解锁成就徽章

祝你学习愉快！', 'all_learners', 'published', NULL, NULL, '94fdf828-ccfb-436d-9683-8dbbd5000da5', '2026-05-10 23:31:11.535088+08', '2026-05-10 23:31:11.535088+08');
INSERT INTO public.announcements VALUES ('8a9d77bc-4145-4c24-95c0-349009f6ac8a', '新增 CSS 布局精通课程！', '# 新课程上线

我们很高兴地宣布 **CSS 布局精通** 课程正式上线！

## 课程内容

本课程涵盖现代 CSS 布局的核心技术：

### 第1章：Flexbox 弹性盒子基础
- Flex 容器和项目属性
- 水平垂直居中
- 常见布局模式

### 第2章：Flexbox 实战布局模式
- 导航栏、卡片列表
- 底部固定布局
- 自适应表单

### 第3章：CSS Grid 网格布局
- Grid 模板定义
- 项目放置和对齐
- 命名区域布局

### 第4章：响应式设计
- 媒体查询和断点
- 移动优先策略
- 响应式图片

### 第5章：圣杯布局实战
- 综合运用 Flexbox + Grid
- 经典布局模式实现

## 配套挑战

同时上线的还有 **布局达人** 挑战，完成全部 5 个关卡可获得 250 XP 和「布局大师」徽章！

立即开始学习吧！', 'all_learners', 'published', NULL, NULL, '94fdf828-ccfb-436d-9683-8dbbd5000da5', '2026-05-10 23:31:11.535088+08', '2026-05-10 23:31:11.535088+08');
INSERT INTO public.announcements VALUES ('81cb4560-5a7e-4d63-9bfd-f81ae6639605', '系统维护通知', '# 系统维护通知

为了提供更稳定的服务，我们将进行计划维护：

**维护时间**：2026年5月20日 02:00 - 04:00 (UTC+8)

**影响范围**：
- 课程学习功能将暂停
- 用户登录可能受影响
- 排行榜和积分更新将延迟

**维护内容**：
- 数据库性能优化
- 新增练习自动评测功能
- 升级代码编辑器组件

请提前安排你的学习计划，避免在维护时段进行练习。感谢你的理解与支持！', 'all', 'published', NULL, NULL, '94fdf828-ccfb-436d-9683-8dbbd5000da5', '2026-05-10 23:31:11.535088+08', '2026-05-10 23:31:11.535088+08');
INSERT INTO public.announcements VALUES ('3286a65e-35fd-4c8a-895e-98aa56299fe7', '管理员操作手册更新', '# 管理员操作手册 V1.1

本次更新包含以下内容：

## 新增功能
- 课程数据统计面板
- 用户学习进度导出
- 批量导入练习题目

## 操作流程

### 发布新课程
1. 进入「课程管理」页面
2. 点击「新建课程」按钮
3. 填写课程基本信息（标题、描述、难度等）
4. 逐章添加章节内容
5. 为每个章节配置练习题目
6. 预览确认后发布

### 审核用户反馈
1. 在「反馈管理」查看待审核条目
2. 查看用户提交的详细信息和截图
3. 选择处理方式：采纳/拒绝/标记
4. 填写处理备注

如有疑问请联系技术团队。', 'all_admins', 'published', NULL, NULL, '94fdf828-ccfb-436d-9683-8dbbd5000da5', '2026-05-10 23:31:11.535088+08', '2026-05-10 23:31:11.535088+08');
INSERT INTO public.announcements VALUES ('39029a7b-a703-429c-988e-b91f1497dc60', '五一学习马拉松活动预告', '# 五一学习马拉松活动

为庆祝五一劳动节，CodeQuest 将举办为期 5 天的学习马拉松活动！

## 活动时间
2026年5月1日 - 5月5日

## 活动内容

### 每日挑战加倍
活动期间，每日挑战的 XP 奖励 **翻倍**！

### 限时挑战
活动期间将推出 3 个限时挑战：
- HTML 极速通关（5月1日-2日）
- CSS 样式冲刺（5月3日-4日）
- 布局终极挑战（5月5日）

### 排行榜竞赛
活动期间累计 XP 排名前 10 的用户将获得：
- 第1名：年度 VIP 会员 + 限量版徽章
- 第2-3名：季度 VIP 会员
- 第4-10名：月度 VIP 会员

## 参与方式
活动期间正常登录平台，完成每日挑战和课程练习即可自动参与活动。

准备好了吗？让我们一起在五一假期精进前端技能！', 'all_learners', 'published', NULL, NULL, '94fdf828-ccfb-436d-9683-8dbbd5000da5', '2026-05-10 23:31:11.535088+08', '2026-05-10 23:31:11.535088+08');
INSERT INTO public.announcements VALUES ('9a0214da-a3c1-4f20-a799-a55ad48e8aa9', 'JavaScript 基础入门课程正式上线！', '# JavaScript 基础入门课程发布

我们非常兴奋地宣布：**JavaScript 基础入门** 课程正式上线！

## 课程内容

本课程基于 MDN Web Docs 官方 JavaScript 学习路径，涵盖 8 大核心章节：

### 第1章：变量与数据类型
- let / const / var 的区别
- String、Number、Boolean、Null、Undefined
- typeof 检测与类型转换

### 第2章：运算符与表达式
- 算术、比较、逻辑运算符
- 严格相等 === vs 松散相等 ==
- 运算符优先级

### 第3章：条件语句
- if / else if / else
- switch 多分支
- 三元运算符

### 第4章：循环语句
- for / while / do...while
- for...of 遍历数组
- break / continue 控制

### 第5章：函数定义与调用
- 函数声明 vs 表达式 vs 箭头函数
- 默认参数与剩余参数
- 作用域与闭包

### 第6章：数组操作
- push / pop / shift / unshift
- map / filter / reduce
- 数组解构

### 第7章：对象与类
- 对象创建与属性操作
- ES6 Class 与继承
- 对象解构与展开运算符

### 第8章：DOM 操作与事件处理
- 选择元素、修改内容和样式
- 创建和添加元素
- addEventListener 与事件委托

## 配套内容

- **JS 编码先锋** 挑战（200 XP）
- **逻辑与函数** 专项挑战（120 XP）
- 4 个 JS 主题每日挑战

立即开始你的 JavaScript 学习之旅吧！', 'all_learners', 'published', NULL, NULL, '94fdf828-ccfb-436d-9683-8dbbd5000da5', '2026-05-10 23:31:11.535088+08', '2026-05-10 23:31:11.535088+08');


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: badges; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.badges VALUES ('91b2e841-1d68-4b09-a776-fde4f7ae9a28', 'first-step', '第一步', '完成第一个编程练习', NULL, 'manual', '{}', 'published', '2026-05-10 23:31:11.530677+08', '2026-05-10 23:31:11.530677+08');
INSERT INTO public.badges VALUES ('293095a1-7014-483f-91dc-a589b63409d1', 'html-rookie', 'HTML 新秀', '完成 HTML 基础入门课程中的所有练习', NULL, 'course', '{}', 'published', '2026-05-10 23:31:11.530677+08', '2026-05-10 23:31:11.530677+08');
INSERT INTO public.badges VALUES ('3a201d88-28fa-48ba-a64b-2148207c3690', 'css-rookie', 'CSS 新秀', '完成 CSS 样式基础课程中的所有练习', NULL, 'course', '{}', 'published', '2026-05-10 23:31:11.530677+08', '2026-05-10 23:31:11.530677+08');
INSERT INTO public.badges VALUES ('d8f84db3-1ba5-4f19-987d-a3619d1aa2db', 'layout-master', '布局大师', '完成 CSS 布局精通课程中的所有练习', NULL, 'course', '{}', 'published', '2026-05-10 23:31:11.530677+08', '2026-05-10 23:31:11.530677+08');
INSERT INTO public.badges VALUES ('f7f8d38f-f66b-40a6-91d4-ad6516a87504', 'challenge-champion', '挑战冠军', '完成任意一个挑战的全部关卡', NULL, 'challenge', '{}', 'published', '2026-05-10 23:31:11.530677+08', '2026-05-10 23:31:11.530677+08');
INSERT INTO public.badges VALUES ('f33830d5-ab02-4f41-9a88-2708feb5667d', 'streak-week', '坚持不懈', '连续 7 天完成每日挑战', NULL, 'streak', '{}', 'published', '2026-05-10 23:31:11.530677+08', '2026-05-10 23:31:11.530677+08');
INSERT INTO public.badges VALUES ('89fcee6a-2971-403d-857c-cca002193cb3', 'perfect-score', '满分达人', '在一次测验中获得满分', NULL, 'manual', '{}', 'published', '2026-05-10 23:31:11.530677+08', '2026-05-10 23:31:11.530677+08');
INSERT INTO public.badges VALUES ('80294ad6-a336-4e01-9ee8-15b98f46ed3c', 'early-bird', '早鸟先锋', '在每日挑战发布后的前 1 小时内完成', NULL, 'manual', '{}', 'published', '2026-05-10 23:31:11.530677+08', '2026-05-10 23:31:11.530677+08');
INSERT INTO public.badges VALUES ('a866a05f-e431-4cbf-b459-aa72f20823b5', 'html-semantic-pro', '语义化专家', '在语义化相关的所有练习中正确回答每一道选择题', NULL, 'manual', '{}', 'published', '2026-05-10 23:31:11.530677+08', '2026-05-10 23:31:11.530677+08');
INSERT INTO public.badges VALUES ('f29d2602-b6ae-4e2d-9ee8-907ac0682aca', 'responsive-designer', '响应式设计者', '完成所有响应式布局相关的练习', NULL, 'course', '{}', 'published', '2026-05-10 23:31:11.530677+08', '2026-05-10 23:31:11.530677+08');
INSERT INTO public.badges VALUES ('05f17648-6b07-4e41-8ae1-8d6a77e1b2cc', 'js-rookie', 'JS 新秀', '完成 JavaScript 基础入门课程中的所有练习', NULL, 'course', '{}', 'published', '2026-05-10 23:31:11.530677+08', '2026-05-10 23:31:11.530677+08');
INSERT INTO public.badges VALUES ('003c8297-7588-489b-b43b-b98a2303a193', 'dom-wizard', 'DOM 魔法师', '完成所有 DOM 操作和事件处理相关的编码练习', NULL, 'manual', '{}', 'published', '2026-05-10 23:31:11.530677+08', '2026-05-10 23:31:11.530677+08');
INSERT INTO public.badges VALUES ('5057257d-3c79-40d5-a16c-34d903284241', 'function-master', '函数大师', '所有函数相关练习一次性通过，无错误提交', NULL, 'manual', '{}', 'published', '2026-05-10 23:31:11.530677+08', '2026-05-10 23:31:11.530677+08');


--
-- Data for Name: challenges; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.challenges VALUES ('cf2f7be4-ba58-4ff6-aef2-c9350841d579', 'ch-html-master', 'HTML 标签大师', '测试你对 HTML 基础标签和语义化元素的综合掌握程度', NULL, 'beginner', 150, 'published', 0, 1, '2026-05-10 23:31:11.520628+08', '2026-05-11 03:12:44.232727+08', '2026-05-11 03:12:44.232727+08');
INSERT INTO public.challenges VALUES ('41902b4e-0ed0-4daf-aa6d-7a1b493f6b1c', 'ch-css-stylist', 'CSS 样式专家', '挑战你的 CSS 选择器、盒模型和排版技能', NULL, 'beginner', 150, 'published', 0, 1, '2026-05-10 23:31:11.520628+08', '2026-05-11 03:12:44.232727+08', '2026-05-11 03:12:44.232727+08');
INSERT INTO public.challenges VALUES ('cd15426e-ee90-4e79-861f-35c22cd4e0a3', 'ch-layout-guru', '布局达人', '综合运用 Flexbox 和 Grid 完成复杂布局挑战', NULL, 'intermediate', 250, 'published', 0, 1, '2026-05-10 23:31:11.520628+08', '2026-05-11 03:12:44.232727+08', '2026-05-11 03:12:44.232727+08');
INSERT INTO public.challenges VALUES ('6ba30193-16fc-4a59-beca-fa40f708bd47', 'ch-beginner-sprint', '新手冲刺', '专为初学者设计的快速入门挑战，覆盖 HTML 和 CSS 基础', NULL, 'beginner', 100, 'published', 0, 1, '2026-05-10 23:31:11.520628+08', '2026-05-11 03:12:44.232727+08', '2026-05-11 03:12:44.232727+08');
INSERT INTO public.challenges VALUES ('f354d0a6-a6db-4e80-99b9-21db53f03e5a', 'ch-semantic-pro', '语义化大师', '深入测试 HTML5 语义化标签的理解和应用能力', NULL, 'beginner', 120, 'published', 0, 1, '2026-05-10 23:31:11.520628+08', '2026-05-11 03:12:44.232727+08', '2026-05-11 03:12:44.232727+08');
INSERT INTO public.challenges VALUES ('a2e47984-9c9f-4459-bfa4-549daee22549', 'ch-js-coder', 'JS 编码先锋', '全面测试 JavaScript 基础语法掌握程度，从变量到 DOM 操作', NULL, 'beginner', 200, 'published', 0, 1, '2026-05-10 23:31:11.520628+08', '2026-05-11 03:12:44.232727+08', '2026-05-11 03:12:44.232727+08');
INSERT INTO public.challenges VALUES ('14610dfd-b788-491c-bc50-5211cf968bc9', 'ch-js-logic', '逻辑与函数挑战', '专注测试条件判断、循环和函数定义的编程能力', NULL, 'beginner', 120, 'published', 0, 1, '2026-05-10 23:31:11.520628+08', '2026-05-11 03:12:44.232727+08', '2026-05-11 03:12:44.232727+08');


--
-- Data for Name: challenge_attempts; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: challenge_stages; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.challenge_stages VALUES ('b37debe0-4163-459c-b4ae-41e5d2858784', 'cf2f7be4-ba58-4ff6-aef2-c9350841d579', 'b793abc0-2496-4e3a-b444-2f2254c9913b', 1, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('1619fda6-05e3-428a-8fff-8a31596ce554', 'cf2f7be4-ba58-4ff6-aef2-c9350841d579', 'b6bf5c42-3520-4953-9e33-91339e31e903', 2, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('12898d97-5f86-4928-9e3e-0fb76374b12f', 'cf2f7be4-ba58-4ff6-aef2-c9350841d579', '63b00b44-a4fa-4263-a5f7-996160fccf46', 3, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('6911086e-3f8a-48e3-be1f-7f9c5feea106', 'cf2f7be4-ba58-4ff6-aef2-c9350841d579', 'ef7bfc65-ea82-4aea-93b9-75706f232cdc', 4, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('b04acd28-8cc6-4fa2-b7fe-332d88ee0c4d', 'cf2f7be4-ba58-4ff6-aef2-c9350841d579', '16518b1b-90e6-4ef3-892a-190f0492b5cb', 5, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('33a6be5b-8716-4931-8eef-b6c38c096b93', 'cf2f7be4-ba58-4ff6-aef2-c9350841d579', '6ce8865f-2269-409e-87c2-85619c99871a', 6, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('8307dfe9-26f0-46bc-bba2-5501e2240bbd', '41902b4e-0ed0-4daf-aa6d-7a1b493f6b1c', '5e4d6abc-81c7-4207-b2e1-93d5cd53dab8', 1, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('09520a1c-676d-4ea0-8bb2-a004ceb77762', '41902b4e-0ed0-4daf-aa6d-7a1b493f6b1c', '872db405-81f1-45fa-bb23-f7e42a9ae516', 2, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('9920a43f-c239-4e80-8315-67549cfc4317', '41902b4e-0ed0-4daf-aa6d-7a1b493f6b1c', '971655af-6ef3-4ce9-8cc4-e83db1907ee4', 3, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('a1dc4b57-d99c-419f-a8a9-8ee99d884ca6', '41902b4e-0ed0-4daf-aa6d-7a1b493f6b1c', 'c080c963-600b-4f6f-9564-22d80873dd3e', 4, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('be1c0cda-e219-432e-915c-5d508f432871', '41902b4e-0ed0-4daf-aa6d-7a1b493f6b1c', '7a0ff6bb-a2ab-43a3-85ef-6839df8c7a12', 5, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('f766043c-0ae5-4380-823d-ff34c3b01bde', 'cd15426e-ee90-4e79-861f-35c22cd4e0a3', '7bd62366-dc6a-4e42-841a-7bf009f03af0', 1, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('669851b8-2586-4b9a-bcf5-ac21ae7a5d0d', 'cd15426e-ee90-4e79-861f-35c22cd4e0a3', '8f8496d1-22c4-4271-94b7-82dd29208721', 2, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('2c3a7abe-6184-43ea-b44d-c1ae1a54308d', 'cd15426e-ee90-4e79-861f-35c22cd4e0a3', 'e224d144-1ab7-4375-bb5d-452c0a6902b0', 3, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('19ff5bb7-444c-46dc-b179-130b6a968360', 'cd15426e-ee90-4e79-861f-35c22cd4e0a3', 'f65ab5d7-697b-4c5a-9d94-43e3edf470f2', 4, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('af46d575-cb6b-4510-90aa-2d28e5f39c2e', 'cd15426e-ee90-4e79-861f-35c22cd4e0a3', '432d7044-d4f6-4f91-a1da-bd3eebe0af22', 5, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('fba97874-b98d-4c68-80cc-a195f4ced811', '6ba30193-16fc-4a59-beca-fa40f708bd47', 'b793abc0-2496-4e3a-b444-2f2254c9913b', 1, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('4a643df5-2b51-4c05-aeb7-f3b52dcb6f39', '6ba30193-16fc-4a59-beca-fa40f708bd47', 'b6bf5c42-3520-4953-9e33-91339e31e903', 2, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('5afa2d20-469b-4541-91b8-f87eaf29a1e6', '6ba30193-16fc-4a59-beca-fa40f708bd47', '872db405-81f1-45fa-bb23-f7e42a9ae516', 3, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('81574792-0493-4fa1-8003-df7ac0be38d3', '6ba30193-16fc-4a59-beca-fa40f708bd47', '7bd62366-dc6a-4e42-841a-7bf009f03af0', 4, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('4133421e-8b52-4c12-8954-d31725807ad1', 'f354d0a6-a6db-4e80-99b9-21db53f03e5a', '63b00b44-a4fa-4263-a5f7-996160fccf46', 1, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('99c82d6f-04b1-4d63-b121-cbc207d14edc', 'f354d0a6-a6db-4e80-99b9-21db53f03e5a', 'ef7bfc65-ea82-4aea-93b9-75706f232cdc', 2, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('e1572759-e69e-4ad2-ae8d-bf3dea848552', 'f354d0a6-a6db-4e80-99b9-21db53f03e5a', '432d7044-d4f6-4f91-a1da-bd3eebe0af22', 3, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('778e8335-13cf-414f-852a-aaa62cd6dcb5', 'a2e47984-9c9f-4459-bfa4-549daee22549', '37e02f09-9288-4a19-8de0-bec3aa5809dc', 1, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('840efd70-07ff-4109-83ed-b5697fe721b9', 'a2e47984-9c9f-4459-bfa4-549daee22549', '04099d40-2444-4011-89dd-a7c4dfe59740', 2, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('d09a3820-40a6-493f-8db6-73bc1de92f19', 'a2e47984-9c9f-4459-bfa4-549daee22549', 'b0fc3659-0bce-4668-a997-3dae2866456f', 3, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('0732a309-8eb0-48e1-8557-deb7852d7b82', 'a2e47984-9c9f-4459-bfa4-549daee22549', '71f1d9b3-b5e5-4b97-81f7-4d83e2f83dd2', 4, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('1a58695b-6907-4144-9357-ef09a4141570', 'a2e47984-9c9f-4459-bfa4-549daee22549', '4d8fdc42-cfd9-4f73-8e84-86e61f065775', 5, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('679dacfb-f264-45e5-b89e-df116bde439b', 'a2e47984-9c9f-4459-bfa4-549daee22549', 'cd6d2038-ab8d-4cec-90e2-a38b04a7b403', 6, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('4eef921f-d3e8-455e-98c4-6903720a9dfc', 'a2e47984-9c9f-4459-bfa4-549daee22549', '428ec03b-67fa-41a0-b2c4-db9759f2b0d6', 7, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('e1e10181-5e6c-4397-8974-915f8ad7c732', 'a2e47984-9c9f-4459-bfa4-549daee22549', '4c09ab2c-6436-48dd-adf8-499c5bee4f7c', 8, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('f5be1f72-b0b3-4d9f-84f6-f7c33ebf0dd6', '14610dfd-b788-491c-bc50-5211cf968bc9', 'b0fc3659-0bce-4668-a997-3dae2866456f', 1, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('ea8acb30-7e84-495b-83da-616451a2a316', '14610dfd-b788-491c-bc50-5211cf968bc9', '71f1d9b3-b5e5-4b97-81f7-4d83e2f83dd2', 2, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('00fc7a22-24a0-4e43-a74b-638318f335ef', '14610dfd-b788-491c-bc50-5211cf968bc9', '4d8fdc42-cfd9-4f73-8e84-86e61f065775', 3, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');
INSERT INTO public.challenge_stages VALUES ('4c10f811-71a7-4cdc-978d-f44fc6834667', '14610dfd-b788-491c-bc50-5211cf968bc9', 'cd6d2038-ab8d-4cec-90e2-a38b04a7b403', 4, '{}', '{}', 1, '2026-05-10 23:31:11.523323+08', '2026-05-10 23:31:11.523323+08');


--
-- Data for Name: course_progress; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: daily_challenges; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.daily_challenges VALUES ('8ca8acff-e7d1-4af3-93f0-84bb85933a8d', '2026-05-10', 'HTML 结构大挑战', 'b793abc0-2496-4e3a-b444-2f2254c9913b', 'beginner', 300, 50, 'active', '2026-05-11 03:21:04.48151+08', '2026-05-10 23:31:11.526646+08', '2026-05-11 03:21:04.48151+08');
INSERT INTO public.daily_challenges VALUES ('93ce1f13-e47e-440f-af7e-d014e9317261', '2026-05-11', '文章排版挑战', 'b6bf5c42-3520-4953-9e33-91339e31e903', 'beginner', 400, 60, 'active', '2026-05-11 03:21:04.48151+08', '2026-05-10 23:31:11.526646+08', '2026-05-11 03:21:04.48151+08');
INSERT INTO public.daily_challenges VALUES ('9dc5e2e5-2eef-404a-81d6-b4ad178d7d53', '2026-05-12', '卡片样式设计', '872db405-81f1-45fa-bb23-f7e42a9ae516', 'beginner', 600, 70, 'active', '2026-05-11 03:21:04.48151+08', '2026-05-10 23:31:11.526646+08', '2026-05-11 03:21:04.48151+08');
INSERT INTO public.daily_challenges VALUES ('4af49a02-63cd-42a9-9e38-997ca8e3f441', '2026-05-13', 'Flexbox 居中挑战', '7bd62366-dc6a-4e42-841a-7bf009f03af0', 'beginner', 500, 65, 'active', '2026-05-11 03:21:04.48151+08', '2026-05-10 23:31:11.526646+08', '2026-05-11 03:21:04.48151+08');
INSERT INTO public.daily_challenges VALUES ('bece7089-b73f-459f-941b-ba8856c3ff69', '2026-05-14', '照片墙网格布局', 'e224d144-1ab7-4375-bb5d-452c0a6902b0', 'intermediate', 900, 100, 'active', '2026-05-11 03:21:04.48151+08', '2026-05-10 23:31:11.526646+08', '2026-05-11 03:21:04.48151+08');
INSERT INTO public.daily_challenges VALUES ('e3b1d440-a2b9-4d31-afbc-96bb9cf7743e', '2026-05-15', '响应式卡片布局', 'f65ab5d7-697b-4c5a-9d94-43e3edf470f2', 'intermediate', 800, 90, 'active', '2026-05-11 03:21:04.48151+08', '2026-05-10 23:31:11.526646+08', '2026-05-11 03:21:04.48151+08');
INSERT INTO public.daily_challenges VALUES ('83ca143e-ec70-4625-914a-da8beb22691f', '2026-05-16', '注册表单实战', '6ce8865f-2269-409e-87c2-85619c99871a', 'intermediate', 700, 80, 'active', '2026-05-11 03:21:04.48151+08', '2026-05-10 23:31:11.526646+08', '2026-05-11 03:21:04.48151+08');
INSERT INTO public.daily_challenges VALUES ('86ecd6fb-df85-4ac0-9d6a-3aeab48052ef', '2026-05-17', 'JS 变量与类型', '37e02f09-9288-4a19-8de0-bec3aa5809dc', 'beginner', 400, 55, 'active', '2026-05-11 03:21:04.48151+08', '2026-05-10 23:31:11.526646+08', '2026-05-11 03:21:04.48151+08');
INSERT INTO public.daily_challenges VALUES ('9f436a6b-6028-45f1-9ba2-f90fb8b37f4a', '2026-05-18', 'JS 函数编写', '4d8fdc42-cfd9-4f73-8e84-86e61f065775', 'beginner', 600, 70, 'active', '2026-05-11 03:21:04.48151+08', '2026-05-10 23:31:11.526646+08', '2026-05-11 03:21:04.48151+08');
INSERT INTO public.daily_challenges VALUES ('71507e38-b7eb-4c23-a646-181c2799e9fa', '2026-05-19', '数组方法实战', 'cd6d2038-ab8d-4cec-90e2-a38b04a7b403', 'intermediate', 800, 85, 'active', '2026-05-11 03:21:04.48151+08', '2026-05-10 23:31:11.526646+08', '2026-05-11 03:21:04.48151+08');
INSERT INTO public.daily_challenges VALUES ('a9ba0473-b31a-49ae-8aa0-1d3290cfaada', '2026-05-20', 'DOM 操作挑战', '4c09ab2c-6436-48dd-adf8-499c5bee4f7c', 'intermediate', 900, 100, 'active', '2026-05-11 03:21:04.48151+08', '2026-05-10 23:31:11.526646+08', '2026-05-11 03:21:04.48151+08');


--
-- Data for Name: daily_challenge_records; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: exercise_options; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.exercise_options VALUES ('9cec0422-147d-4440-960f-c90c09cf2ca7', '48b259dc-8b5f-450a-91ce-4e9ccfa1ab82', 'A', '以下哪个是空元素（void element）？', false, 0);
INSERT INTO public.exercise_options VALUES ('cc2b0bb0-c942-48fb-9108-3a9e263d08fb', '48b259dc-8b5f-450a-91ce-4e9ccfa1ab82', 'B', 'HTML 中用于指定字符编码的 meta 标签属性是？', true, 1);
INSERT INTO public.exercise_options VALUES ('35b8d23e-c03a-4bc0-9ab8-e67e43087303', '48b259dc-8b5f-450a-91ce-4e9ccfa1ab82', 'C', '以下哪个标签定义了 HTML 文档的可见内容区域？', true, 2);
INSERT INTO public.exercise_options VALUES ('07fcc791-c68a-43e6-af97-858dd59a5934', '5228bafd-9435-42de-865d-98a25ffb587b', 'A', '要标记一个化学公式中的下标数字（如 H₂O），应使用哪个标签？', true, 0);
INSERT INTO public.exercise_options VALUES ('74bc2847-5385-4b3b-921f-0f9be7a10b30', '5228bafd-9435-42de-865d-98a25ffb587b', 'B', '在网页中表示一段重要警告信息，应该使用哪个标签？', false, 1);
INSERT INTO public.exercise_options VALUES ('12ee7775-d85a-477c-834d-dd86d9eb8fad', '5228bafd-9435-42de-865d-98a25ffb587b', 'C', '以下代码中，哪种列表最适合表示食谱的步骤说明？', false, 2);
INSERT INTO public.exercise_options VALUES ('f491aa9a-a12a-49b2-94bb-00c5701f6960', '83651de8-d2ba-4623-86cc-8e15dff47f0d', 'A', '一个新闻网站中，每篇独立的新闻报道最适合使用哪个标签包裹？', false, 0);
INSERT INTO public.exercise_options VALUES ('97806fda-b77d-4ae3-9df7-a66208d267f4', '83651de8-d2ba-4623-86cc-8e15dff47f0d', 'B', '以下哪种写法是错误的（一个页面中不应该出现的情况）？', true, 1);
INSERT INTO public.exercise_options VALUES ('703783a7-33ce-470c-840b-679242cd7dfa', '83651de8-d2ba-4623-86cc-8e15dff47f0d', 'C', '对于页面中的面包屑导航和文章标签云，分别最适合使用什么标签？', false, 2);
INSERT INTO public.exercise_options VALUES ('43179d78-1e68-49e3-9f25-3b0231ff11d0', '6f44bcaf-6334-4cb5-881d-0a11a8cde744', 'A', '在表格中，以下哪个元素用于定义列的标题？', false, 0);
INSERT INTO public.exercise_options VALUES ('cf2c05d9-43f6-4926-9715-20ad5aab82bb', '6f44bcaf-6334-4cb5-881d-0a11a8cde744', 'B', '要让一个单元格横跨两列，应该使用哪个属性？', true, 1);
INSERT INTO public.exercise_options VALUES ('d6834829-3c0d-41c3-a1bd-1f2ed84ecf37', '10213507-7f83-4974-8ab8-ab1bc8d29c76', 'A', '要让一组单选按钮互斥（只能选一个），需要设置什么属性相同？', false, 0);
INSERT INTO public.exercise_options VALUES ('0160fd8c-21ca-4c16-ab69-b5be3a55acbb', '10213507-7f83-4974-8ab8-ab1bc8d29c76', 'B', 'input type="email" 的优势是什么？', true, 1);
INSERT INTO public.exercise_options VALUES ('c76b2c19-1ce5-4fb1-a8b7-4cd92f50e9e4', '10213507-7f83-4974-8ab8-ab1bc8d29c76', 'C', 'label 元素的 for 属性应该与哪个属性值对应？', false, 2);
INSERT INTO public.exercise_options VALUES ('9e351d07-e4e0-4192-8b0c-d6b9558088f6', '1861e14c-77fc-4f86-845d-1368c152945e', 'A', '选择器 ''#nav .menu-item a:hover'' 的优先级权重是多少？', true, 0);
INSERT INTO public.exercise_options VALUES ('2ca5a97c-53c9-4914-a901-eca16714835f', '1861e14c-77fc-4f86-845d-1368c152945e', 'B', '以下哪种方式引入的 CSS 优先级最高？', false, 1);
INSERT INTO public.exercise_options VALUES ('f5d2a418-3795-4b06-88a6-e8b1423c7922', '1861e14c-77fc-4f86-845d-1368c152945e', 'C', '要让所有奇数行的 li 背景色为灰色，应该使用哪个选择器？', false, 2);
INSERT INTO public.exercise_options VALUES ('da37b0dc-e74f-4d5d-b7be-00b96cf83b61', 'bcc98785-7e52-48f2-8565-f76dc6829ee0', 'A', '在默认的 content-box 模式下，一个元素设置 width: 300px, padding: 20px, border: 5px，它的实际占据宽度是多少？', false, 0);
INSERT INTO public.exercise_options VALUES ('7da1da96-a739-4108-9a15-ea5d9234e0a8', 'bcc98785-7e52-48f2-8565-f76dc6829ee0', 'B', '以下哪个是全局设置 border-box 的推荐写法？', false, 1);
INSERT INTO public.exercise_options VALUES ('0aa49d45-c33d-4bb3-af9f-32fd2f0efdf7', 'ef69f995-c3e4-43a5-866a-e931e5f2a34e', 'A', 'background-size: cover 和 contain 的区别是什么？', true, 0);
INSERT INTO public.exercise_options VALUES ('9df321a0-f638-4eaa-a047-3b5e3a998be9', 'ef69f995-c3e4-43a5-866a-e931e5f2a34e', 'B', '要将一个元素设置为正圆形，border-radius 应该设置为什么值？', true, 1);
INSERT INTO public.exercise_options VALUES ('311f7463-6df7-42b9-a3d4-aad2c68b6df7', '3b899010-4726-49c4-9592-4a35c843a5f8', 'A', '在 Flexbox 中，哪个属性用于设置项目在主轴上的对齐方式？', false, 0);
INSERT INTO public.exercise_options VALUES ('7886f25f-e91a-4739-a849-d104b44169be', '3b899010-4726-49c4-9592-4a35c843a5f8', 'B', 'flex: 1 是以下哪种写法的简写？', false, 1);
INSERT INTO public.exercise_options VALUES ('c6a5d230-1212-4e1e-9f51-eff3f4f1b386', '3b899010-4726-49c4-9592-4a35c843a5f8', 'C', '要让三个 flex 项目均分容器宽度（每个占 1/3），以下哪种写法是正确的？', false, 2);
INSERT INTO public.exercise_options VALUES ('24a46865-2f82-4419-aab5-ee1a319aff03', '9477228f-3234-45a3-9bfc-29a621ad5cdf', 'A', 'CSS Grid 中的 1fr 单位表示什么？', false, 0);
INSERT INTO public.exercise_options VALUES ('113e781e-96a5-4c40-9eed-745423f02fdb', '9477228f-3234-45a3-9bfc-29a621ad5cdf', 'B', 'grid-template-areas 中，用什么符号表示空白单元格？', false, 1);
INSERT INTO public.exercise_options VALUES ('d68ce0bb-3c5d-4b57-89a2-9aa7eb919b2d', '9477228f-3234-45a3-9bfc-29a621ad5cdf', 'C', '以下哪个属性用于让 Grid 项目在其单元格内水平居中？', false, 2);
INSERT INTO public.exercise_options VALUES ('911bdca9-8975-4812-9bbf-568f7885eaf5', 'ca60b1cf-2071-4e05-b17a-b30bb70c0068', 'A', '移动优先（Mobile First）的设计策略是指？', false, 0);
INSERT INTO public.exercise_options VALUES ('ef062374-1858-43d0-8798-2b9bf4927783', 'ca60b1cf-2071-4e05-b17a-b30bb70c0068', 'B', '以下哪个 viewport meta 标签设置是正确的？', true, 1);
INSERT INTO public.exercise_options VALUES ('a2263305-c613-49ce-b46b-2e7d4656a4c0', 'ca60b1cf-2071-4e05-b17a-b30bb70c0068', 'C', '在响应式设计中，图片应该使用什么 CSS 属性确保不溢出容器？', false, 2);
INSERT INTO public.exercise_options VALUES ('307c35c5-146d-49bd-b702-2bf6fa8e7d71', 'bf449955-addb-4c62-8a82-e09e27c30174', 'A', '以下哪个声明方式具有块级作用域？', false, 0);
INSERT INTO public.exercise_options VALUES ('6f841a6d-74f3-4c7e-9eec-52b523bf169d', 'bf449955-addb-4c62-8a82-e09e27c30174', 'B', 'typeof null 的返回值是什么？', false, 1);
INSERT INTO public.exercise_options VALUES ('63cf8fb3-a21c-4762-aa4b-b5f2500118bc', 'bf449955-addb-4c62-8a82-e09e27c30174', 'C', 'const 声明的变量能否重新赋值？', false, 2);
INSERT INTO public.exercise_options VALUES ('7120d46c-9a4d-4eec-ad61-e0a63222b6db', 'bf449955-addb-4c62-8a82-e09e27c30174', 'D', '以下哪个是模板字符串的正确语法？', false, 3);
INSERT INTO public.exercise_options VALUES ('ca15d0d3-08ea-4cf1-be31-aad60b0fee90', '5016741b-19b0-4878-96b0-fa2ea3cea76f', 'A', '表达式 0 == false && '''' == false 的结果是？', true, 0);
INSERT INTO public.exercise_options VALUES ('ef0a540c-c866-4f3d-bffb-9792506024c5', '5016741b-19b0-4878-96b0-fa2ea3cea76f', 'B', 'let result = 10 + 5 * 2 - 8 / 4; result 的值是？', false, 1);
INSERT INTO public.exercise_options VALUES ('ef7809cf-8a26-4373-ab44-08a7bc03686d', '5016741b-19b0-4878-96b0-fa2ea3cea76f', 'C', '以下哪个表达式结果为 true？', false, 2);
INSERT INTO public.exercise_options VALUES ('47e6952c-1932-4f9a-b00d-c63ff7ca07e9', 'cc241837-7a9e-4766-ad53-f9293fa2138a', 'A', '以下代码的输出是什么？
let x = 5;
if (x) { console.log(''A''); } else { console.log(''B''); }', true, 0);
INSERT INTO public.exercise_options VALUES ('437d1d31-5cbc-4ac7-ae7d-c9a37a2f932a', 'cc241837-7a9e-4766-ad53-f9293fa2138a', 'B', 'switch 语句中忘记写 break 会导致什么？', false, 1);
INSERT INTO public.exercise_options VALUES ('72e4a971-f8a3-473d-a147-43243b0f75bf', 'cc241837-7a9e-4766-ad53-f9293fa2138a', 'C', 'let result = 0 ? ''yes'' : ''no''; result 的值是？', false, 2);
INSERT INTO public.exercise_options VALUES ('53b5bc27-c774-4c6e-9b4e-9bc66228060d', '44179f63-3600-4603-bb22-ca1bd8152cf1', 'A', '以下哪种循环适合遍历数组的元素值？', false, 0);
INSERT INTO public.exercise_options VALUES ('94d0c945-3588-4eb7-b23f-9031bf87e830', '44179f63-3600-4603-bb22-ca1bd8152cf1', 'B', '以下代码的输出是什么？
for (let i = 0; i < 5; i++) {
  if (i === 2) continue;
  if (i === 4) break;
  console.log(i);
}', true, 1);
INSERT INTO public.exercise_options VALUES ('00d5ac31-216a-4a8e-a6b7-1173a6af6e9d', '44179f63-3600-4603-bb22-ca1bd8152cf1', 'C', 'let arr = [''a'', ''b'']; for (let i in arr) { console.log(i); } 的输出是？', true, 2);
INSERT INTO public.exercise_options VALUES ('208682cc-1b7e-4514-81f3-2790f3ae9974', 'cc64706b-f3c9-4042-82c5-4f4f413852ab', 'A', '以下关于箭头函数的说法，哪个是正确的？', false, 0);
INSERT INTO public.exercise_options VALUES ('8c2ba0b2-c077-4c2c-bc1d-894fc79badb9', 'cc64706b-f3c9-4042-82c5-4f4f413852ab', 'B', 'function greet() {} 和 const greet = function() {} 的主要区别是？', true, 1);
INSERT INTO public.exercise_options VALUES ('0dc04a54-c932-4492-9d2f-b8b0247ef2ad', 'cc64706b-f3c9-4042-82c5-4f4f413852ab', 'C', 'const fn = (a, b = 10) => a + b; fn(5) 的返回值是？', true, 2);
INSERT INTO public.exercise_options VALUES ('751e0207-38ad-4db8-872a-d3f8ad26fd46', 'a2595c3e-aafe-48c1-941b-1a5313bb20fb', 'A', 'arr.map(fn) 和 arr.forEach(fn) 的主要区别是？', false, 0);
INSERT INTO public.exercise_options VALUES ('9fe3a3c2-baf1-4e81-bf58-35c299c3bad4', 'a2595c3e-aafe-48c1-941b-1a5313bb20fb', 'B', 'let arr = [1, 2, 3]; arr.splice(1, 1, ''a'', ''b''); 之后 arr 的值是？', false, 1);
INSERT INTO public.exercise_options VALUES ('09fd5426-4bce-434c-93a9-06158d472b53', 'a2595c3e-aafe-48c1-941b-1a5313bb20fb', 'C', 'let arr = [1, 2, 3]; let copy = arr; copy.push(4); console.log(arr.length); 输出是？', false, 2);
INSERT INTO public.exercise_options VALUES ('ca3142df-2c47-4471-b62f-dcc366041226', 'f749cf5e-1041-4be8-ae2a-c475f6cd49e5', 'A', 'let obj = { a: 1, b: 2 }; let copy = { ...obj }; copy.a = 3; obj.a 的值是？', true, 0);
INSERT INTO public.exercise_options VALUES ('1fd3ab96-cbef-4aee-80cf-ca7dc31ab768', 'f749cf5e-1041-4be8-ae2a-c475f6cd49e5', 'B', 'class Dog extends Animal { ... } 中 super() 的作用是？', false, 1);
INSERT INTO public.exercise_options VALUES ('a373d3cd-69fb-4f91-8fa5-50da8ab7a145', 'c27582c4-53cf-4f28-a8b1-f504a447be4b', 'A', 'document.querySelector(''.item'') 和 document.querySelectorAll(''.item'') 的区别是？', false, 0);
INSERT INTO public.exercise_options VALUES ('23e37555-ffaa-4837-a74d-70600b445352', 'c27582c4-53cf-4f28-a8b1-f504a447be4b', 'B', '以下哪种方式可以安全地修改元素的文本内容，不会解析 HTML 标签？', true, 1);
INSERT INTO public.exercise_options VALUES ('46cc8a5b-44fc-495d-b42c-8f1f614b5365', 'c27582c4-53cf-4f28-a8b1-f504a447be4b', 'C', '事件委托（Event Delegation）的主要优势是什么？', false, 2);


--
-- Data for Name: exercise_test_cases; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.exercise_test_cases VALUES ('cc2041e5-6b43-472f-b15c-cc904c0da4ce', 'b793abc0-2496-4e3a-b444-2f2254c9913b', 'has_doctype', 'text_match', NULL, '{"pattern": "<!DOCTYPE html>", "match_type": "contains"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('5a47d642-ad02-437c-8e3c-e70f924d2287', 'b793abc0-2496-4e3a-b444-2f2254c9913b', 'html_lang_zh', 'dom_snapshot', NULL, '{"equals": "zh-CN", "selector": "html", "attribute": "lang"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('da407f25-2d91-4e51-8ca1-8a5ba8948913', 'b793abc0-2496-4e3a-b444-2f2254c9913b', 'has_charset_meta', 'text_match', NULL, '{"pattern": "charset=\"UTF-8\"", "match_type": "contains"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('c0fcace8-8e8c-4d79-91f6-ba9a9bd68abc', 'b793abc0-2496-4e3a-b444-2f2254c9913b', 'title_correct', 'dom_snapshot', NULL, '{"selector": "title", "textContent": "我的第一个网页"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('6d720407-47fe-4f32-b42f-2636a2fb17e7', 'b793abc0-2496-4e3a-b444-2f2254c9913b', 'h1_content', 'dom_snapshot', NULL, '{"selector": "h1", "textContent": "你好，HTML!"}', 1, false, 4, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('f58c0158-e372-42b8-9dfe-1d33ee2527b5', 'b793abc0-2496-4e3a-b444-2f2254c9913b', 'p_content', 'dom_snapshot', NULL, '{"selector": "p", "textContent": "这是我创建的第一个网页。"}', 1, false, 5, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('333c8a85-f371-4917-9764-14c833fa59c7', 'b6bf5c42-3520-4953-9e33-91339e31e903', 'has_h1_title', 'dom_snapshot', NULL, '{"selector": "h1", "textContent": "HTML 入门指南"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('8750a496-9826-4c9a-8e96-2ae14fe3d404', 'b6bf5c42-3520-4953-9e33-91339e31e903', 'strong_in_intro', 'dom_snapshot', NULL, '{"selector": "strong", "textContent": "重要"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('ad0ed2dd-d9e8-4bca-979a-f424d97d71b5', 'b6bf5c42-3520-4953-9e33-91339e31e903', 'two_h2_sections', 'dom_snapshot', NULL, '{"count": 2, "selector": "h2"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('ff66e3bc-5e54-4511-9541-f6be434eaba7', 'b6bf5c42-3520-4953-9e33-91339e31e903', 'unordered_list_items', 'dom_snapshot', NULL, '{"count": 3, "selector": "ul li"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('328e9df6-bdf9-41e4-9f93-2dd52d4b4bec', 'b6bf5c42-3520-4953-9e33-91339e31e903', 'ordered_list_items', 'dom_snapshot', NULL, '{"count": 2, "selector": "ol li"}', 1, false, 4, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('30bc820a-bfc7-4cad-aefc-cd3198cbeb44', '63b00b44-a4fa-4263-a5f7-996160fccf46', 'has_header_nav', 'dom_snapshot', NULL, '{"exists": true, "selector": "header nav"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('88bef26a-03ec-401d-b440-010e8c0aead1', '63b00b44-a4fa-4263-a5f7-996160fccf46', 'nav_links_count', 'dom_snapshot', NULL, '{"count": 2, "selector": "nav a"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('d0d8efe9-cc66-4be0-8806-e398ecc113b9', '63b00b44-a4fa-4263-a5f7-996160fccf46', 'has_main_article', 'dom_snapshot', NULL, '{"exists": true, "selector": "main article"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('3ad95cde-c868-47fa-8895-aab1154e62e1', '63b00b44-a4fa-4263-a5f7-996160fccf46', 'sections_count', 'dom_snapshot', NULL, '{"count": 2, "selector": "article section"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('a4233f4e-5603-4caf-9a01-3b9f42174d94', '63b00b44-a4fa-4263-a5f7-996160fccf46', 'has_aside', 'dom_snapshot', NULL, '{"exists": true, "selector": "aside"}', 1, false, 4, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('d024a41f-7196-4cde-af23-06daaf3da619', '63b00b44-a4fa-4263-a5f7-996160fccf46', 'has_footer', 'dom_snapshot', NULL, '{"exists": true, "selector": "footer"}', 1, false, 5, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('cb471f87-9e65-4fd5-95f4-107d3209ff25', 'ef7bfc65-ea82-4aea-93b9-75706f232cdc', 'nav_structure', 'dom_snapshot', NULL, '{"count": 4, "selector": "nav ul li a"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('4a526add-997d-4e0f-929a-0ae7086e26d9', 'ef7bfc65-ea82-4aea-93b9-75706f232cdc', 'anchor_link', 'text_match', NULL, '{"pattern": "href=\"#contact\"", "match_type": "contains"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('b071f96f-41eb-4beb-8516-158631673f18', 'ef7bfc65-ea82-4aea-93b9-75706f232cdc', 'images_count', 'dom_snapshot', NULL, '{"count": 2, "selector": "img"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('dbf30502-f756-4e0b-bcc2-a9dffc6a3000', 'ef7bfc65-ea82-4aea-93b9-75706f232cdc', 'alt_text', 'dom_snapshot', NULL, '{"count": 2, "selector": "img[alt]"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('e6e444aa-c941-4764-8fe7-3e00ea54372e', 'ef7bfc65-ea82-4aea-93b9-75706f232cdc', 'mailto_link', 'text_match', NULL, '{"pattern": "mailto:hello@example.com", "match_type": "contains"}', 1, false, 4, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('63117ea1-ba2d-4596-b767-fc056d3f0ec3', '16518b1b-90e6-4ef3-892a-190f0492b5cb', 'has_caption', 'dom_snapshot', NULL, '{"selector": "caption", "textContent": "2025年春季学生成绩表"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('d0784ce0-91d3-4416-9045-2ff09cabec84', '16518b1b-90e6-4ef3-892a-190f0492b5cb', 'thead_structure', 'dom_snapshot', NULL, '{"count": 3, "selector": "thead th"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('50451f41-589e-4019-b2ab-9f4c3144b4bd', '16518b1b-90e6-4ef3-892a-190f0492b5cb', 'tbody_rows', 'dom_snapshot', NULL, '{"count": 2, "selector": "tbody tr"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('fe4b6157-b401-462b-bc02-ec773933a7ae', '16518b1b-90e6-4ef3-892a-190f0492b5cb', 'scope_attrs', 'text_match', NULL, '{"pattern": "scope=\"col\"", "match_type": "contains"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('84e3a13b-5089-4fa9-b75a-e59b6062041e', '6ce8865f-2269-409e-87c2-85619c99871a', 'form_attributes', 'text_match', NULL, '{"pattern": "method=\"POST\"", "match_type": "contains"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('d2cff326-bfae-4c48-a558-9db545c9b5a2', '6ce8865f-2269-409e-87c2-85619c99871a', 'text_input', 'dom_snapshot', NULL, '{"equals": "text", "selector": "input[name=\"username\"]", "attribute": "type"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('e8157673-22ed-452f-894b-d2c02280153a', '6ce8865f-2269-409e-87c2-85619c99871a', 'email_input', 'dom_snapshot', NULL, '{"equals": "email", "selector": "input[name=\"email\"]", "attribute": "type"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('5eb25d82-2279-4f82-b64a-ff9bce8488bc', '6ce8865f-2269-409e-87c2-85619c99871a', 'password_minlength', 'dom_snapshot', NULL, '{"equals": "8", "selector": "input[name=\"password\"]", "attribute": "minlength"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('0b6f8487-df50-412a-8fd0-cfbf9bd47001', '6ce8865f-2269-409e-87c2-85619c99871a', 'radio_buttons', 'dom_snapshot', NULL, '{"count": 2, "selector": "input[type=\"radio\"]"}', 1, false, 4, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('9a86c54e-c646-42ba-8bb2-8d7bee2f995b', '6ce8865f-2269-409e-87c2-85619c99871a', 'checkboxes', 'dom_snapshot', NULL, '{"count": 3, "selector": "input[type=\"checkbox\"]"}', 1, false, 5, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('5d088efe-3890-4b1f-b910-c745e1e185c0', '6ce8865f-2269-409e-87c2-85619c99871a', 'select_options', 'dom_snapshot', NULL, '{"count": 4, "selector": "select option"}', 1, false, 6, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('abcb82e5-b9ef-4691-a5a9-3f994a62c580', '6ce8865f-2269-409e-87c2-85619c99871a', 'submit_button', 'dom_snapshot', NULL, '{"exists": true, "selector": "button[type=\"submit\"]"}', 1, false, 7, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('b7f04134-5dc6-46d6-af0b-d8a5f7139daa', '5e4d6abc-81c7-4207-b2e1-93d5cd53dab8', 'nav_link_color', 'css_assert', NULL, '{"equals": "#333", "property": "color", "selector": "nav a"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('745c4c5e-bedc-48e8-8594-c6a95df8f3d0', '5e4d6abc-81c7-4207-b2e1-93d5cd53dab8', 'nav_hover_color', 'css_assert', NULL, '{"equals": "#007bff", "property": "color", "selector": "nav a:hover"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('08469c0a-e33a-42c2-8ae3-3f8d6a1e3ca0', '5e4d6abc-81c7-4207-b2e1-93d5cd53dab8', 'active_class', 'css_assert', NULL, '{"equals": "bold", "property": "font-weight", "selector": "a.active"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('7f233061-2c3c-421e-9945-96d4892f5882', '5e4d6abc-81c7-4207-b2e1-93d5cd53dab8', 'ul_list_style', 'css_assert', NULL, '{"equals": "none", "property": "list-style", "selector": "nav > ul"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('6bf84faa-d9ec-4818-834b-09f3aeef6f21', '872db405-81f1-45fa-bb23-f7e42a9ae516', 'card_width', 'css_assert', NULL, '{"equals": "300px", "property": "width", "selector": ".card"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('6f1c4fcb-b621-42a0-a232-c137526ed44f', '872db405-81f1-45fa-bb23-f7e42a9ae516', 'card_border_radius', 'css_assert', NULL, '{"equals": "12px", "property": "border-radius", "selector": ".card"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('a144351e-4350-436a-90f6-cee2b8dcf6c0', '872db405-81f1-45fa-bb23-f7e42a9ae516', 'body_padding', 'css_assert', NULL, '{"equals": "16px", "property": "padding", "selector": ".card-body"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('81be3193-78d4-455b-bc5e-777a740f413e', '872db405-81f1-45fa-bb23-f7e42a9ae516', 'title_color', 'css_assert', NULL, '{"equals": "#333", "property": "color", "selector": ".card-title"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('0cd93cb9-d839-450c-9468-2595c0870b20', '872db405-81f1-45fa-bb23-f7e42a9ae516', 'button_bg', 'css_assert', NULL, '{"equals": "#3498db", "property": "background-color", "selector": ".card-button"}', 1, false, 4, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('b5f04074-fc8b-486b-9274-637390987e99', '971655af-6ef3-4ce9-8cc4-e83db1907ee4', 'body_font', 'css_assert', NULL, '{"equals": "16px", "property": "font-size", "selector": "body"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('83d53434-00fc-4c0d-9c9b-816550172a6c', '971655af-6ef3-4ce9-8cc4-e83db1907ee4', 'h1_style', 'css_assert', NULL, '{"equals": "center", "property": "text-align", "selector": "h1"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('e2a90b04-4e14-44d5-9b78-8e4785aa71aa', '971655af-6ef3-4ce9-8cc4-e83db1907ee4', 'intro_border', 'css_assert', NULL, '{"equals": "4px solid #3498db", "property": "border-left", "selector": ".intro"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('d8edc4fd-81c1-42f0-92bf-4f4320e3895e', '971655af-6ef3-4ce9-8cc4-e83db1907ee4', 'highlight_bg', 'css_assert', NULL, '{"equals": "#fff3cd", "property": "background-color", "selector": ".highlight"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('d55a05f6-375d-411e-a0a7-1608f5c5166b', 'c080c963-600b-4f6f-9564-22d80873dd3e', 'btn_gradient', 'text_match', NULL, '{"pattern": "linear-gradient.*667eea.*764ba2", "match_type": "regex_contains"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('bee9cc47-1cf0-470f-b11e-c48279c92ac1', 'c080c963-600b-4f6f-9564-22d80873dd3e', 'btn_border_radius', 'css_assert', NULL, '{"equals": "25px", "property": "border-radius", "selector": ".gradient-btn"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('6fce7b04-2046-4024-8b18-bbd45625aae1', 'c080c963-600b-4f6f-9564-22d80873dd3e', 'card_dimensions', 'css_assert', NULL, '{"equals": "300px", "property": "width", "selector": ".card-gradient"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('2518cf85-1d94-48ef-b1dc-1b6ed898efaf', 'c080c963-600b-4f6f-9564-22d80873dd3e', 'body_flex', 'css_assert', NULL, '{"equals": "flex", "property": "display", "selector": "body"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('bf6f22da-46ad-4989-81d9-7f0eb839e1de', '7a0ff6bb-a2ab-43a3-85ef-6839df8c7a12', 'overlay_position', 'css_assert', NULL, '{"equals": "fixed", "property": "position", "selector": ".overlay"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('f1fabf4d-88af-48b0-b8a8-922167d6cc0f', '7a0ff6bb-a2ab-43a3-85ef-6839df8c7a12', 'modal_center', 'css_assert', NULL, '{"equals": "50%", "property": "top", "selector": ".modal"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('abe24742-27fb-4d25-98bc-33da3417d9ee', '7a0ff6bb-a2ab-43a3-85ef-6839df8c7a12', 'modal_transform', 'css_assert', NULL, '{"equals": "translate(-50%, -50%)", "property": "transform", "selector": ".modal"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('6bf500ce-73d2-4c57-b302-9563a688fdba', '7a0ff6bb-a2ab-43a3-85ef-6839df8c7a12', 'z_index_order', 'css_assert', NULL, '{"equals": "1000", "property": "z-index", "selector": ".modal"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('3290b334-fcf7-4a79-a0a9-896bd458e362', '7a0ff6bb-a2ab-43a3-85ef-6839df8c7a12', 'close_btn_position', 'css_assert', NULL, '{"equals": "absolute", "property": "position", "selector": ".close-btn"}', 1, false, 4, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('015ec5b3-5bf5-45da-91be-5a2442ad34ec', '7bd62366-dc6a-4e42-841a-7bf009f03af0', 'body_flex_center', 'css_assert', NULL, '{"equals": "flex", "property": "display", "selector": "body"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('c31d55fd-4572-4bcd-bb08-1da7c65fe276', '7bd62366-dc6a-4e42-841a-7bf009f03af0', 'justify_center', 'css_assert', NULL, '{"equals": "center", "property": "justify-content", "selector": "body"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('9fbaabb5-08e5-4905-98e7-ab7277ab4322', '7bd62366-dc6a-4e42-841a-7bf009f03af0', 'align_center', 'css_assert', NULL, '{"equals": "center", "property": "align-items", "selector": "body"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('5db3242a-b90c-415d-b32f-786d0d0a9832', '7bd62366-dc6a-4e42-841a-7bf009f03af0', 'card_shadow', 'css_assert', NULL, '{"equals": "12px", "property": "border-radius", "selector": ".login-card"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('bf31afed-4ac2-4fbd-b3a3-6dbf94cd7184', '7bd62366-dc6a-4e42-841a-7bf009f03af0', 'input_flex_col', 'css_assert', NULL, '{"equals": "column", "property": "flex-direction", "selector": ".input-group"}', 1, false, 4, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('12d0eeab-fcb5-421f-ac78-479ecfd35123', '7bd62366-dc6a-4e42-841a-7bf009f03af0', 'submit_btn_width', 'css_assert', NULL, '{"equals": "100%", "property": "width", "selector": "button[type=\"submit\"]"}', 1, false, 5, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('7d7c171a-24d1-490f-ac15-4ee262c1967d', '8f8496d1-22c4-4271-94b7-82dd29208721', 'navbar_flex', 'css_assert', NULL, '{"equals": "flex", "property": "display", "selector": ".navbar"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('522c625c-b471-46dc-81c4-f8b46a2fbbad', '8f8496d1-22c4-4271-94b7-82dd29208721', 'navbar_justify', 'css_assert', NULL, '{"equals": "space-between", "property": "justify-content", "selector": ".navbar"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('ed5c38e1-aefb-4a96-909b-8b4a015ac1ff', '8f8496d1-22c4-4271-94b7-82dd29208721', 'nav_links_flex', 'css_assert', NULL, '{"equals": "flex", "property": "display", "selector": ".nav-links"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('10ad0884-1bee-46f2-920f-0f13a79d206b', '8f8496d1-22c4-4271-94b7-82dd29208721', 'cta_btn_bg', 'css_assert', NULL, '{"equals": "#3498db", "property": "background-color", "selector": ".cta-btn"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('449c4b95-5eef-4dfc-b557-88792f71b258', '8f8496d1-22c4-4271-94b7-82dd29208721', 'navbar_height', 'css_assert', NULL, '{"equals": "64px", "property": "height", "selector": ".navbar"}', 1, false, 4, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('4df6e8c4-e2f6-4d64-bbe5-c469453794c3', 'e224d144-1ab7-4375-bb5d-452c0a6902b0', 'gallery_grid', 'css_assert', NULL, '{"equals": "grid", "property": "display", "selector": ".gallery"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('df293ff4-e37f-4a24-8141-d89b8663a1b2', 'e224d144-1ab7-4375-bb5d-452c0a6902b0', 'auto_fill', 'text_match', NULL, '{"pattern": "auto-fill", "match_type": "contains"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('89b38a9a-b2a8-491e-990b-a52fb3eef849', 'e224d144-1ab7-4375-bb5d-452c0a6902b0', 'minmax_usage', 'text_match', NULL, '{"pattern": "minmax", "match_type": "contains"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('eb1f8976-2710-4797-9bf2-233d810e2258', 'e224d144-1ab7-4375-bb5d-452c0a6902b0', 'featured_span', 'css_assert', NULL, '{"equals": "span 2", "property": "grid-column", "selector": ".featured"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('8c7c580f-e8f7-4044-b47b-21106c57894e', 'e224d144-1ab7-4375-bb5d-452c0a6902b0', 'img_object_fit', 'css_assert', NULL, '{"equals": "cover", "property": "object-fit", "selector": ".gallery-item img"}', 1, false, 4, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('8f57ac61-f144-4eed-8010-2b08bba56b4a', 'f65ab5d7-697b-4c5a-9d94-43e3edf470f2', 'container_grid', 'css_assert', NULL, '{"equals": "grid", "property": "display", "selector": ".container"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('648d079d-5c3b-4ff2-9e02-533ad9474cfb', 'f65ab5d7-697b-4c5a-9d94-43e3edf470f2', 'mobile_col', 'css_assert', NULL, '{"equals": "1fr", "property": "grid-template-columns", "selector": ".container"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('d36cec08-ae68-40c8-be46-1dd363098c84', 'f65ab5d7-697b-4c5a-9d94-43e3edf470f2', 'media_query_600', 'text_match', NULL, '{"pattern": "@media.*min-width.*600", "match_type": "regex_contains"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('97ed24da-9862-4302-b6a6-d51500c4d6cf', 'f65ab5d7-697b-4c5a-9d94-43e3edf470f2', 'media_query_900', 'text_match', NULL, '{"pattern": "@media.*min-width.*900", "match_type": "regex_contains"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('e831af2d-cda4-42d2-9223-24c829b97158', 'f65ab5d7-697b-4c5a-9d94-43e3edf470f2', 'card_shadow', 'css_assert', NULL, '{"equals": "12px", "property": "border-radius", "selector": ".card"}', 1, false, 4, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('6fb92fb4-7740-4d76-923b-8a64f9de8533', '432d7044-d4f6-4f91-a1da-bd3eebe0af22', 'layout_grid', 'css_assert', NULL, '{"equals": "grid", "property": "display", "selector": ".layout"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('db543351-71b7-498d-ae29-98b64f9f34f0', '432d7044-d4f6-4f91-a1da-bd3eebe0af22', 'grid_template_areas', 'text_match', NULL, '{"pattern": "header header header", "match_type": "contains"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('941aa40b-ada4-47a6-b1e3-ca877a9032cc', '432d7044-d4f6-4f91-a1da-bd3eebe0af22', 'header_area', 'css_assert', NULL, '{"equals": "header", "property": "grid-area", "selector": ".header"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('45befb38-bc37-4716-a3f7-7b927935b487', '432d7044-d4f6-4f91-a1da-bd3eebe0af22', 'media_query', 'text_match', NULL, '{"pattern": "@media.*max-width.*768", "match_type": "regex_contains"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('9f2461ab-d964-4ee8-9e2a-3a1b5506bbf6', '432d7044-d4f6-4f91-a1da-bd3eebe0af22', 'footer_align', 'css_assert', NULL, '{"equals": "center", "property": "text-align", "selector": ".footer"}', 1, false, 4, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('c0ab91ec-21af-4253-b958-b7cea67043fb', '37e02f09-9288-4a19-8de0-bec3aa5809dc', 'siteName_const', 'text_match', NULL, '{"pattern": "const siteName", "match_type": "contains"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('dc37495a-0f57-4238-a53f-d95a814143a7', '37e02f09-9288-4a19-8de0-bec3aa5809dc', 'siteName_value', 'text_match', NULL, '{"pattern": "[''\"]CodeQuest[''\"]", "match_type": "regex_contains"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('8fd31b8a-1715-4856-b4ff-e972e330d529', '37e02f09-9288-4a19-8de0-bec3aa5809dc', 'userCount_let', 'text_match', NULL, '{"pattern": "let userCount", "match_type": "contains"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('38d7858e-5fd5-45a7-bddc-ca0475a2c5a9', '37e02f09-9288-4a19-8de0-bec3aa5809dc', 'typeof_output', 'text_match', NULL, '{"pattern": "typeof\\s*\\(?\\s*siteName\\s*\\)?", "match_type": "regex_contains"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('05fbcb2b-caf9-4977-8281-d9af25299379', '04099d40-2444-4011-89dd-a7c4dfe59740', 'celsius_const', 'text_match', NULL, '{"pattern": "const celsius", "match_type": "contains"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('2224fa52-da13-40df-b82a-f81b9d5f87c7', '04099d40-2444-4011-89dd-a7c4dfe59740', 'formula_correct', 'text_match', NULL, '{"pattern": "celsius\\s*\\*\\s*9\\s*/\\s*5\\s*\\+\\s*32", "match_type": "regex_contains"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('4a1720dc-60c5-44a9-86da-1b0438b2969b', '04099d40-2444-4011-89dd-a7c4dfe59740', 'template_string', 'text_match', NULL, '{"pattern": "`.*\\$\\{.*\\}.*`", "match_type": "regex_contains"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('f99ea865-163b-47f9-8ab5-1301f813810b', '04099d40-2444-4011-89dd-a7c4dfe59740', 'strict_equality', 'text_match', NULL, '{"pattern": "===", "match_type": "contains"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('dea37649-55c5-4c49-af7f-b6f6b5dd79da', 'b0fc3659-0bce-4668-a997-3dae2866456f', 'score_const', 'text_match', NULL, '{"pattern": "const score", "match_type": "contains"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('29660eb2-4141-43b1-99a0-24483fcb0872', 'b0fc3659-0bce-4668-a997-3dae2866456f', 'if_structure', 'text_match', NULL, '{"pattern": "if.*score\\s*>=\\s*90", "match_type": "regex_contains"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('ac091c7f-7b09-4c43-a22f-d729cc9c1693', 'b0fc3659-0bce-4668-a997-3dae2866456f', 'else_if_80', 'text_match', NULL, '{"pattern": "else if.*score\\s*>=\\s*80", "match_type": "regex_contains"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('5397ec20-9715-4811-ae01-ef02f8993108', 'b0fc3659-0bce-4668-a997-3dae2866456f', 'template_output', 'text_match', NULL, '{"pattern": "`.*等级.*\\$\\{grade\\}.*`", "match_type": "regex_contains"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('ec302336-ce9d-4111-b3b9-abd459a25852', '71f1d9b3-b5e5-4b97-81f7-4d83e2f83dd2', 'sum_initialized', 'text_match', NULL, '{"pattern": "let sum\\s*=\\s*0", "match_type": "regex_contains"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('2c0ddcfa-b417-44a9-a884-39e043f4b459', '71f1d9b3-b5e5-4b97-81f7-4d83e2f83dd2', 'for_loop_1_to_20', 'text_match', NULL, '{"pattern": "for.*let.*i.*=.*1.*i\\s*<=\\s*20.*i\\+\\+", "match_type": "regex_contains"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('4d0afd0b-d7a4-433f-af07-b2a96b65d9c1', '71f1d9b3-b5e5-4b97-81f7-4d83e2f83dd2', 'even_check', 'text_match', NULL, '{"pattern": "i\\s*%\\s*2\\s*===?\\s*0", "match_type": "regex_contains"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('0c9a04b6-1284-4bb3-9788-576a11c704f0', '71f1d9b3-b5e5-4b97-81f7-4d83e2f83dd2', 'add_to_sum', 'text_match', NULL, '{"pattern": "sum\\s*\\+?=\\s*i", "match_type": "regex_contains"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('3f05e174-acf7-4a3f-a3db-23a78cde61fc', '4d8fdc42-cfd9-4f73-8e84-86e61f065775', 'add_arrow', 'text_match', NULL, '{"pattern": "const add\\s*=\\s*\\(.*a,.*b.*\\)\\s*=>", "match_type": "regex_contains"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('22d5e36f-0b28-450e-bbbf-de406c817bec', '4d8fdc42-cfd9-4f73-8e84-86e61f065775', 'add_return', 'text_match', NULL, '{"pattern": "return a \\+ b", "match_type": "contains"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('03477951-cfd3-468d-9992-b7b6783e6f48', '4d8fdc42-cfd9-4f73-8e84-86e61f065775', 'divide_check', 'text_match', NULL, '{"pattern": "if.*b\\s*===?\\s*0", "match_type": "regex_contains"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('1888468b-b76c-4fd3-bfea-62b8ed33a61b', '4d8fdc42-cfd9-4f73-8e84-86e61f065775', 'console_outputs', 'text_match', NULL, '{"pattern": "console\\.log.*add\\(10,\\s*5\\)", "match_type": "regex_contains"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('978eaba3-201f-4102-89ad-b7648d7f2ebd', 'cd6d2038-ab8d-4cec-90e2-a38b04a7b403', 'scores_array', 'text_match', NULL, '{"pattern": "\\[78,\\s*92,\\s*85,\\s*64,\\s*88,\\s*91\\]", "match_type": "regex_contains"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('b6e0436c-83ac-4450-b932-be11233184ed', 'cd6d2038-ab8d-4cec-90e2-a38b04a7b403', 'filter_usage', 'text_match', NULL, '{"pattern": "scores\\.filter", "match_type": "contains"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('ef881412-70e1-4a4d-a0c2-fb856b50521d', 'cd6d2038-ab8d-4cec-90e2-a38b04a7b403', 'map_usage', 'text_match', NULL, '{"pattern": "passed\\.map", "match_type": "contains"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('7b537bea-0872-4651-ba63-859c2c7fe3c8', 'cd6d2038-ab8d-4cec-90e2-a38b04a7b403', 'reduce_usage', 'text_match', NULL, '{"pattern": "bonus\\.reduce", "match_type": "contains"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('4fb3aa05-2a48-43ad-85d0-f11d42f14862', '428ec03b-67fa-41a0-b2c4-db9759f2b0d6', 'class_book', 'text_match', NULL, '{"pattern": "class Book", "match_type": "contains"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('339760b5-27d6-4595-a849-ab523866e6b4', '428ec03b-67fa-41a0-b2c4-db9759f2b0d6', 'constructor_params', 'text_match', NULL, '{"pattern": "constructor\\(title,\\s*author\\)", "match_type": "regex_contains"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('1ed8efdc-1ac3-4d83-83f9-085c5c439450', '428ec03b-67fa-41a0-b2c4-db9759f2b0d6', 'this_assignment', 'text_match', NULL, '{"pattern": "this\\.title\\s*=\\s*title", "match_type": "regex_contains"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('18e1ae12-07c8-4bf5-92d3-22f239bf81e4', '428ec03b-67fa-41a0-b2c4-db9759f2b0d6', 'getInfo_method', 'text_match', NULL, '{"pattern": "getInfo\\(\\)", "match_type": "regex_contains"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('5e2fa606-7011-4979-99dc-3385784bcf1b', '4c09ab2c-6436-48dd-adf8-499c5bee4f7c', 'query_addBtn', 'text_match', NULL, '{"pattern": "querySelector\\([''\"]#addBtn[''\"]\\)", "match_type": "regex_contains"}', 1, false, 0, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('4045d57d-2696-44c3-bfe6-a61f4ae637b4', '4c09ab2c-6436-48dd-adf8-499c5bee4f7c', 'addEventListener_click', 'text_match', NULL, '{"pattern": "addEventListener\\([''\"]click[''\"]", "match_type": "regex_contains"}', 1, false, 1, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('8aaf0773-2e0a-432f-9d25-0f56e9cc1704', '4c09ab2c-6436-48dd-adf8-499c5bee4f7c', 'createElement_li', 'text_match', NULL, '{"pattern": "createElement\\([''\"]li[''\"]\\)", "match_type": "regex_contains"}', 1, false, 2, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('bee2e807-3bc5-43ba-9bac-923f2a845003', '4c09ab2c-6436-48dd-adf8-499c5bee4f7c', 'appendChild', 'text_match', NULL, '{"pattern": "appendChild\\(li\\)", "match_type": "regex_contains"}', 1, false, 3, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('f0cac025-7133-4fb3-8bca-755652012c45', '4c09ab2c-6436-48dd-adf8-499c5bee4f7c', 'clear_input', 'text_match', NULL, '{"pattern": "input\\.value\\s*=\\s*[''\"][''\"]", "match_type": "regex_contains"}', 1, false, 4, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');
INSERT INTO public.exercise_test_cases VALUES ('899b1874-80b9-4d4a-a3be-726b005c2222', '4c09ab2c-6436-48dd-adf8-499c5bee4f7c', 'enter_key', 'text_match', NULL, '{"pattern": "[''\"]Enter[''\"]", "match_type": "contains"}', 1, false, 5, 1, '2026-05-10 23:31:11.516759+08', '2026-05-10 23:31:11.516759+08');


--
-- Data for Name: feedback_tickets; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: friend_relations; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: leaderboard_snapshots; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: learner_badges; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: learner_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.learner_profiles VALUES ('e3e99fda-c2ea-4170-a5a7-d30c1a95531d', '前端小白', NULL, NULL, 'system', 30, 7, 1500, 5, 0, 50, NULL, '2026-05-10 23:31:11.484837+08', '2026-05-10 23:31:11.484837+08');
INSERT INTO public.learner_profiles VALUES ('48eb082f-53d8-4929-b107-10b3b296fa6d', '代码猎人', NULL, NULL, 'system', 30, 14, 3200, 12, 0, 50, NULL, '2026-05-10 23:31:11.484837+08', '2026-05-10 23:31:11.484837+08');
INSERT INTO public.learner_profiles VALUES ('22a2c7da-e77f-4a25-b79e-b3deed9ad839', 'CSS魔法师', NULL, NULL, 'system', 30, 2, 800, 3, 0, 50, NULL, '2026-05-10 23:31:11.484837+08', '2026-05-10 23:31:11.484837+08');
INSERT INTO public.learner_profiles VALUES ('5d036eff-e26b-4782-a8f0-eefa53038c58', '测试用户', NULL, NULL, 'system', 30, 0, 0, 1, 0, 50, NULL, '2026-05-11 02:53:57.325266+08', '2026-05-11 02:53:57.325266+08');
INSERT INTO public.learner_profiles VALUES ('f2cedc3c-6bb6-460e-9a07-1467d8530399', '管理员2', NULL, NULL, 'system', 30, 0, 0, 1, 0, 50, NULL, '2026-05-11 02:54:45.743294+08', '2026-05-11 02:54:45.743294+08');
INSERT INTO public.learner_profiles VALUES ('6392737f-e239-45ac-b472-b74f35f25a12', 'TestUser', NULL, NULL, 'system', 30, 0, 0, 1, 0, 50, NULL, '2026-05-11 03:51:21.879908+08', '2026-05-11 03:51:21.879908+08');
INSERT INTO public.learner_profiles VALUES ('ae44b7e0-600f-4743-9ad4-7a1e59734e3c', 'Learner2', NULL, NULL, 'system', 30, 0, 0, 1, 0, 50, NULL, '2026-05-11 04:24:44.691684+08', '2026-05-11 04:24:44.691684+08');


--
-- Data for Name: moderation_cases; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sessions VALUES ('902cff0c-7466-4b20-b09a-94f8edb0f69f', '5d036eff-e26b-4782-a8f0-eefa53038c58', 'learner', 'test-device', NULL, 'web', NULL, NULL, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI1ZDAzNmVmZi1lMjZiLTQ3ODItYThmMC1lZWZhNTMwMzhjNTgiLCJhY2NvdW50X2lkIjoiNWQwMzZlZmYtZTI2Yi00NzgyLWE4ZjAtZWVmYTUzMDM4YzU4Iiwicm9sZSI6ImxlYXJuZXIiLCJleHAiOjE3NzkwNDQwMzcsImlhdCI6MTc3ODQzOTIzN30.K9XgoZLWtju8iACkoemzHwPcsomm9M39Ocpq0szWjXA', '2026-05-18 02:53:57.34504+08', NULL, '2026-05-11 02:53:57.362294+08', '2026-05-11 02:53:57.362294+08');
INSERT INTO public.sessions VALUES ('cba1fa6b-3f26-4297-ac92-8be20b7a202a', 'f2cedc3c-6bb6-460e-9a07-1467d8530399', 'learner', 'admin-web', NULL, 'web', NULL, NULL, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJmMmNlZGMzYy02YmI2LTQ2MGUtOWEwNy0xNDY3ZDg1MzAzOTkiLCJhY2NvdW50X2lkIjoiZjJjZWRjM2MtNmJiNi00NjBlLTlhMDctMTQ2N2Q4NTMwMzk5Iiwicm9sZSI6ImxlYXJuZXIiLCJleHAiOjE3NzkwNDQwODUsImlhdCI6MTc3ODQzOTI4NX0.tap0R3wwCx1qYSpxcjm6pAojBeoJiRslnjnZVTGNZbs', '2026-05-18 02:54:45.766718+08', NULL, '2026-05-11 02:54:45.778595+08', '2026-05-11 02:54:45.778595+08');
INSERT INTO public.sessions VALUES ('ece9910a-9460-43bc-8985-ae313d4a0c93', '6392737f-e239-45ac-b472-b74f35f25a12', 'learner', 'test-device-123', NULL, 'web', NULL, NULL, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI2MzkyNzM3Zi1lMjM5LTQ1YWMtYjQ3Mi1iNzRmMzVmMjVhMTIiLCJhY2NvdW50X2lkIjoiNjM5MjczN2YtZTIzOS00NWFjLWI0NzItYjc0ZjM1ZjI1YTEyIiwicm9sZSI6ImxlYXJuZXIiLCJleHAiOjE3NzkwNDc0ODEsImlhdCI6MTc3ODQ0MjY4MX0.aFZkuVZ1q4Bbd0vz-OyMp-cKT1pYC9ahtw5Gtejgz_o', '2026-05-18 03:51:21.902538+08', NULL, '2026-05-11 03:51:21.909874+08', '2026-05-11 03:51:21.909874+08');
INSERT INTO public.sessions VALUES ('9896ad50-22f5-4d93-9d4e-cde35875a122', '6392737f-e239-45ac-b472-b74f35f25a12', 'learner', 'learner-mobile-device', NULL, 'ios', NULL, NULL, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI2MzkyNzM3Zi1lMjM5LTQ1YWMtYjQ3Mi1iNzRmMzVmMjVhMTIiLCJhY2NvdW50X2lkIjoiNjM5MjczN2YtZTIzOS00NWFjLWI0NzItYjc0ZjM1ZjI1YTEyIiwicm9sZSI6ImxlYXJuZXIiLCJleHAiOjE3NzkwNDc1MTIsImlhdCI6MTc3ODQ0MjcxMn0.J-Bwwx_Z8rZig2u1qTCQ692-BCjJ9uUYaoO3lnulxPQ', '2026-05-18 03:51:52.408649+08', NULL, '2026-05-11 03:51:52.420719+08', '2026-05-11 03:51:52.420719+08');
INSERT INTO public.sessions VALUES ('77bfef6d-70d4-4c3e-8a20-11faa81bf266', '6392737f-e239-45ac-b472-b74f35f25a12', 'learner', 'learner-mobile-device', NULL, 'ios', NULL, NULL, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI2MzkyNzM3Zi1lMjM5LTQ1YWMtYjQ3Mi1iNzRmMzVmMjVhMTIiLCJhY2NvdW50X2lkIjoiNjM5MjczN2YtZTIzOS00NWFjLWI0NzItYjc0ZjM1ZjI1YTEyIiwicm9sZSI6ImxlYXJuZXIiLCJleHAiOjE3NzkwNDc2NjAsImlhdCI6MTc3ODQ0Mjg2MH0.3IzBsf3-SnuSyGwGKAxyej_M26lYIDsimiSozOugsZI', '2026-05-18 03:54:20.407302+08', NULL, '2026-05-11 03:54:20.421735+08', '2026-05-11 03:54:20.421735+08');
INSERT INTO public.sessions VALUES ('2a445c07-601b-4c6a-a9bc-e98adf7519b6', '6392737f-e239-45ac-b472-b74f35f25a12', 'learner', 'learner-mobile-device', NULL, 'ios', NULL, NULL, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI2MzkyNzM3Zi1lMjM5LTQ1YWMtYjQ3Mi1iNzRmMzVmMjVhMTIiLCJhY2NvdW50X2lkIjoiNjM5MjczN2YtZTIzOS00NWFjLWI0NzItYjc0ZjM1ZjI1YTEyIiwicm9sZSI6ImxlYXJuZXIiLCJleHAiOjE3NzkwNDkzMDUsImlhdCI6MTc3ODQ0NDUwNX0.34Qwq9pV7fsujwIk4OyD4wz7cwzcs2MRq8RvVePwER0', '2026-05-18 04:21:45.864188+08', NULL, '2026-05-11 04:21:45.878029+08', '2026-05-11 04:21:45.878029+08');
INSERT INTO public.sessions VALUES ('0d93ff3e-0b8f-417c-b7f0-718717aad42f', '6392737f-e239-45ac-b472-b74f35f25a12', 'learner', 'learner-mobile-device', NULL, 'ios', NULL, NULL, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI2MzkyNzM3Zi1lMjM5LTQ1YWMtYjQ3Mi1iNzRmMzVmMjVhMTIiLCJhY2NvdW50X2lkIjoiNjM5MjczN2YtZTIzOS00NWFjLWI0NzItYjc0ZjM1ZjI1YTEyIiwicm9sZSI6ImxlYXJuZXIiLCJleHAiOjE3NzkwNDkzMzcsImlhdCI6MTc3ODQ0NDUzN30.m2X6tetih6QJvkqJMcOpqCKHuaxL60XQcEjaFV2wuvY', '2026-05-18 04:22:17.124086+08', NULL, '2026-05-11 04:22:17.156636+08', '2026-05-11 04:22:17.156636+08');
INSERT INTO public.sessions VALUES ('fa2e0d95-83b7-42cc-a037-1ebeae8d4da5', '6392737f-e239-45ac-b472-b74f35f25a12', 'learner', 'learner-mobile-device', NULL, 'ios', NULL, NULL, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI2MzkyNzM3Zi1lMjM5LTQ1YWMtYjQ3Mi1iNzRmMzVmMjVhMTIiLCJhY2NvdW50X2lkIjoiNjM5MjczN2YtZTIzOS00NWFjLWI0NzItYjc0ZjM1ZjI1YTEyIiwicm9sZSI6ImxlYXJuZXIiLCJleHAiOjE3NzkwNDkzNjcsImlhdCI6MTc3ODQ0NDU2N30.w-1aVdbCMmuVOguXMZe-StIjD8XAYxjU9MrETWT_AS0', '2026-05-18 04:22:47.441025+08', NULL, '2026-05-11 04:22:47.464585+08', '2026-05-11 04:22:47.464585+08');
INSERT INTO public.sessions VALUES ('b433015c-f503-4613-a59a-e4e15a8724a6', '6392737f-e239-45ac-b472-b74f35f25a12', 'learner', 'learner-mobile-device', NULL, 'ios', NULL, NULL, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI2MzkyNzM3Zi1lMjM5LTQ1YWMtYjQ3Mi1iNzRmMzVmMjVhMTIiLCJhY2NvdW50X2lkIjoiNjM5MjczN2YtZTIzOS00NWFjLWI0NzItYjc0ZjM1ZjI1YTEyIiwicm9sZSI6ImxlYXJuZXIiLCJleHAiOjE3NzkwNDk0MzYsImlhdCI6MTc3ODQ0NDYzNn0.mi2Uf855jtSoCxFWhewmS3-vsXAz1UVU-arqzUSmprg', '2026-05-18 04:23:56.998457+08', NULL, '2026-05-11 04:23:56.999434+08', '2026-05-11 04:23:56.999434+08');
INSERT INTO public.sessions VALUES ('fb5e823e-bb9c-4f06-97ae-62c20071f3c4', '94fdf828-ccfb-436d-9683-8dbbd5000da5', 'admin', 'admin-web-device', NULL, 'web', NULL, NULL, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI5NGZkZjgyOC1jY2ZiLTQzNmQtOTY4My04ZGJiZDUwMDBkYTUiLCJhY2NvdW50X2lkIjoiOTRmZGY4MjgtY2NmYi00MzZkLTk2ODMtOGRiYmQ1MDAwZGE1Iiwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzc5MDQ5NDczLCJpYXQiOjE3Nzg0NDQ2NzN9.6kYK5WP7K1s2pK5-ILBKl24fphimQyXGidNhVQ11Kp4', '2026-05-18 04:24:33.294052+08', NULL, '2026-05-11 04:24:33.303266+08', '2026-05-11 04:24:33.303266+08');
INSERT INTO public.sessions VALUES ('b9767702-9ee8-4bb7-9f36-a8f434a1cad0', 'ae44b7e0-600f-4743-9ad4-7a1e59734e3c', 'learner', 'test', NULL, 'web', NULL, NULL, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZTQ0YjdlMC02MDBmLTQ3NDMtOWFkNC03YTFlNTk3MzRlM2MiLCJhY2NvdW50X2lkIjoiYWU0NGI3ZTAtNjAwZi00NzQzLTlhZDQtN2ExZTU5NzM0ZTNjIiwicm9sZSI6ImxlYXJuZXIiLCJleHAiOjE3NzkwNDk0ODQsImlhdCI6MTc3ODQ0NDY4NH0.l0IQ_EVQk0QY8dFrmAeIUakVVf72OTWcH94zZPpsT-8', '2026-05-18 04:24:44.715813+08', NULL, '2026-05-11 04:24:44.717142+08', '2026-05-11 04:24:44.717142+08');
INSERT INTO public.sessions VALUES ('19b5553f-d4d2-4b3b-b6a3-e1bc35f06330', '6392737f-e239-45ac-b472-b74f35f25a12', 'learner', 'learner-mobile-device', NULL, 'ios', NULL, NULL, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI2MzkyNzM3Zi1lMjM5LTQ1YWMtYjQ3Mi1iNzRmMzVmMjVhMTIiLCJhY2NvdW50X2lkIjoiNjM5MjczN2YtZTIzOS00NWFjLWI0NzItYjc0ZjM1ZjI1YTEyIiwicm9sZSI6ImxlYXJuZXIiLCJleHAiOjE3NzkwNDk2MjcsImlhdCI6MTc3ODQ0NDgyN30.zb_wS-XmKsjpryiFzdvziqiMyzmuhjqj2WnFlNEFsBM', '2026-05-18 04:27:07.392692+08', NULL, '2026-05-11 04:27:07.397209+08', '2026-05-11 04:27:07.397209+08');
INSERT INTO public.sessions VALUES ('d3ff36ae-bdb4-487d-8f63-c6344e8ff170', 'e3e99fda-c2ea-4170-a5a7-d30c1a95531d', 'learner', 'learner-mobile-device', NULL, 'ios', NULL, NULL, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJlM2U5OWZkYS1jMmVhLTQxNzAtYTVhNy1kMzBjMWE5NTUzMWQiLCJhY2NvdW50X2lkIjoiZTNlOTlmZGEtYzJlYS00MTcwLWE1YTctZDMwYzFhOTU1MzFkIiwicm9sZSI6ImxlYXJuZXIiLCJleHAiOjE3NzkwNDk2NTcsImlhdCI6MTc3ODQ0NDg1N30.IIY870AaaVWFj-_-Xse78JoLeGjYZ5lScvhZOpQGBcs', '2026-05-18 04:27:37.168608+08', NULL, '2026-05-11 04:27:37.169612+08', '2026-05-11 04:27:37.169612+08');
INSERT INTO public.sessions VALUES ('27e2f1d3-5ed0-4768-a62c-64f2daf6e8fd', '94fdf828-ccfb-436d-9683-8dbbd5000da5', 'admin', 'admin-web-device', NULL, 'web', NULL, NULL, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI5NGZkZjgyOC1jY2ZiLTQzNmQtOTY4My04ZGJiZDUwMDBkYTUiLCJhY2NvdW50X2lkIjoiOTRmZGY4MjgtY2NmYi00MzZkLTk2ODMtOGRiYmQ1MDAwZGE1Iiwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzc5MDQ5Njg1LCJpYXQiOjE3Nzg0NDQ4ODV9.u5y0N_REtRCQ2iaUZCd__EYQJORVp91qloD9lCOROZw', '2026-05-18 04:28:05.363235+08', NULL, '2026-05-11 04:28:05.364856+08', '2026-05-11 04:28:05.364856+08');
INSERT INTO public.sessions VALUES ('74dd7e9f-da43-4daf-a41b-7891b3518ae4', 'e3e99fda-c2ea-4170-a5a7-d30c1a95531d', 'learner', 'learner-mobile-device', NULL, 'ios', NULL, NULL, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJlM2U5OWZkYS1jMmVhLTQxNzAtYTVhNy1kMzBjMWE5NTUzMWQiLCJhY2NvdW50X2lkIjoiZTNlOTlmZGEtYzJlYS00MTcwLWE1YTctZDMwYzFhOTU1MzFkIiwicm9sZSI6ImxlYXJuZXIiLCJleHAiOjE3NzkwNDk2ODgsImlhdCI6MTc3ODQ0NDg4OH0.WrUCwuUq8H905IJluva85iLZxiylKgtxz38eA8Yw70I', '2026-05-18 04:28:08.590665+08', NULL, '2026-05-11 04:28:08.592796+08', '2026-05-11 04:28:08.592796+08');
INSERT INTO public.sessions VALUES ('ca88311b-d220-4a5b-9494-17db3f02941f', '48eb082f-53d8-4929-b107-10b3b296fa6d', 'learner', 'learner-mobile-device', NULL, 'ios', NULL, NULL, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI0OGViMDgyZi01M2Q4LTQ5MjktYjEwNy0xMGIzYjI5NmZhNmQiLCJhY2NvdW50X2lkIjoiNDhlYjA4MmYtNTNkOC00OTI5LWIxMDctMTBiM2IyOTZmYTZkIiwicm9sZSI6ImxlYXJuZXIiLCJleHAiOjE3NzkwNDk3MjEsImlhdCI6MTc3ODQ0NDkyMX0.Ys-kTk4EAVdQ_oPSCGIyPv4z6c3v5rkplWqZcF_dz9g', '2026-05-18 04:28:41.707014+08', NULL, '2026-05-11 04:28:41.710526+08', '2026-05-11 04:28:41.710526+08');
INSERT INTO public.sessions VALUES ('0a29884a-dc8a-4a63-ada4-6c45b48484ba', '22a2c7da-e77f-4a25-b79e-b3deed9ad839', 'learner', 'learner-mobile-device', NULL, 'ios', NULL, NULL, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyMmEyYzdkYS1lNzdmLTRhMjUtYjc5ZS1iM2RlZWQ5YWQ4MzkiLCJhY2NvdW50X2lkIjoiMjJhMmM3ZGEtZTc3Zi00YTI1LWI3OWUtYjNkZWVkOWFkODM5Iiwicm9sZSI6ImxlYXJuZXIiLCJleHAiOjE3NzkwNDk3MjUsImlhdCI6MTc3ODQ0NDkyNX0.EnBcmfSen8M0xZ0VKs8WmtdWmqE4Ny7pgYrxNn0UeyU', '2026-05-18 04:28:45.078521+08', NULL, '2026-05-11 04:28:45.080395+08', '2026-05-11 04:28:45.080395+08');
INSERT INTO public.sessions VALUES ('0932a2e7-4fe0-4ff7-a88e-1d1d3f9cc724', 'e3e99fda-c2ea-4170-a5a7-d30c1a95531d', 'learner', 'learner-mobile-device', NULL, 'ios', NULL, NULL, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJlM2U5OWZkYS1jMmVhLTQxNzAtYTVhNy1kMzBjMWE5NTUzMWQiLCJhY2NvdW50X2lkIjoiZTNlOTlmZGEtYzJlYS00MTcwLWE1YTctZDMwYzFhOTU1MzFkIiwicm9sZSI6ImxlYXJuZXIiLCJleHAiOjE3NzkwNDk3NDQsImlhdCI6MTc3ODQ0NDk0NH0.oBTqArgiuWKLZjZD0_4Nd06w_iWJurU4Jgxe2rXIloo', '2026-05-18 04:29:04.809107+08', NULL, '2026-05-11 04:29:04.811635+08', '2026-05-11 04:29:04.811635+08');


--
-- Data for Name: social_activities; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: system_configs; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: xp_ledger; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- PostgreSQL database dump complete
--

\unrestrict YT4Cikz5xV2xOww5TPbgiQdY3MAgkdslfbCRaLq8EYb3mL0K0oU12g2mqh8vEwq

