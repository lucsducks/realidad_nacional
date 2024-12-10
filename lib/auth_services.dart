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

  Future<void> _saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    _username = username;
    notifyListeners();
  }

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

  Future<Map<String, dynamic>> registerUser(
      Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/auth/register', data: userData);

      if (response.data != null &&
          response.data['token'] != null &&
          response.data['username'] != null &&
          response.data['userId'] != null) {
        await _saveToken(
          response.data['token'].toString(),
          response.data['username'].toString(),
          response.data['userId'].toString(),
        );

        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'error': 'La respuesta del servidor no es válida',
        };
      }
    } on DioError catch (e) {
      print('DioError en registro: ${e.toString()}');
      String errorMessage = 'Ocurrió un error al registrar el usuario';

      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          // Si la respuesta es un mapa, intentamos obtener el mensaje de error
          errorMessage = e.response!.data['message']?.toString() ??
              e.response!.data['error']?.toString() ??
              errorMessage;
        } else if (e.response!.data is String) {
          // Si la respuesta es una cadena, la usamos directamente
          errorMessage = e.response!.data.toString();
        }
      }

      // Manejo de errores específicos comunes
      if (e.type == DioErrorType.connectionTimeout) {
        errorMessage =
            'Tiempo de espera agotado. Por favor, verifica tu conexión';
      } else if (e.type == DioErrorType.badResponse) {
        if (e.response?.statusCode == 409) {
          errorMessage = 'El correo electrónico ya está registrado';
        } else if (e.response?.statusCode == 400) {
          errorMessage = 'Datos de registro inválidos';
        }
      }

      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      print('Error general en registro: ${e.toString()}');
      return {
        'success': false,
        'error': 'Ocurrió un error inesperado durante el registro',
      };
    }
  }

  Future<Map<String, dynamic>> loginUser(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/auth/login', data: userData);

      if (response.data != null &&
          response.data['token'] != null &&
          response.data['username'] != null &&
          response.data['userId'] != null) {
        await _saveToken(
          response.data['token'].toString(),
          response.data['username'].toString(),
          response.data['userId'].toString(),
        );

        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'error': 'La respuesta del servidor no es válida',
        };
      }
    } on DioError catch (e) {
      String errorMessage = 'Ocurrió un error al iniciar sesión';

      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['message']?.toString() ??
              e.response!.data['error']?.toString() ??
              errorMessage;
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data.toString();
        }
      }

      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Ocurrió un error inesperado',
      };
    }
  }

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
