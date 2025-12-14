import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/recibos_response.dart';

abstract class RecibosRemoteDataSource {
  Future<RecibosResponse> getRecibos({
    required String token,
    required String schema,
    String? year,
    String? month,
    int? tenant,
    int? house,
    String? status,
    int? page,
    int? perPage,
  });
}

class RecibosRemoteDataSourceImpl implements RecibosRemoteDataSource {
  final http.Client client;

  RecibosRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<RecibosResponse> getRecibos({
    required String token,
    required String schema,
    String? year,
    String? month,
    int? tenant,
    int? house,
    String? status,
    int? page,
    int? perPage,
  }) async {
    try {
      // Construir la URL con los parámetros de consulta
      final uri = Uri.parse(ApiConstants.recibosEndpoint).replace(
        queryParameters: {
          'schema': schema,
          if (year != null) 'year': year,
          if (month != null) 'month': month,
          if (tenant != null) 'tenant': tenant.toString(),
          if (house != null) 'house': house.toString(),
          if (status != null) 'status': status,
          if (page != null) 'page': page.toString(),
          if (perPage != null) 'per_page': perPage.toString(),
        },
      );

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

      // Verificar si la respuesta es exitosa
      if (response.statusCode != 200) {
        String errorMessage = 'Error al obtener recibos';
        try {
          final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = jsonResponse['message'] as String? ??
              jsonResponse['error'] as String? ??
              jsonResponse['errors']?.toString() ??
              errorMessage;
        } catch (e) {
          // Si no se puede parsear el JSON, usar el body directamente
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }
        throw Exception(errorMessage);
      }

      // Intentar parsear la respuesta
      try {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Verificar si hay un error en el JSON (aunque el status sea 200)
        if (jsonResponse.containsKey('error') || jsonResponse.containsKey('errors')) {
          final errorMessage = jsonResponse['error'] as String? ??
              jsonResponse['errors']?.toString() ??
              jsonResponse['message'] as String? ??
              'Error al obtener recibos';
          throw Exception(errorMessage);
        }
        
        return RecibosResponse.fromJson(jsonResponse);
      } catch (e) {
        // Si hay un error al parsear, verificar si es un error del backend
        if (e is Exception && e.toString().contains('Undefined property')) {
          throw Exception('Error en el servidor: ${e.toString().replaceFirst('Exception: ', '')}');
        }
        // Si es otro tipo de error de parsing, relanzarlo
        if (e is Exception) {
          rethrow;
        }
        throw Exception('Error al procesar la respuesta del servidor: ${e.toString()}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}

