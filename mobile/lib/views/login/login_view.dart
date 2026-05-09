import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/page_state_host.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          SizedBox(height: 60.h),
          Icon(
            Icons.school,
            size: 64.sp,
            color: theme.primaryColor,
          ),
          SizedBox(height: 24.h),
          Text(
            '欢迎回来',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            '登录以继续学习',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 48.h),

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
            textInputAction: TextInputAction.done,
            onChanged: (_) => controller.clearPasswordError(),
            onSubmitted: (_) => controller.login(),
          )),
          SizedBox(height: 32.h),

          // Login button
          Obx(() => SizedBox(
            width: double.infinity,
            height: 56.h,
            child: FilledButton(
              onPressed: controller.isLoading.value ? null : controller.login,
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
                      '登录',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          )),
          SizedBox(height: 24.h),

          // Register link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '还没有账号？',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/register'),
                child: const Text('注册'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LoginController extends BaseController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final emailError = ''.obs;
  final passwordError = ''.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void clearEmailError() {
    emailError.value = '';
  }

  void clearPasswordError() {
    passwordError.value = '';
  }

  bool _validate() {
    bool isValid = true;

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
    } else if (password.length < 6) {
      passwordError.value = '密码至少需要6个字符';
      isValid = false;
    }

    return isValid;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> login() async {
    if (!_validate()) return;

    isLoading.value = true;
    resetState();

    try {
      final response = await _apiService.post('/auth/login', data: {
        'email': emailController.text.trim(),
        'password': passwordController.text,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'] as String?;
        if (token != null && token.isNotEmpty) {
          await _storage.write(StorageService.authTokenKey, token);
          Get.offAllNamed('/home');
        } else {
          setError(message: '服务器响应无效');
        }
      }
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        setError(message: '邮箱或密码错误');
      } else if (e.response?.statusCode == 403) {
        setError(message: '账号已被禁用，请联系客服');
      } else if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        setError(message: '连接超时，请重试');
      } else if (e.type == dio.DioExceptionType.connectionError) {
        setError(message: '无网络连接，请检查网络设置');
      } else {
        setError(message: '登录失败，请稍后重试');
      }
    } catch (e) {
      setError(message: '发生未知错误，请重试');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
