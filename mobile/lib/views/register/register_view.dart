import 'package:dio/dio.dart' as dio;
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
        title: const Text('Sign Up'),
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
            'Create Account',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Start your learning journey today',
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
              labelText: 'Nickname',
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
              labelText: 'Email',
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
              labelText: 'Password',
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
              labelText: 'Confirm Password',
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
              onPressed: controller.isLoading.value ? null : controller.register,
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
                      'Sign Up',
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
                'Already have an account? ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Sign In'),
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
      nicknameError.value = 'Nickname is required';
      isValid = false;
    } else if (nickname.length < 2) {
      nicknameError.value = 'Nickname must be at least 2 characters';
      isValid = false;
    }

    final email = emailController.text.trim();
    if (email.isEmpty) {
      emailError.value = 'Email is required';
      isValid = false;
    } else if (!_isValidEmail(email)) {
      emailError.value = 'Please enter a valid email';
      isValid = false;
    }

    final password = passwordController.text;
    if (password.isEmpty) {
      passwordError.value = 'Password is required';
      isValid = false;
    } else if (password.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
      isValid = false;
    }

    final confirmPassword = confirmPasswordController.text;
    if (confirmPassword.isEmpty) {
      confirmPasswordError.value = 'Please confirm your password';
      isValid = false;
    } else if (confirmPassword != password) {
      confirmPasswordError.value = 'Passwords do not match';
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
      final response = await _apiService.post('/auth/register', data: {
        'nickname': nicknameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Auto-login after successful registration
        final token = response.data['token'] as String?;
        if (token != null && token.isNotEmpty) {
          await _storage.write(StorageService.authTokenKey, token);
          Get.offAllNamed('/home');
        } else {
          // If no token in response, redirect to login
          Get.snackbar(
            'Success',
            'Account created successfully. Please sign in.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
          );
          Get.offAllNamed('/login');
        }
      }
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 409) {
        setError(message: 'An account with this email already exists.');
      } else if (e.response?.statusCode == 422) {
        setError(message: 'Invalid input. Please check your information.');
      } else if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        setError(message: 'Connection timed out. Please try again.');
      } else if (e.type == dio.DioExceptionType.connectionError) {
        setError(message: 'No internet connection. Please check your network.');
      } else {
        setError(message: 'Registration failed. Please try again later.');
      }
    } catch (e) {
      setError(message: 'An unexpected error occurred. Please try again.');
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
