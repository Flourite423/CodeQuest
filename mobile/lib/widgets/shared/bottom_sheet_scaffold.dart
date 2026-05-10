import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bottom sheet scaffold with drag handle, title bar, content area and action area.
///
/// Used for modal bottom sheets that need consistent structure.
class BottomSheetScaffold extends StatelessWidget {
  const BottomSheetScaffold({
    super.key,
    this.title,
    this.showDragHandle = true,
    required this.content,
    this.actions,
    this.contentPadding,
  });

  final String? title;
  final bool showDragHandle;
  final Widget content;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDragHandle) ...[
              SizedBox(height: 8.h),
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
            if (title != null) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title!,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Divider(height: 1.h),
            ],
            Flexible(
              child: SingleChildScrollView(
                padding: contentPadding ?? EdgeInsets.all(16.w),
                child: content,
              ),
            ),
            if (actions != null) ...[
              Divider(height: 1.h),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: actions!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
