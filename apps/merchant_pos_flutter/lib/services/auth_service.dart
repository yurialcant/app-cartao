import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:merchant_pos_flutter/config/app_environment.dart';

class AuthService {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();
  late String baseUrl;
  
  AuthService() {
    baseUrl = AppEnvironment().baseUrl;
  }
  
  Future<bool> login(String username, String password) async {
    try {
      print('🔐 [Auth] Tentando login para: $username');
      final response = await _dio.post(
        '$baseUrl/auth/login',
        data: {'username': username, 'password': password},
      );
      final token = response.data['access_token'];
      await _storage.write(key: 'token', value: token);
      print('🔐 [Auth] Login bem-sucedido');
      return true;
    } catch (e) {
      print('🔐 [Auth] Erro no login: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
  }
}
