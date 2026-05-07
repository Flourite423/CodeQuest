import 'package:get/get.dart';

class AppPages {
  static const INITIAL = '/splash';
  
  static final routes = [
    GetPage(
      name: '/splash',
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: '/login',
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: '/home',
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: '/course/:id',
      page: () => const CourseDetailView(),
      binding: CourseBinding(),
    ),
    GetPage(
      name: '/challenge/:id',
      page: () => const ChallengeDetailView(),
      binding: ChallengeBinding(),
    ),
    GetPage(
      name: '/profile',
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: '/leaderboard',
      page: () => const LeaderboardView(),
      binding: LeaderboardBinding(),
    ),
    GetPage(
      name: '/friends',
      page: () => const FriendsView(),
      binding: FriendsBinding(),
    ),
  ];
}
