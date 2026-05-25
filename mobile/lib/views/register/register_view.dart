import 'dart:math';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/page_state_host.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('注册'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() => PageStateHost(
              state: controller.pageState.value,
              child: _buildForm(context),
            )),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 16.h),
          Text(
            '创建账号',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            '今天开始学习之旅',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),

          // Nickname field
          Obx(() => TextField(
                controller: controller.nicknameController,
                decoration: InputDecoration(
                  labelText: '昵称',
                  prefixIcon: const Icon(Icons.person_outline),
                  errorText: controller.nicknameError.value.isEmpty
                      ? null
                      : controller.nicknameError.value,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                textInputAction: TextInputAction.next,
                onChanged: (_) => controller.clearNicknameError(),
              )),
          SizedBox(height: 16.h),

          // Email field
          Obx(() => TextField(
                controller: controller.emailController,
                decoration: InputDecoration(
                  labelText: '邮箱',
                  prefixIcon: const Icon(Icons.email_outlined),
                  errorText: controller.emailError.value.isEmpty
                      ? null
                      : controller.emailError.value,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: (_) => controller.clearEmailError(),
              )),
          SizedBox(height: 16.h),

          // Password field
          Obx(() => TextField(
                controller: controller.passwordController,
                decoration: InputDecoration(
                  labelText: '密码',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                  errorText: controller.passwordError.value.isEmpty
                      ? null
                      : controller.passwordError.value,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                obscureText: !controller.isPasswordVisible.value,
                textInputAction: TextInputAction.next,
                onChanged: (_) => controller.clearPasswordError(),
              )),
          SizedBox(height: 16.h),

          // Confirm password field
          Obx(() => TextField(
                controller: controller.confirmPasswordController,
                decoration: InputDecoration(
                  labelText: '确认密码',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isConfirmPasswordVisible.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: controller.toggleConfirmPasswordVisibility,
                  ),
                  errorText: controller.confirmPasswordError.value.isEmpty
                      ? null
                      : controller.confirmPasswordError.value,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                obscureText: !controller.isConfirmPasswordVisible.value,
                textInputAction: TextInputAction.done,
                onChanged: (_) => controller.clearConfirmPasswordError(),
                onSubmitted: (_) => controller.register(),
              )),
          SizedBox(height: 32.h),

          // Register button
          Obx(() => SizedBox(
                width: double.infinity,
                height: 56.h,
                child: FilledButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.register,
                  child: controller.isLoading.value
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Text(
                          '注册',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              )),
          SizedBox(height: 24.h),

          // Login link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '已有账号？',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('登录'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RegisterController extends BaseController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();

  final nicknameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final nicknameError = ''.obs;
  final emailError = ''.obs;
  final passwordError = ''.obs;
  final confirmPasswordError = ''.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void clearNicknameError() {
    nicknameError.value = '';
  }

  void clearEmailError() {
    emailError.value = '';
  }

  void clearPasswordError() {
    passwordError.value = '';
  }

  void clearConfirmPasswordError() {
    confirmPasswordError.value = '';
  }

  bool _validate() {
    bool isValid = true;

    final nickname = nicknameController.text.trim();
    if (nickname.isEmpty) {
      nicknameError.value = '请输入昵称';
      isValid = false;
    } else if (nickname.length < 2) {
      nicknameError.value = '昵称至少需要2个字符';
      isValid = false;
    }

    final email = emailController.text.trim();
    if (email.isEmpty) {
      emailError.value = '请输入邮箱';
      isValid = false;
    } else if (!_isValidEmail(email)) {
      emailError.value = '请输入有效的邮箱地址';
      isValid = false;
    }

    final password = passwordController.text;
    if (password.isEmpty) {
      passwordError.value = '请输入密码';
      isValid = false;
    } else if (password.length < 8) {
      passwordError.value = '密码至少需要8个字符';
      isValid = false;
    } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$')
        .hasMatch(password)) {
      passwordError.value = '密码需包含大写字母、小写字母和数字';
      isValid = false;
    }

    final confirmPassword = confirmPasswordController.text;
    if (confirmPassword.isEmpty) {
      confirmPasswordError.value = '请确认密码';
      isValid = false;
    } else if (confirmPassword != password) {
      confirmPasswordError.value = '两次输入的密码不一致';
      isValid = false;
    }

    return isValid;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> register() async {
    if (!_validate()) return;

    isLoading.value = true;
    resetState();

    try {
      final platform = kIsWeb ? 'web' : 'android';
      final response = await _apiService.post('/auth/register', data: {
        'nickname': nicknameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'device_id':
            '$platform-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}',
        'platform': platform,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Auto-login after successful registration
        final payload = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        final data = payload['data'] is Map<String, dynamic>
            ? payload['data'] as Map<String, dynamic>
            : payload;
        final token = (data['access_token'] ?? data['token']) as String?;
        if (token != null && token.isNotEmpty) {
          await _storage.write(StorageService.authTokenKey, token);
          Get.offAllNamed('/home');
        } else {
          // If no token in response, redirect to login
          Get.snackbar(
            '成功',
            '账号创建成功，请登录',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
          );
          Get.offAllNamed('/login');
        }
      }
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final payload = e.response?.data is Map<String, dynamic>
            ? e.response?.data as Map<String, dynamic>
            : null;
        final msg = payload?['error']?['message'] ??
            payload?['message'] ??
            '请求参数错误，请检查输入';
        setError(message: msg.toString());
      } else if (e.response?.statusCode == 409) {
        setError(message: '该邮箱已被注册');
      } else if (e.response?.statusCode == 422) {
        setError(message: '输入信息无效，请检查');
      } else if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        setError(message: '连接超时，请重试');
      } else if (e.type == dio.DioExceptionType.connectionError) {
        setError(message: '无网络连接，请检查网络设置');
      } else {
        setError(message: '注册失败，请稍后重试');
      }
    } catch (e) {
      setError(message: '发生未知错误，请重试');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nicknameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController());
  }
}
