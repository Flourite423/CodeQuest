# 任务 B1: Mobile AI 帮助兜底逻辑

## 背景
当前 `mobile/lib/views/exercise/widgets/ai_help_sheet.dart` 中，AI 帮助完全依赖后端返回。当后端 AI 服务不可用（5xx 错误、超时、无 API Key）时，用户体验中断。

论文要求有客户端兜底逻辑：当 AI 服务不可用时，根据测试用例结果生成本地安全提示。

## 前提条件
- Wave 1 的 A1 已完成（Backend AI Help 返回稳定 JSON 结构）
- 确认后端 AI 接口返回的 JSON 结构包含 `hint_level`、`summary` 等字段

## 目标
在 AI Help Bottom Sheet 中添加客户端降级逻辑。

## 修改文件

### `mobile/lib/views/exercise/widgets/ai_help_sheet.dart`

当前逻辑大概是：
```dart
// 调用后端 AI Help API
final response = await apiService.requestAiHelp(...);
// 直接展示 response
```

需要改为：
```dart
Future<void> _requestAiHelp() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final response = await apiService.requestAiHelp(
      exerciseId: widget.exerciseId,
      submissionId: widget.submissionId,
      requestType: _currentHintLevel, // error_location / correction_hint / operation_suggestion
      sourceCode: widget.sourceCode,
    ).timeout(const Duration(seconds: 10));

    setState(() {
      _aiResponse = response;
      _isLoading = false;
    });
  } on TimeoutException catch (_) {
    // 超时降级：使用本地兜底提示
    setState(() {
      _aiResponse = _generateFallbackHint(_currentHintLevel);
      _isLoading = false;
    });
  } catch (e) {
    // 其他错误（5xx、网络错误等）降级
    setState(() {
      _aiResponse = _generateFallbackHint(_currentHintLevel);
      _isLoading = false;
    });
  }
}

Map<String, dynamic> _generateFallbackHint(String hintLevel) {
  // 根据测试用例结果生成本地提示
  final testCases = widget.visibleTestCases ?? [];
  final failedCases = testCases.where((c) => c['passed'] == false).toList();

  switch (hintLevel) {
    case 'error_location':
      return {
        'hint_level': 1,
        'summary': '检测到部分测试用例未通过',
        'error_location': {
          'section': '代码结构',
          'selector': failedCases.isNotEmpty ? '相关元素' : '未知',
          'property': '请检查可见测试用例要求',
        },
        'observable_symptom': '页面渲染结果与预期不符',
        'next_check': '请对照测试用例检查代码中是否缺少必要的标签或属性',
      };
    case 'correction_hint':
      return {
        'hint_level': 2,
        'summary': '修正方向建议',
        'root_cause': {
          'category': '结构或样式问题',
          'detail': '代码可能缺少必要的 HTML 标签或 CSS 属性',
        },
        'direction': {
          'priority': '先检查 HTML 结构',
          'reason': 'HTML 是页面的骨架，结构错误会影响后续样式应用',
        },
        'suggestions': [
          '检查是否使用了正确的 HTML 标签',
          '检查 CSS 选择器是否正确匹配了目标元素',
        ],
      };
    case 'operation_suggestion':
    default:
      return {
        'hint_level': 3,
        'summary': '可执行的操作步骤',
        'action_steps': [
          {'step': 1, 'action': '对照测试用例要求，逐一检查代码', 'expected': '确认每个要求都有对应的代码实现'},
          {'step': 2, 'action': '检查 HTML 标签是否正确闭合', 'expected': '所有标签都有开和闭'},
          {'step': 3, 'action': '检查 CSS 属性拼写是否正确', 'expected': '属性名无拼写错误'},
          {'step': 4, 'action': '重新提交代码查看结果', 'expected': '观察哪些测试用例状态发生变化'},
        ],
        'final_reminder': '修改后重新提交，观察测试用例变化。如仍有问题，可再次请求帮助。',
      };
  }
}
```

### UI 展示调整
确保 `_aiResponse` 的展示逻辑能同时处理后端返回的 JSON 和本地兜底的 JSON。两者的结构应该保持一致（都是三级提示格式）。

可能需要在展示组件中添加一个标识，提示用户"当前为离线提示"：
```dart
if (_isFallback) ...[
  Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Row(
      children: [
        Icon(Icons.offline_bolt, size: 16.sp, color: Colors.orange),
        SizedBox(width: 4.w),
        Text(
          '离线提示模式',
          style: TextStyle(fontSize: 12.sp, color: Colors.orange),
        ),
      ],
    ),
  ),
]
```

## 测试验证
- [ ] 正常网络下调用后端 AI Help 正常展示
- [ ] 关闭后端服务或断开网络，触发兜底逻辑
- [ ] 三级提示（error_location / correction_hint / operation_suggestion）都有对应的本地提示
- [ ] 兜底提示的 JSON 结构与后端返回结构一致，展示组件正常渲染

## 注意
- 兜底提示应该是"安全"的，不给答案，只给方向
- 保持与现有 Bottom Sheet UI 风格一致
- 超时时间设为 10 秒比较合理
