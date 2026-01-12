import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;

  DioClient(this._dio) {
    _dio.options = BaseOptions(
      baseUrl: 'https://zenquotes.io/api/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add any request interceptors here
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Add any response interceptors here
          return handler.next(response);
        },
        onError: (error, handler) {
          // Add any error interceptors here
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}

