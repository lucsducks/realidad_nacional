// lib/auth_services.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://sv-te6t3kuxcj.cloud.elastika.pe/realidad',
    contentType: 'application/json',
  ));

  bool _isAuthenticated = false;
  String? _token;
  String? _username;
  String? _userId;

  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;
  String? get userId => _userId;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt');
    _username = prefs.getString('username');
    _userId = prefs.getString('userId');
    _isAuthenticated = _token != null;
    notifyListeners();
  }

  Future<void> _saveToken(String token, String username, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', token);
    await prefs.setString('username', username);
    await prefs.setString('userId', userId);
    _token = token;
    _username = username;
    _userId = userId;
    _isAuthenticated = true;
    notifyListeners();
  }

  /// Guarda únicamente el nombre de usuario en SharedPreferences
  Future<void> _saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    _username = username;
    notifyListeners();
  }

  /// Elimina el token, el nombre de usuario y el userId de SharedPreferences
  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    await prefs.remove('username');
    await prefs.remove('userId');
    _token = null;
    _username = null;
    _userId = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Recupera el token desde SharedPreferences
  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt');
    _username = prefs.getString('username');
    _userId = prefs.getString('userId');
    _isAuthenticated = _token != null;
    notifyListeners();
    return _token;
  }

  /// Registra un nuevo usuario
  Future<Map<String, dynamic>> registerUser(
      Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/auth/register', data: userData);
      if (response.data['token'] != null &&
          response.data['username'] != null &&
          response.data['userId'] != null) {
        await _saveToken(
          response.data['token'],
          response.data['username'],
          response.data['userId'],
        );
      }
      return {'success': true, 'data': response.data};
    } on DioError catch (e) {
      return {
        'success': false,
        'error':
            e.response?.data ?? 'Ocurrió un error al registrar el usuario.',
      };
    }
  }

  /// Inicia sesión de un usuario existente
  Future<Map<String, dynamic>> loginUser(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/auth/login', data: userData);
      if (response.data['token'] != null &&
          response.data['username'] != null &&
          response.data['userId'] != null) {
        await _saveToken(
          response.data['token'],
          response.data['username'],
          response.data['userId'],
        );
      }
      return {'success': true, 'data': response.data};
    } on DioError catch (e) {
      return {
        'success': false,
        'error': e.response?.data ?? 'Ocurrió un error al iniciar sesión.',
      };
    }
  }

  /// Envía una solicitud para recuperar la contraseña
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response =
          await _dio.post('/auth/forgot-password', data: {'email': email});
      return {'success': true, 'data': response.data};
    } on DioError catch (e) {
      return {
        'success': false,
        'error': e.response?.data ??
            'Ocurrió un error al enviar el correo de recuperación.',
      };
    }
  }

  /// Restaura la contraseña utilizando un token
  Future<Map<String, dynamic>> restorePassword(
      String password, String token) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password/restore',
        data: {'password': password},
        queryParameters: {'token': token},
      );
      return {'success': true, 'data': response.data};
    } on DioError catch (e) {
      return {
        'success': false,
        'error':
            e.response?.data ?? 'Ocurrió un error al restaurar la contraseña.',
      };
    }
  }

  /// Cambia la contraseña del usuario autenticado
  Future<Map<String, dynamic>> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'No autorizado', 'status': 401};
      }
      final response = await _dio.post(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return {'success': true, 'data': response.data};
    } on DioError catch (e) {
      return {
        'success': false,
        'error':
            e.response?.data ?? 'Ocurrió un error al cambiar la contraseña.',
      };
    }
  }

  /// Verifica la validez de un token
  Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password/validate-token',
        queryParameters: {'token': token},
      );
      return {'success': true, 'data': response.data};
    } on DioError catch (e) {
      return {
        'success': false,
        'error': e.response?.data ?? 'Ocurrió un error al validar el token.',
      };
    }
  }

  /// Obtiene la información del usuario autenticado
  Future<Map<String, dynamic>> getLoggedInUser() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'No autorizado'};
      }
      final response = await _dio.get(
        '/auth/validate-jwt',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['data'] != null &&
          response.data['data']['fullName'] != null) {
        _username = response.data['data']['fullName'];
        await _saveUsername(_username!);
      }
      return {'success': true, 'data': response.data};
    } on DioError catch (e) {
      return {
        'success': false,
        'error': e.response?.data ??
            'Ocurrió un error al obtener la información del usuario.',
      };
    }
  }

  /// Cierra sesión del usuario
  Future<void> logout() async {
    await _removeToken();
  }
}
