import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../domain/entities/residente.dart';
import '../models/residentes_response.dart';

abstract class ResidentesRemoteDataSource {
  Future<ResidentesResponse> getResidentes(String token, String schema);
}

class ResidentesRemoteDataSourceImpl implements ResidentesRemoteDataSource {
  final http.Client client;

  ResidentesRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<ResidentesResponse> getResidentes(String token, String schema) async {
    try {
      List<dynamic> allData = [];
      int currentPage = 1;
      int lastPage = 1;
      bool hasMorePages = true;

      // Cargar todas las páginas
      while (hasMorePages) {
        final uri = Uri.parse(ApiConstants.residentesEndpoint).replace(
          queryParameters: {
            'schema': schema,
            'page': currentPage.toString(),
            'per_page': '100', // Cargar más items por página para ser más eficiente
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

        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

        if (response.statusCode == 200) {
          final pageData = jsonResponse['data'] as List<dynamic>? ?? [];
          allData.addAll(pageData);

          // Obtener información de paginación
          final metaData = jsonResponse['meta'] as Map<String, dynamic>?;
          if (metaData != null) {
            lastPage = metaData['last_page'] as int? ?? 1;
            // Verificar si hay más páginas
            hasMorePages = currentPage < lastPage;
            currentPage++;
          } else {
            // Si no hay meta, asumimos que solo hay una página
            hasMorePages = false;
          }
        } else {
          final errorMessage = jsonResponse['message'] as String? ??
              'Error al obtener residentes';
          throw Exception(errorMessage);
        }
      }

      // Construir respuesta con todos los datos usando el método de parseo del modelo
      final residentes = allData
          .map((item) {
            final json = item as Map<String, dynamic>;
            
            // Función helper para convertir valores a String? de forma segura
            String? _toStringOrNull(dynamic value) {
              if (value == null) return null;
              if (value is String) return value.isEmpty ? null : value;
              return value.toString();
            }
            
            return Residente(
              id: json['id'] as int,
              fullname: json['fullname'] as String,
              gender: _toStringOrNull(json['gender']),
              nationalId: _toStringOrNull(json['national_id']),
              phoneNumber: _toStringOrNull(json['phone_number']),
              email: _toStringOrNull(json['email']),
              registrationDate: _toStringOrNull(json['registration_date']),
              house: json['house'] as int?,
              status: _toStringOrNull(json['status']),
              exitDate: _toStringOrNull(json['exit_date']),
              agreementDocument: _toStringOrNull(json['agreement_document']),
              estacionamiento: _toStringOrNull(json['estacionamiento']),
              estacionamiento2: _toStringOrNull(json['estacionamiento2']),
              estacionamiento3: _toStringOrNull(json['estacionamiento3']),
              correoEnvio: json['correo_envio'] as int?,
              emailCc: _toStringOrNull(json['email_cc']),
              emailCc2: _toStringOrNull(json['email_cc2']),
              flagReserva: _toStringOrNull(json['flag_reserva']),
            );
          })
          .toList();

      return ResidentesResponse(data: residentes);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}

