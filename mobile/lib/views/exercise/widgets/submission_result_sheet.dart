import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../models/models.dart';
import '../../../widgets/shared/bottom_sheet_scaffold.dart';

class SubmissionResultSheet extends StatelessWidget {
  const SubmissionResultSheet({
    super.key,
    required this.result,
    required this.onContinue,
    required this.onViewAiHelp,
  });

  final SubmissionResult result;
  final VoidCallback onContinue;
  final VoidCallback onViewAiHelp;

  bool get hasPassed => result.totalCases == 0 || result.passedCases >= result.totalCases;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BottomSheetScaffold(
      title: '提交结果',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: hasPassed
                  ? colorScheme.primaryContainer
                  : colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      hasPassed ? Icons.check_circle : Icons.error_outline,
                      color: hasPassed
                          ? colorScheme.primary
                          : colorScheme.error,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      hasPassed ? '通过' : '未通过',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  '得分 ${result.score}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '通过 ${result.passedCases}/${result.totalCases} 个测试用例',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '反馈',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            result.feedback ?? '本次结果未返回额外反馈。',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '仅展示 learner 可见的聚合结果；隐藏断言与内部评测细节不会出现在这里。',
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
          height: 48.h,
          child: OutlinedButton(
            onPressed: onViewAiHelp,
            child: const Text('查看 AI 帮助'),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: FilledButton(
            onPressed: onContinue,
            child: Text(hasPassed ? '继续' : '继续修改'),
          ),
        ),
      ],
    );
  }
}
