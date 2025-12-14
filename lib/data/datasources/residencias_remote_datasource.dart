import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../models/residencias_response.dart';

abstract class ResidenciasRemoteDataSource {
  Future<ResidenciasResponse> getResidencias(String token);
}

class ResidenciasRemoteDataSourceImpl implements ResidenciasRemoteDataSource {
  final http.Client client;

  ResidenciasRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<ResidenciasResponse> getResidencias(String token) async {
    try {
      final response = await client.get(
        Uri.parse(ApiConstants.residenciasEndpoint),
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

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return ResidenciasResponse.fromJson(jsonResponse);
      } else {
        final errorMessage = jsonResponse['message'] as String? ??
            'Error al obtener residencias';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}

