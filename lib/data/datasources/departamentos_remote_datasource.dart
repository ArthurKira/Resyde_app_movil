import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../domain/entities/departamento.dart';
import '../models/departamentos_response.dart';

abstract class DepartamentosRemoteDataSource {
  Future<DepartamentosResponse> getDepartamentos(String token, String schema);
}

class DepartamentosRemoteDataSourceImpl implements DepartamentosRemoteDataSource {
  final http.Client client;

  DepartamentosRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<DepartamentosResponse> getDepartamentos(String token, String schema) async {
    try {
      List<dynamic> allData = [];
      int currentPage = 1;
      int lastPage = 1;
      bool hasMorePages = true;

      // Cargar todas las páginas
      while (hasMorePages) {
        final uri = Uri.parse(ApiConstants.departamentosEndpoint).replace(
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
              'Error al obtener departamentos';
          throw Exception(errorMessage);
        }
      }

      // Construir respuesta con todos los datos
      final departamentos = allData
          .map((item) {
            final json = item as Map<String, dynamic>;
            return Departamento(
              id: json['id'] as int,
              houseNumber: json['house_number'] as String,
              features: json['features'] as String?,
              rent: json['rent'] as String?,
              status: json['status'] as String?,
              idresidencia: json['idresidencia'] as int?,
              reciboFisico: json['recibo_fisico'] as String?,
            );
          })
          .toList();

      return DepartamentosResponse(data: departamentos);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}

