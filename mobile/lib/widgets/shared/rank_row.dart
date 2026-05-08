import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Leaderboard row with rank, avatar, username, level and XP.
///
/// Top 3 ranks use special colors (gold, silver, bronze).
/// Current user can be highlighted.
class RankRow extends StatelessWidget {
  const RankRow({
    super.key,
    required this.rank,
    required this.username,
    required this.level,
    required this.xp,
    this.avatarUrl,
    this.isCurrentUser = false,
    this.onTap,
  });

  final int rank;
  final String username;
  final int level;
  final int xp;
  final String? avatarUrl;
  final bool isCurrentUser;
  final VoidCallback? onTap;

  Color _rankColor(BuildContext context) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              SizedBox(
                width: 40.w,
                child: Center(
                  child: rank <= 3
                      ? Icon(
                          Icons.emoji_events,
                          color: _rankColor(context),
                          size: 28.sp,
                        )
                      : Text(
                          '$rank',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _rankColor(context),
                          ),
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              CircleAvatar(
                radius: 16.r,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? Text(
                        username.isNotEmpty ? username[0].toUpperCase() : '?',
                        style: TextStyle(fontSize: 14.sp),
                      )
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      username,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: isCurrentUser ? FontWeight.w600 : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Level $level',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Flexible(
                child: Text(
                  '$xp XP',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
