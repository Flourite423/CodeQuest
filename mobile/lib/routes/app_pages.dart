import 'package:get/get.dart';

import '../views/challenge/challenge_detail_view.dart';
import '../views/challenge/challenge_list_view.dart';
import '../views/chapter/chapter_view.dart';
import '../views/course/course_detail_view.dart';
import '../views/course/course_list_view.dart';
import '../views/daily_challenge/daily_challenge_view.dart';
import '../views/exercise/exercise_view.dart';
import '../views/friends/friends_view.dart';
import '../views/home/home_view.dart';
import '../views/login/login_view.dart';
import '../views/onboarding/onboarding_view.dart';
import '../views/profile/profile_view.dart';
import '../views/profile_edit/profile_edit_view.dart';
import '../views/profile_rewards/profile_rewards_view.dart';
import '../views/profile_stats/profile_stats_view.dart';
import '../views/register/register_view.dart';
import '../views/settings/settings_view.dart';
import '../views/add_friend/add_friend_view.dart';
import '../views/social/social_view.dart';
import '../views/splash/splash_view.dart';

class AppPages {
  static const initialRoute = '/splash';

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
      name: '/onboarding',
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: '/register',
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: '/home',
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: '/courses',
      page: () => const CourseListView(),
      binding: CourseListBinding(),
    ),
    GetPage(
      name: '/course/:id',
      page: () => const CourseDetailView(),
      binding: CourseBinding(),
    ),
    GetPage(
      name: '/chapter/:id',
      page: () => const ChapterView(),
      binding: ChapterBinding(),
    ),
    GetPage(
      name: '/exercise/:id',
      page: () => const ExerciseView(),
      binding: ExerciseBinding(),
    ),
    GetPage(
      name: '/challenges',
      page: () => const ChallengeListView(),
      binding: ChallengeListBinding(),
    ),
    GetPage(
      name: '/challenge/:id',
      page: () => const ChallengeDetailView(),
      binding: ChallengeBinding(),
    ),
    GetPage(
      name: '/daily-challenge',
      page: () => const DailyChallengeView(),
      binding: DailyChallengeBinding(),
    ),
    GetPage(
      name: '/social',
      page: () => const SocialView(),
      binding: SocialBinding(),
    ),
    GetPage(
      name: '/add-friend',
      page: () => const AddFriendView(),
      binding: AddFriendBinding(),
    ),
    GetPage(
      name: '/profile',
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: '/profile/stats',
      page: () => const ProfileStatsView(),
      binding: ProfileStatsBinding(),
    ),
    GetPage(
      name: '/profile/rewards',
      page: () => const ProfileRewardsView(),
      binding: ProfileRewardsBinding(),
    ),
    GetPage(
      name: '/profile/edit',
      page: () => const ProfileEditView(),
      binding: ProfileEditBinding(),
    ),
    GetPage(
      name: '/settings',
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: '/friends',
      page: () => const FriendsView(),
      binding: FriendsBinding(),
    ),
  ];
}
