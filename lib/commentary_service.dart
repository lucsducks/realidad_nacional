// lib/services/commentary_service.dart

import 'package:dio/dio.dart';
import 'package:realidadnacional/auth_services.dart';
import 'package:realidadnacional/topics.dart';

class CommentaryService {
  final Dio _dio;
  final AuthService _authService;

  CommentaryService(this._authService)
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://sv-te6t3kuxcj.cloud.elastika.pe/realidad',
          contentType: 'application/json',
        ));

  /// Obtiene los comentarios por tema con paginación.
  Future<Map<String, dynamic>> getCommentariesByTopic(
      Topics topic, int offset) async {
    try {
      final response = await _dio.get(
        '/commentaries/${topic.value}',
        queryParameters: {'limit': 10, 'offset': offset},
      );
      return {'success': true, 'data': response.data};
    } on DioError catch (e) {
      return {
        'success': false,
        'error':
            e.response?.data ?? 'Ocurrió un error al obtener los comentarios.',
      };
    }
  }

  /// Vota un comentario (up o down).
  Future<Map<String, dynamic>> voteCommentary(
      int commentaryId, VoteType vote) async {
    final token = await _authService.getToken();
    if (token == null) {
      return {
        'success': false,
        'error': 'No autorizado',
        'status': 401,
      };
    }
    try {
      final response = await _dio.patch(
        '/commentaries/$commentaryId/vote/${vote.value}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      // Aquí puedes manejar la revalidación de datos si usas alguna librería de caching
      return {'success': true, 'data': response.data};
    } on DioError catch (e) {
      return {
        'success': false,
        'error': e.response?.data ?? 'Ocurrió un error al votar el comentario.',
      };
    }
  }

  /// Publica un nuevo comentario.
  Future<Map<String, dynamic>> postCommentary(
      String content, Topics topic) async {
    final token = await _authService.getToken();
    if (token == null) {
      return {
        'success': false,
        'error': 'No autorizado',
        'status': 401,
      };
    }
    try {
      final response = await _dio.post(
        '/commentaries',
        data: {'content': content, 'topic': topic.value},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      return {'success': true, 'data': response.data};
    } on DioError catch (e) {
      return {
        'success': false,
        'error':
            e.response?.data ?? 'Ocurrió un error al publicar el comentario.',
      };
    }
  }

  /// Elimina un comentario.
  Future<Map<String, dynamic>> deleteCommentary(int commentaryId) async {
    final token = await _authService.getToken();
    if (token == null) {
      return {
        'success': false,
        'error': 'No autorizado',
        'status': 401,
      };
    }
    try {
      final response = await _dio.delete(
        '/commentaries/$commentaryId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return {'success': true, 'data': response.data};
    } on DioError catch (e) {
      return {
        'success': false,
        'error':
            e.response?.data ?? 'Ocurrió un error al eliminar el comentario.',
      };
    }
  }

  /// Edita un comentario existente.
  Future<Map<String, dynamic>> editCommentary(
      int commentaryId, String content) async {
    final token = await _authService.getToken();
    if (token == null) {
      return {
        'success': false,
        'error': 'No autorizado',
        'status': 401,
      };
    }
    try {
      final response = await _dio.patch(
        '/commentaries/$commentaryId',
        data: {'content': content},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      return {'success': true, 'data': response.data};
    } on DioError catch (e) {
      return {
        'success': false,
        'error':
            e.response?.data ?? 'Ocurrió un error al editar el comentario.',
      };
    }
  }
}

/// Enumerado para el tipo de voto.
enum VoteType {
  up,
  down,
}

extension VoteTypeExtension on VoteType {
  String get value {
    switch (this) {
      case VoteType.up:
        return 'up';
      case VoteType.down:
        return 'down';
    }
  }
}
