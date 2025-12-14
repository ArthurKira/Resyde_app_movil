import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../core/constants/api_constants.dart';

abstract class MedidorRemoteDataSource {
  Future<void> uploadMedidorImage({
    required String token,
    required int reciboId,
    required String schema,
    required File imagen,
    required String lecturaActual,
  });
}

class MedidorRemoteDataSourceImpl implements MedidorRemoteDataSource {
  final http.Client client;

  MedidorRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<void> uploadMedidorImage({
    required String token,
    required int reciboId,
    required String schema,
    required File imagen,
    required String lecturaActual,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/recibos/$reciboId/medidor').replace(
        queryParameters: {'schema': schema},
      );

      // Crear la petición multipart
      final request = http.MultipartRequest('POST', uri);
      
      // Agregar headers
      request.headers['Authorization'] = 'Bearer $token';
      
      // Agregar la imagen
      final imageFile = await http.MultipartFile.fromPath(
        'imagen',
        imagen.path,
        filename: imagen.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(imageFile);
      
      // Agregar la lectura actual
      request.fields['lectura_actual'] = lecturaActual;

      final streamedResponse = await client.send(request).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return; // Éxito
      } else {
        // Intentar parsear el error si es JSON
        String errorMessage = 'Error al subir imagen del medidor';
        try {
          final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
          // Intentar obtener el mensaje de error de diferentes campos posibles
          errorMessage = jsonResponse['message'] as String? ?? 
                        jsonResponse['error'] as String? ??
                        jsonResponse['errors']?.toString() ??
                        errorMessage;
          
          // Si el mensaje contiene información sobre la base de datos, simplificarlo
          if (errorMessage.contains('SQLSTATE') || errorMessage.contains('Column not found')) {
            errorMessage = 'Error en el servidor: Problema con la base de datos. Por favor contacta al administrador.';
          }
        } catch (e) {
          // Si no es JSON, usar el body directamente o un mensaje genérico
          if (response.body.isNotEmpty) {
            String bodyText = response.body;
            // Simplificar mensajes de error de base de datos
            if (bodyText.contains('SQLSTATE') || bodyText.contains('Column not found')) {
              errorMessage = 'Error en el servidor: Problema con la base de datos. Por favor contacta al administrador.';
            } else {
              errorMessage = bodyText;
            }
          }
        }
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

