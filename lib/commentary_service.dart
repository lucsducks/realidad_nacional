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

  Map<String, dynamic> _handleDioError(DioError e, String defaultMessage) {
    print('DioError: ${e.toString()}');
    String errorMessage = defaultMessage;

    if (e.response?.data != null) {
      if (e.response!.data is Map) {
        errorMessage = e.response!.data['message']?.toString() ??
            e.response!.data['error']?.toString() ??
            defaultMessage;
      } else if (e.response!.data is String) {
        errorMessage = e.response!.data.toString();
      }
    }

    // Manejo específico según el tipo de error
    if (e.type == DioErrorType.connectionTimeout ||
        e.type == DioErrorType.receiveTimeout ||
        e.type == DioErrorType.sendTimeout) {
      errorMessage =
          'Tiempo de espera agotado. Por favor, verifica tu conexión';
    } else if (e.type == DioErrorType.badResponse) {
      switch (e.response?.statusCode) {
        case 400:
          errorMessage =
              'No autorizado. Por favor, verifique primero su correo electrónico, revise su bandeja de entrada y haga clic en el enlace de verificación';
          break;
        case 401:
          errorMessage = 'No autorizado. Por favor, inicia sesión nuevamente';
          break;
        case 403:
          errorMessage = 'No tienes permisos para realizar esta acción';
          break;
        case 404:
          errorMessage = 'El recurso solicitado no existe';
          break;
        case 429:
          errorMessage = 'Demasiadas solicitudes. Por favor, intenta más tarde';
          break;
        case 500:
          errorMessage = 'Error en el servidor. Por favor, intenta más tarde';
          break;
      }
    }

    return {
      'success': false,
      'error': errorMessage,
      'status': e.response?.statusCode,
    };
  }

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
      return _handleDioError(e, 'Ocurrió un error al obtener los comentarios.');
    } catch (e) {
      print('Error general: ${e.toString()}');
      return {
        'success': false,
        'error': 'Error inesperado al obtener los comentarios',
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
        'error': 'Debes iniciar sesión para votar',
        'status': 401,
      };
    }
    try {
      final response = await _dio.patch(
        '/commentaries/$commentaryId/vote/${vote.value}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return {'success': true, 'data': response.data};
    } on DioError catch (e) {
      return _handleDioError(e, 'Ocurrió un error al votar el comentario.');
    } catch (e) {
      print('Error general: ${e.toString()}');
      return {
        'success': false,
        'error': 'Error inesperado al votar el comentario',
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
        'error': 'Debes iniciar sesión para publicar un comentario',
        'status': 401,
      };
    }
    try {
      if (content.trim().isEmpty) {
        return {
          'success': false,
          'error': 'El comentario no puede estar vacío',
        };
      }

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
      return _handleDioError(e, 'Ocurrió un error al publicar el comentario.');
    } catch (e) {
      print('Error general: ${e.toString()}');
      return {
        'success': false,
        'error': 'Error inesperado al publicar el comentario',
      };
    }
  }

  /// Elimina un comentario.
  Future<Map<String, dynamic>> deleteCommentary(int commentaryId) async {
    final token = await _authService.getToken();
    if (token == null) {
      return {
        'success': false,
        'error': 'Debes iniciar sesión para eliminar el comentario',
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
      return _handleDioError(e, 'Ocurrió un error al eliminar el comentario.');
    } catch (e) {
      print('Error general: ${e.toString()}');
      return {
        'success': false,
        'error': 'Error inesperado al eliminar el comentario',
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
        'error': 'Debes iniciar sesión para editar el comentario',
        'status': 401,
      };
    }
    try {
      if (content.trim().isEmpty) {
        return {
          'success': false,
          'error': 'El comentario no puede estar vacío',
        };
      }

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
      return _handleDioError(e, 'Ocurrió un error al editar el comentario.');
    } catch (e) {
      print('Error general: ${e.toString()}');
      return {
        'success': false,
        'error': 'Error inesperado al editar el comentario',
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
