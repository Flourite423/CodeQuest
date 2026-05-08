import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../challenge/challenge_list_view.dart';
import '../course/course_list_view.dart';
import '../profile/profile_view.dart';
import '../social/social_view.dart';
import 'home_dashboard_view.dart';

/// 学习者应用主壳组件
/// 
/// 提供5-Tab底部导航，使用IndexedStack保持已访问页面的状态。
/// Tab采用惰性初始化：只有被访问过的Tab才会被构建，切换Tab时状态保持。
/// 针对手机操作优化：底部导航固定、热区最小48x48、SafeArea处理。
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Obx(() => IndexedStack(
          index: controller.selectedIndex.value,
          children: List.generate(5, (index) {
            // Only build tabs that have been visited (lazy initialization)
            if (!controller.visitedTabs.contains(index)) {
              return const SizedBox.shrink();
            }
            switch (index) {
              case 0:
                return const HomeDashboardView();
              case 1:
                return const CourseListView();
              case 2:
                return const ChallengeListView();
              case 3:
                return const SocialView();
              case 4:
                return const ProfileView();
              default:
                return const SizedBox.shrink();
            }
          }),
        )),
      ),
      bottomNavigationBar: Obx(() => _buildBottomNav(context, colorScheme)),
    );
  }

  /// 构建底部导航栏
  /// 
  /// 使用 fixed 类型（5个tab必须），确保每个item有足够的热区。
  /// 活跃状态有明确的视觉反馈：填充图标 + 主色高亮。
  Widget _buildBottomNav(BuildContext context, ColorScheme colorScheme) {
    return BottomNavigationBar(
      currentIndex: controller.selectedIndex.value,
      onTap: controller.changeTab,
      type: BottomNavigationBarType.fixed,
      // 使用主题色，确保活跃状态视觉反馈明确
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      // 选中标签样式：增大字体确保清晰可读
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 12,
      ),
      // 背景色与主题一致
      backgroundColor: colorScheme.surface,
      // 提升高度，增加视觉层次
      elevation: 8,
      items: [
        _buildNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
          // TODO: 接入真实未读消息数
          badgeCount: controller.homeBadgeCount.value,
        ),
        _buildNavItem(
          icon: Icons.book_outlined,
          activeIcon: Icons.book,
          label: 'Courses',
          badgeCount: controller.coursesBadgeCount.value,
        ),
        _buildNavItem(
          icon: Icons.emoji_events_outlined,
          activeIcon: Icons.emoji_events,
          label: 'Challenges',
          badgeCount: controller.challengesBadgeCount.value,
        ),
        _buildNavItem(
          icon: Icons.groups_outlined,
          activeIcon: Icons.groups,
          label: 'Social',
          badgeCount: controller.socialBadgeCount.value,
        ),
        _buildNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile',
          badgeCount: controller.profileBadgeCount.value,
        ),
      ],
    );
  }

  /// 构建单个导航项，支持未读红点（badge）
  /// 
  /// 图标尺寸24 + padding，确保热区至少48x48。
  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int badgeCount = 0,
  }) {
    return BottomNavigationBarItem(
      icon: _BadgedIcon(
        icon: icon,
        badgeCount: badgeCount,
      ),
      activeIcon: _BadgedIcon(
        icon: activeIcon,
        badgeCount: badgeCount,
      ),
      label: label,
    );
  }
}

/// 带未读红点的图标组件
/// 
/// 当badgeCount > 0时，在图标右上角显示红色圆点。
/// 红点尺寸紧凑，不遮挡图标主体。
class _BadgedIcon extends StatelessWidget {
  final IconData icon;
  final int badgeCount;

  const _BadgedIcon({
    required this.icon,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: 24),
        if (badgeCount > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 主页控制器
/// 
/// 管理底部导航选中状态、各Tab未读消息数和访问记录。
/// visitedTabs记录用户已访问过的Tab，用于惰性初始化。
class HomeController extends GetxController {
  final selectedIndex = 0.obs;

  /// 记录已访问过的Tab索引列表，初始包含Tab 0（首页）
  /// 用于IndexedStack的惰性构建：只构建已访问的Tab
  final visitedTabs = <int>[0].obs;

  // 各Tab未读消息数（占位，后续接入真实数据）
  final homeBadgeCount = 0.obs;
  final coursesBadgeCount = 0.obs;
  final challengesBadgeCount = 0.obs;
  final socialBadgeCount = 0.obs;
  final profileBadgeCount = 0.obs;

  void changeTab(int index) {
    if (!visitedTabs.contains(index)) {
      visitedTabs.add(index);
    }
    selectedIndex.value = index;
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
