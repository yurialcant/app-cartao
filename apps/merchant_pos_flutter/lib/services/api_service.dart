import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:merchant_pos_flutter/config/app_environment.dart';

class ApiService {
  late final Dio _dio;
  late String baseUrl;
  
  ApiService() {
    // Usa a configuração do AppEnvironment
    baseUrl = AppEnvironment().baseUrl;
    
    print('🌐 [API Service] Inicializando Merchant POS com baseUrl: $baseUrl');
    print('🌐 [API Service] Ambiente: ${AppEnvironment().environment}');
    
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: AppEnvironment().apiTimeoutSeconds),
      receiveTimeout: Duration(seconds: AppEnvironment().apiTimeoutSeconds),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🌐 [API] → ${options.method} ${options.baseUrl}${options.path}');
        if (options.data != null) {
          print('🌐 [API] Body: ${options.data}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('🌐 [API] ← ${response.statusCode} ${response.requestOptions.method}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('🌐 [API] ❌ Erro: ${error.type}');
        print('🌐 [API] Status: ${error.response?.statusCode}');
        handler.next(error);
      },
    ));
  }
  
  Future<Map<String, dynamic>> createQRCharge(double amount) async {
    final response = await _dio.post(
      '/charges/qr',
      data: {'amount': amount},
    );
    return response.data;
  }

  void setAccessToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      print('🌐 [API] Token configurado');
    } else {
      _dio.options.headers.remove('Authorization');
      print('🌐 [API] Token removido');
    }
  }
}
