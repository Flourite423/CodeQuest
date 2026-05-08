import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../controllers/base_controller.dart';
import 'storage_service.dart';

class ApiService extends GetxService {
  late final dio.Dio _dio;
  final Logger _logger = Logger();

  @override
  void onInit() {
    super.onInit();
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: 'http://localhost:8080/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) {
        if (Get.isRegistered<StorageService>()) {
          final token = Get.find<StorageService>().readAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }

        _logger.i('Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.i('Response: ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (error, handler) {
        _logger.e('Error: ${error.message}');

        if (error.response?.statusCode == 401) {
          BaseController.handleUnauthorized();
        }

        return handler.next(error);
      },
    ));
  }

  Future<dio.Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<dio.Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  Future<dio.Response> put(String path, {dynamic data}) async {
    return _dio.put(path, data: data);
  }

  Future<dio.Response> delete(String path) async {
    return _dio.delete(path);
  }
}
