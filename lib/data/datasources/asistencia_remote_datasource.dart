import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/estado_asistencia_response.dart';
import '../models/marcar_entrada_response.dart';
import '../models/marcar_salida_response.dart';
import '../models/historial_asistencia_response.dart';

abstract class AsistenciaRemoteDataSource {
  Future<EstadoAsistenciaResponse> getEstadoAsistencia(String token);
  Future<MarcarEntradaResponse> marcarEntrada(
    String token,
    double latitud,
    double longitud,
  );
  Future<MarcarSalidaResponse> marcarSalida(
    String token,
    double latitud,
    double longitud,
  );
  Future<HistorialAsistenciaResponse> getHistorialAsistencia(
    String token, {
    int? limite,
    String? desde,
    String? hasta,
  });
}

class AsistenciaRemoteDataSourceImpl implements AsistenciaRemoteDataSource {
  final http.Client client;

  AsistenciaRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<EstadoAsistenciaResponse> getEstadoAsistencia(String token) async {
    try {
      final response = await client.get(
        Uri.parse(ApiConstants.asistenciaEstadoEndpoint),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Accept': ApiConstants.accept,
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );

      if (response.statusCode != 200) {
        String errorMessage = 'Error al obtener estado de asistencia';
        try {
          final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = jsonResponse['message'] as String? ??
              jsonResponse['error'] as String? ??
              errorMessage;
        } catch (e) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }
        throw Exception(errorMessage);
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      return EstadoAsistenciaResponse.fromJson(jsonResponse);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<MarcarEntradaResponse> marcarEntrada(
    String token,
    double latitud,
    double longitud,
  ) async {
    try {
      final response = await client.post(
        Uri.parse(ApiConstants.asistenciaMarcarEntradaEndpoint),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Accept': ApiConstants.accept,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'latitud': latitud,
          'longitud': longitud,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        String errorMessage = 'Error al marcar entrada';
        try {
          final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = jsonResponse['message'] as String? ??
              jsonResponse['error'] as String? ??
              errorMessage;
        } catch (e) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }
        throw Exception(errorMessage);
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      return MarcarEntradaResponse.fromJson(jsonResponse);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<MarcarSalidaResponse> marcarSalida(
    String token,
    double latitud,
    double longitud,
  ) async {
    try {
      final response = await client.post(
        Uri.parse(ApiConstants.asistenciaMarcarSalidaEndpoint),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Accept': ApiConstants.accept,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'latitud': latitud,
          'longitud': longitud,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );

      if (response.statusCode != 200) {
        String errorMessage = 'Error al marcar salida';
        try {
          final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = jsonResponse['message'] as String? ??
              jsonResponse['error'] as String? ??
              errorMessage;
        } catch (e) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }
        throw Exception(errorMessage);
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      return MarcarSalidaResponse.fromJson(jsonResponse);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<HistorialAsistenciaResponse> getHistorialAsistencia(
    String token, {
    int? limite,
    String? desde,
    String? hasta,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (limite != null) queryParams['limite'] = limite.toString();
      if (desde != null) queryParams['desde'] = desde;
      if (hasta != null) queryParams['hasta'] = hasta;

      final uri = Uri.parse(ApiConstants.asistenciaHistorialEndpoint)
          .replace(queryParameters: queryParams);

      final response = await client.get(
        uri,
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Accept': ApiConstants.accept,
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );

      if (response.statusCode != 200) {
        String errorMessage = 'Error al obtener historial de asistencia';
        try {
          final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = jsonResponse['message'] as String? ??
              jsonResponse['error'] as String? ??
              errorMessage;
        } catch (e) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }
        throw Exception(errorMessage);
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      return HistorialAsistenciaResponse.fromJson(jsonResponse);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}

