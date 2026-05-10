import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/base_controller.dart';
import '../../models/models.dart' as app_models;
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/page_state_host.dart';

class ProfileEditView extends GetView<ProfileEditController> {
  const ProfileEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑资料'),
        actions: [
          TextButton(
            onPressed: controller.saveProfile,
            child: const Text('保存'),
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
            final avatarFile = controller.avatarFile.value;
            final isUploading = controller.isUploadingAvatar.value;

            return Stack(
              children: [
                CircleAvatar(
                  radius: 60.r,
                  backgroundColor: colorScheme.primaryContainer,
                  backgroundImage: avatarFile != null
                      ? FileImage(avatarFile) as ImageProvider
                      : (avatarUrl != null ? NetworkImage(avatarUrl) : null),
                  child: avatarFile == null && avatarUrl == null
                      ? Icon(
                          Icons.person,
                          size: 60.sp,
                          color: colorScheme.onPrimaryContainer,
                        )
                      : null,
                ),
                if (isUploading)
                  Positioned.fill(
                    child: CircleAvatar(
                      radius: 60.r,
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      child: SizedBox(
                        width: 32.w,
                        height: 32.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
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
                      onPressed: isUploading ? null : controller.pickAvatar,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 12.h),
          Obx(() {
            final isUploading = controller.isUploadingAvatar.value;
            return TextButton.icon(
              onPressed: isUploading ? null : controller.pickAvatar,
              icon: isUploading
                  ? SizedBox(
                      width: 18.w,
                      height: 18.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    )
                  : const Icon(Icons.image_outlined),
              label: Text(isUploading ? '上传中...' : '更换头像'),
            );
          }),
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
          '基本信息',
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
    return TextFormField(
      controller: controller.nicknameController,
      decoration: InputDecoration(
        labelText: '昵称',
        hintText: '请输入昵称',
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
  }

  Widget _buildBioField(BuildContext context) {
    return TextFormField(
      controller: controller.bioController,
      decoration: InputDecoration(
        labelText: '个人简介（可选）',
        hintText: '介绍一下你自己',
        prefixIcon: const Icon(Icons.edit_note_outlined),
        counterText: '${controller.bioController.text.length}/200',
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
      ),
      style: TextStyle(fontSize: 16.sp),
      maxLines: 3,
      maxLength: 200,
      textInputAction: TextInputAction.done,
      onChanged: controller.validateBio,
    );
  }

  Widget _buildDailyGoalSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '每日目标',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '每天想学习多少分钟？',
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
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
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
          '主题',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '选择你喜欢的界面外观',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 12.h),
        Obx(() {
          final selectedTheme = controller.themeMode.value;
          final themes = [
            _ThemeOption('system', '跟随系统', Icons.brightness_auto),
            _ThemeOption('light', '浅色', Icons.brightness_7),
            _ThemeOption('dark', '深色', Icons.brightness_2),
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
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
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
          onPressed:
              controller.isFormValid.value ? controller.saveProfile : null,
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
                    valueColor:
                        AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                  ),
                )
              : Text(
                  '保存更改',
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
  ApiService get _apiService => Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  final nicknameController = TextEditingController();
  final bioController = TextEditingController();

  final Rx<app_models.User?> user = Rx<app_models.User?>(null);
  final Rx<String?> avatarUrl = Rx<String?>(null);
  final Rx<File?> avatarFile = Rx<File?>(null);
  final RxBool isUploadingAvatar = false.obs;
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
    setLoading(message: '加载个人资料中...');
    registerRetry(loadProfileData);

    try {
      final response = await _apiService.get('/learner/profile');
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final profile =
          payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

      // Build user from profile data
      user.value = app_models.User.fromContracts(
        account: {'id': profile['account_id'] ?? '', 'email': ''},
        profile: profile,
      );

      avatarUrl.value = profile['avatar_url'] as String?;
      nicknameController.text = (profile['nickname'] ?? '').toString();
      bioController.text = (profile['bio'] as String?) ?? '';

      final goal = profile['daily_goal_minutes'];
      if (goal != null) {
        dailyGoal.value = goal is int ? goal : int.tryParse(goal.toString()) ?? 30;
      }
      final theme = profile['theme_mode'] as String?;
      if (theme != null && theme.isNotEmpty) {
        themeMode.value = theme;
      }

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
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await setAuthExpired(message: '登录状态已失效，请重新登录后编辑资料。');
      } else if (e.response?.statusCode == 403) {
        setError(message: '当前账号暂无编辑权限。');
      } else if (e.response?.statusCode == 500) {
        setError(message: '个人资料服务暂时不可用，请稍后重试。');
      } else if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        setError(message: '加载个人资料超时，请重试。');
      } else if (e.type == dio.DioExceptionType.connectionError) {
        setError(message: '网络连接异常，请检查后重试。');
      } else {
        setError(message: '加载个人资料失败，请重试。');
      }
    } catch (e) {
      setError(message: '加载个人资料失败，请重试。');
    }
  }

  void validateNickname(String value) {
    if (value.trim().isEmpty) {
      nicknameError.value = '昵称不能为空';
    } else if (value.trim().length > maxNicknameLength) {
      nicknameError.value = '昵称不能超过 $maxNicknameLength 个字符';
    } else {
      nicknameError.value = '';
    }
    validateForm();
  }

  void validateBio(String value) {
    if (value.length > maxBioLength) {
      bioError.value = '简介不能超过 $maxBioLength 个字符';
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
    _showImageSourceSheet();
  }

  void _showImageSourceSheet() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '更换头像',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Get.theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: Get.theme.colorScheme.onSurface,
                ),
                title: Text(
                  '拍照',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Get.theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: Get.theme.colorScheme.onSurface,
                ),
                title: Text(
                  '从相册选择',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Get.theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.gallery);
                },
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await _uploadAvatar(File(pickedFile.path));
      }
    } catch (e) {
      if (e.toString().contains('permission') ||
          e.toString().contains('denied')) {
        Get.snackbar(
          '权限不足',
          '请在系统设置中允许访问相册或相机权限。',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          margin: EdgeInsets.all(16.w),
        );
      } else {
        Get.snackbar(
          '选择失败',
          '无法选择图片，请重试。',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          margin: EdgeInsets.all(16.w),
        );
      }
    }
  }

  Future<void> _uploadAvatar(File imageFile) async {
    isUploadingAvatar.value = true;

    try {
      // TODO: Replace with actual avatar upload endpoint when available
      // For now, keep the selected file locally
      avatarFile.value = imageFile;

      Get.snackbar(
        '上传成功',
        '头像已更新',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.all(16.w),
      );
    } catch (e) {
      Get.snackbar(
        '上传失败',
        '头像上传失败，请重试。',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.all(16.w),
      );
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  Future<void> saveProfile() async {
    if (!isFormValid.value) return;

    isSaving.value = true;

    try {
      // Persist settings locally
      await _storageService.write(_dailyGoalKey, dailyGoal.value);
      await _storageService.write(_themeModeKey, themeMode.value);

      // Send PATCH request to update profile
      await _apiService.patch('/learner/profile', data: {
        'nickname': nicknameController.text.trim(),
        'bio': bioController.text.trim().isEmpty
            ? null
            : bioController.text.trim(),
        'daily_goal_minutes': dailyGoal.value,
        'theme_mode': themeMode.value,
      });

      Get.back();
      Get.snackbar(
        '保存成功',
        '个人资料已更新',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.all(16.w),
      );
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 400) {
        Get.snackbar(
          '数据错误',
          '请检查输入内容后重试。',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          margin: EdgeInsets.all(16.w),
        );
      } else if (e.response?.statusCode == 401) {
        await setAuthExpired(message: '登录状态已失效，请重新登录。');
      } else if (e.response?.statusCode == 500) {
        Get.snackbar(
          '服务错误',
          '保存服务暂时不可用，请稍后重试。',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          margin: EdgeInsets.all(16.w),
        );
      } else if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        Get.snackbar(
          '请求超时',
          '保存超时，请重试。',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          margin: EdgeInsets.all(16.w),
        );
      } else if (e.type == dio.DioExceptionType.connectionError) {
        Get.snackbar(
          '网络错误',
          '网络连接异常，请检查后重试。',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          margin: EdgeInsets.all(16.w),
        );
      } else {
        Get.snackbar(
          '错误',
          '保存个人资料失败，请重试。',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          margin: EdgeInsets.all(16.w),
        );
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '保存个人资料失败，请重试。',
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
