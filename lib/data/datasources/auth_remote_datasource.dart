import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await client.post(
        Uri.parse(ApiConstants.loginEndpoint),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Accept': ApiConstants.accept,
        },
        body: jsonEncode(request.toJson()),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );

      // Verificar el status code primero
      if (response.statusCode != 200 && response.statusCode != 201) {
        String errorMessage = 'Error al iniciar sesión';
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

      // Parsear la respuesta exitosa
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      // Verificar si el backend indica error aunque el status code sea 200
      final status = jsonResponse['status'] as String?;
      if (status != null && status != 'success') {
        final errorMessage = jsonResponse['message'] as String? ??
            jsonResponse['error'] as String? ??
            'Error al iniciar sesión';
        throw Exception(errorMessage);
      }
      
      return LoginResponse.fromJson(jsonResponse);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}

