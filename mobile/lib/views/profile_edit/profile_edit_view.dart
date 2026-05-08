import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/models.dart' as app_models;
import '../../services/mock_data.dart';
import '../../services/storage_service.dart';
import '../../widgets/page_state_host.dart';

class ProfileEditView extends GetView<ProfileEditController> {
  const ProfileEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: controller.saveProfile,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Obx(() {
        return PageStateHost(
          state: controller.pageState.value,
          onRetry: controller.retry,
          child: _buildContent(context),
        );
      }),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatarSection(context),
          SizedBox(height: 24.h),
          _buildFormSection(context),
          SizedBox(height: 24.h),
          _buildDailyGoalSection(context),
          SizedBox(height: 24.h),
          _buildThemeSection(context),
          SizedBox(height: 32.h),
          _buildSaveButton(context),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        children: [
          Obx(() {
            final avatarUrl = controller.avatarUrl.value;
            return Stack(
              children: [
                CircleAvatar(
                  radius: 60.r,
                  backgroundColor: colorScheme.primaryContainer,
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Icon(
                          Icons.person,
                          size: 60.sp,
                          color: colorScheme.onPrimaryContainer,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20.r,
                    backgroundColor: colorScheme.primary,
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        size: 20.sp,
                        color: colorScheme.onPrimary,
                      ),
                      onPressed: controller.pickAvatar,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 12.h),
          TextButton.icon(
            onPressed: controller.pickAvatar,
            icon: const Icon(Icons.image_outlined),
            label: const Text('Change Photo'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Info',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 12.h),
        _buildNicknameField(context),
        SizedBox(height: 16.h),
        _buildBioField(context),
      ],
    );
  }

  Widget _buildNicknameField(BuildContext context) {
    return Obx(() {
      return TextFormField(
        controller: controller.nicknameController,
        decoration: InputDecoration(
          labelText: 'Nickname',
          hintText: 'Enter your nickname',
          prefixIcon: const Icon(Icons.person_outline),
          errorText: controller.nicknameError.value.isEmpty
              ? null
              : controller.nicknameError.value,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
        style: TextStyle(fontSize: 16.sp),
        textInputAction: TextInputAction.next,
        onChanged: controller.validateNickname,
      );
    });
  }

  Widget _buildBioField(BuildContext context) {
    return Obx(() {
      final bioLength = controller.bioController.text.length;
      final maxLength = 200;

      return TextFormField(
        controller: controller.bioController,
        decoration: InputDecoration(
          labelText: 'Bio (Optional)',
          hintText: 'Tell us about yourself',
          prefixIcon: const Icon(Icons.edit_note_outlined),
          counterText: '$bioLength/$maxLength',
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
        style: TextStyle(fontSize: 16.sp),
        maxLines: 3,
        maxLength: maxLength,
        textInputAction: TextInputAction.done,
        onChanged: controller.validateBio,
      );
    });
  }

  Widget _buildDailyGoalSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Goal',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'How many minutes do you want to learn each day?',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 12.h),
        Obx(() {
          final selectedGoal = controller.dailyGoal.value;
          final goals = [15, 30, 60];

          return Row(
            children: goals.map((goal) {
              final isSelected = selectedGoal == goal;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: ChoiceChip(
                    label: Text('$goal min'),
                    selected: isSelected,
                    onSelected: (_) => controller.setDailyGoal(goal),
                    selectedColor: colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Choose your preferred appearance',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 12.h),
        Obx(() {
          final selectedTheme = controller.themeMode.value;
          final themes = [
            _ThemeOption('system', 'System', Icons.brightness_auto),
            _ThemeOption('light', 'Light', Icons.brightness_7),
            _ThemeOption('dark', 'Dark', Icons.brightness_2),
          ];

          return Row(
            children: themes.map((theme) {
              final isSelected = selectedTheme == theme.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: InkWell(
                    onTap: () => controller.setThemeMode(theme.value),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            theme.icon,
                            size: 28.sp,
                            color: isSelected
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            theme.label,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      return SizedBox(
        width: double.infinity,
        height: 52.h,
        child: ElevatedButton(
          onPressed: controller.isFormValid.value ? controller.saveProfile : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            disabledBackgroundColor: colorScheme.surfaceContainerHighest,
            disabledForegroundColor: colorScheme.onSurfaceVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: controller.isSaving.value
              ? SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                  ),
                )
              : Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      );
    });
  }
}

class _ThemeOption {
  const _ThemeOption(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;
}

class ProfileEditController extends BaseController {
  final MockDataService _mockDataService = MockDataService();
  final StorageService _storageService = Get.find<StorageService>();

  final nicknameController = TextEditingController();
  final bioController = TextEditingController();

  final Rx<app_models.User?> user = Rx<app_models.User?>(null);
  final Rx<String?> avatarUrl = Rx<String?>(null);
  final RxString nicknameError = ''.obs;
  final RxString bioError = ''.obs;
  final RxInt dailyGoal = 30.obs;
  final RxString themeMode = 'system'.obs;
  final RxBool isFormValid = false.obs;
  final RxBool isSaving = false.obs;

  static const int maxNicknameLength = 30;
  static const int maxBioLength = 200;
  static const String _dailyGoalKey = 'daily_goal_minutes';
  static const String _themeModeKey = 'theme_mode';

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  @override
  void onClose() {
    nicknameController.dispose();
    bioController.dispose();
    super.onClose();
  }

  Future<void> loadProfileData() async {
    setLoading(message: 'Loading profile...');
    registerRetry(loadProfileData);

    try {
      final userData = await _mockDataService.fetchUser();
      if (userData != null) {
        user.value = userData;
        avatarUrl.value = userData.avatar;
        nicknameController.text = userData.nickname;
        bioController.text = userData.bio ?? '';
        dailyGoal.value = userData.dailyGoal;
        themeMode.value = userData.themeMode;

        // Load persisted settings if available
        final persistedGoal = _storageService.read<int>(_dailyGoalKey);
        final persistedTheme = _storageService.read<String>(_themeModeKey);
        if (persistedGoal != null) {
          dailyGoal.value = persistedGoal;
        }
        if (persistedTheme != null) {
          themeMode.value = persistedTheme;
        }

        validateForm();
        resetState();
      } else {
        setEmpty(message: 'Profile data not available.');
      }
    } catch (e) {
      setError(message: 'Failed to load profile. Please try again.');
    }
  }

  void validateNickname(String value) {
    if (value.trim().isEmpty) {
      nicknameError.value = 'Nickname is required';
    } else if (value.trim().length > maxNicknameLength) {
      nicknameError.value = 'Nickname must be less than $maxNicknameLength characters';
    } else {
      nicknameError.value = '';
    }
    validateForm();
  }

  void validateBio(String value) {
    if (value.length > maxBioLength) {
      bioError.value = 'Bio must be less than $maxBioLength characters';
    } else {
      bioError.value = '';
    }
    validateForm();
  }

  void validateForm() {
    final nickname = nicknameController.text.trim();
    isFormValid.value = nickname.isNotEmpty &&
        nickname.length <= maxNicknameLength &&
        bioController.text.length <= maxBioLength;
  }

  void setDailyGoal(int goal) {
    dailyGoal.value = goal;
  }

  void setThemeMode(String mode) {
    themeMode.value = mode;
  }

  void pickAvatar() {
    // Placeholder for avatar upload
    // In a real app, this would open image picker
    Get.snackbar(
      'Coming Soon',
      'Avatar upload will be available in a future update.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
    );
  }

  Future<void> saveProfile() async {
    if (!isFormValid.value) return;

    isSaving.value = true;

    try {
      // Persist settings locally
      await _storageService.write(_dailyGoalKey, dailyGoal.value);
      await _storageService.write(_themeModeKey, themeMode.value);

      // Simulate API call delay
      await Future<void>.delayed(const Duration(milliseconds: 800));

      // Update local user data
      user.value = app_models.User(
        id: user.value?.id ?? '',
        email: user.value?.email ?? '',
        nickname: nicknameController.text.trim(),
        avatar: avatarUrl.value,
        level: user.value?.level ?? 1,
        xp: user.value?.xp ?? 0,
        streak: user.value?.streak ?? 0,
        bio: bioController.text.trim().isEmpty ? null : bioController.text.trim(),
        dailyGoal: dailyGoal.value,
        themeMode: themeMode.value,
      );

      Get.back();
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.all(16.w),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save profile. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.all(16.w),
      );
    } finally {
      isSaving.value = false;
    }
  }
}

class ProfileEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileEditController>(() => ProfileEditController());
  }
}
