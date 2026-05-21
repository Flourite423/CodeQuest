# 任务 A5 + A6: Mobile 语法高亮增强 + WebView 预览增强

## 背景
- `mobile/lib/widgets/syntax_highlighter.dart` 已有基础 HTML 标签高亮，但缺少 CSS 属性高亮、行号、注释高亮
- `mobile/lib/widgets/code_preview_webview.dart` 已有基础 WebView，但只支持纯 HTML，缺少 CSS 注入和错误处理

## 目标
1. 增强语法高亮组件（A5）
2. 增强 WebView 预览组件（A6）

## 修改文件

### A5: 修改 `mobile/lib/widgets/syntax_highlighter.dart`

当前实现只处理了 HTML 标签和字符串。需要添加：

#### a) CSS 属性高亮（绿色）
在 `_highlightLine` 中添加 CSS 属性检测逻辑。当不在 HTML 标签内时，检测是否匹配 CSS 属性名正则（如 `color`, `margin`, `padding` 等），匹配时染绿色。

简化方案：在 `// 不在标签内时` 的默认分支中，添加对 `:` 前面单词的检测：
```dart
// 检测 CSS 属性: property: value;
final cssPropRegExp = RegExp(r'([a-z-]+)\s*:\s*([^;]*);?');
if (cssPropRegExp.hasMatch(remaining)) {
  // 将属性名染绿色，值染橙色
}
```

#### b) 行号显示
在 `_buildLine` 中，当前行号位置是空的 `SizedBox(width: 40.w, child: Text(''))`。改为显示真实行号：
```dart
SizedBox(
  width: 40.w,
  child: Text(
    '${lineIndex + 1}',
    style: theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontFamily: 'monospace',
    ),
    textAlign: TextAlign.right,
  ),
),
```

需要将 `_buildHighlightedCode` 改为带索引的 map：
```dart
Widget _buildHighlightedCode(ThemeData theme) {
  final lines = code.split('\n');
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: lines.asMap().entries.map((entry) {
      return _buildLine(entry.key, entry.value, theme);
    }).toList(),
  );
}
```

#### c) 注释高亮（灰色）
添加对 `<!-- -->`（HTML 注释）和 `/* */` / `//`（CSS/JS 注释）的支持。最简单的方法是在 `_highlightLine` 开头检测整行是否为注释：
```dart
TextSpan _highlightLine(String line, ThemeData theme) {
  final trimmed = line.trim();
  if (trimmed.startsWith('<!--') || trimmed.startsWith('/*') || 
      trimmed.startsWith('//') || trimmed.startsWith('*')) {
    return TextSpan(
      text: line,
      style: TextStyle(
        color: Colors.grey,
        fontFamily: 'monospace',
        fontSize: 14.sp,
        fontStyle: FontStyle.italic,
      ),
    );
  }
  // ... 原有逻辑
}
```

#### d) 改进整体展示
- 添加水平滚动条支持（`SingleChildScrollView` 已存在）
- 字体使用等宽字体（`fontFamily: 'monospace'` 已有）

### A6: 修改 `mobile/lib/widgets/code_preview_webview.dart`

当前只接受 `htmlCode` 一个参数，直接注入到 `<body>` 中。需要改进：

#### a) 支持同时传入 HTML 和 CSS
```dart
class CodePreviewWebView extends StatefulWidget {
  const CodePreviewWebView({
    super.key,
    this.htmlCode = '',
    this.cssCode = '',
  });

  final String htmlCode;
  final String cssCode;
  // ...
}
```

修改 `_loadHtmlContent`：
```dart
void _loadHtmlContent() {
  final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'none'; object-src 'none';">
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      margin: 0;
      padding: 16px;
      background-color: #ffffff;
      color: #333333;
    }
    ${widget.cssCode}
  </style>
</head>
<body>
  ${widget.htmlCode}
</body>
</html>
''';
  _controller.loadHtmlString(htmlContent);
}
```

#### b) 添加错误处理
在 `NavigationDelegate` 中添加 `onWebResourceError`：
```dart
NavigationDelegate(
  onPageStarted: (String url) => setState(() => _isLoading = true),
  onPageFinished: (String url) => setState(() => _isLoading = false),
  onWebResourceError: (WebResourceError error) {
    setState(() => _isLoading = false);
    // 可以在这里记录错误
  },
)
```

#### c) 与练习页面集成
修改 `mobile/lib/views/exercise/exercise_view.dart`，在代码编辑区域旁边或下方添加预览标签页。

如果练习页面已有 Tab 切换，添加一个"预览"Tab：
```dart
// 在 exercise_view.dart 中
TabBar(
  tabs: [
    Tab(text: '代码'),
    Tab(text: '预览'),
  ],
)
TabBarView(
  children: [
    // 代码编辑区
    _buildCodeEditor(),
    // 预览区
    CodePreviewWebView(
      htmlCode: _htmlController.text,
      cssCode: _cssController.text,
    ),
  ],
)
```

如果练习页面结构复杂，至少确保 `CodePreviewWebView` 组件可以被正确导入和使用。

### 可能需要修改 `mobile/pubspec.yaml`

确保 `webview_flutter` 已声明（已有）。

如果考虑使用更强大的语法高亮库，可以添加 `flutter_highlight` 依赖，但当前任务是在现有基础上增强，不建议引入新依赖。

## 测试验证
- [ ] 语法高亮组件显示行号
- [ ] HTML 标签显示蓝色、字符串显示绿色、CSS 属性显示绿色、注释显示灰色
- [ ] WebView 预览能正确渲染 HTML + CSS
- [ ] 代码修改后预览实时更新（通过 didUpdateWidget 触发）
- [ ] 练习页面可以正常切换"代码"和"预览"Tab

## 注意
- 保持与现有 Material 3 主题一致
- 不要破坏现有符号快捷输入面板功能
- 如果练习页面已有复杂结构，以最小改动集成预览
