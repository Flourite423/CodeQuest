import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../models/models.dart';
import '../../../widgets/shared/bottom_sheet_scaffold.dart';

class AIHelpSheet extends StatelessWidget {
  const AIHelpSheet({
    super.key,
    required this.aiHelp,
    required this.exerciseTitle,
  });

  final AIHelp aiHelp;
  final String exerciseTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BottomSheetScaffold(
      title: 'AI 帮助',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exerciseTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '类型：${_requestTypeLabel(aiHelp.requestType)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '提示内容',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            aiHelp.content ?? '暂时没有可展示的帮助内容。',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'AI 只提供方向性提示，不会返回完整答案，也不会暴露隐藏测试断言或 is_correct 字段。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('继续练习'),
          ),
        ),
      ],
    );
  }

  String _requestTypeLabel(String requestType) {
    switch (requestType) {
      case 'error_explanation':
        return '错误解释';
      case 'hint':
        return '解题提示';
      default:
        return '学习帮助';
    }
  }
}
