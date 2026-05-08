import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../controllers/base_controller.dart';
import 'shared/empty_state.dart';
import 'shared/error_state.dart';
import 'shared/loading_state.dart';

class PageStateHost extends StatelessWidget {
  const PageStateHost({
    super.key,
    required this.state,
    required this.child,
    this.onRetry,
    this.message,
    this.emptyTitle = 'Nothing here yet',
    this.emptyDescription = 'Content will appear here when available.',
    this.emptyIcon = Icons.inbox_outlined,
  });

  final PageState state;
  final Widget child;
  final VoidCallback? onRetry;
  final String? message;
  final String emptyTitle;
  final String emptyDescription;
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case PageState.initial:
        return child;
      case PageState.loading:
        return LoadingState(message: message);
      case PageState.empty:
        return EmptyState(
          icon: emptyIcon,
          title: emptyTitle,
          description: message ?? emptyDescription,
          actionLabel: onRetry == null ? null : 'Refresh',
          onAction: onRetry,
        );
      case PageState.error:
        return ErrorState(
          message: message ?? 'Something went wrong. Please try again.',
          onRetry: onRetry ?? () {},
        );
      case PageState.offline:
        return _OfflineState(
          message: message ?? 'You are offline. Reconnect and try again.',
          onRetry: onRetry,
        );
      case PageState.authExpired:
        return _AuthExpiredState(
          message: message ?? 'Session expired. Redirecting to login...',
          onRetry: onRetry,
        );
      case PageState.partialData:
        return _PartialDataState(
          message: message ?? 'Some content is currently unavailable.',
          onRetry: onRetry,
          child: child,
        );
    }
  }
}

class _OfflineState extends StatelessWidget {
  const _OfflineState({
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64.sp,
              color: colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 16.h),
            Text(
              'No connection',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthExpiredState extends StatelessWidget {
  const _AuthExpiredState({
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_clock_outlined,
              size: 64.sp,
              color: colorScheme.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Session expired',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.login),
                  label: const Text('Go to login'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PartialDataState extends StatelessWidget {
  const _PartialDataState({
    required this.message,
    required this.child,
    this.onRetry,
  });

  final String message;
  final Widget child;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: colorScheme.onErrorContainer,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onRetry != null) ...[
                SizedBox(width: 12.w),
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
