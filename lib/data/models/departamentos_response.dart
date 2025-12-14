import '../../domain/entities/departamento.dart';
import 'residentes_response.dart';

class DepartamentosResponse {
  final List<Departamento> data;
  final PaginationMeta? meta;

  DepartamentosResponse({required this.data, this.meta});

  factory DepartamentosResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    final departamentos = dataList
        .map((item) => _DepartamentoJson.fromJson(item as Map<String, dynamic>))
        .toList();

    final metaData = json['meta'] as Map<String, dynamic>?;
    final meta = metaData != null ? PaginationMeta.fromJson(metaData) : null;

    return DepartamentosResponse(data: departamentos, meta: meta);
  }
}

class _DepartamentoJson {
  static Departamento fromJson(Map<String, dynamic> json) {
    return Departamento(
      id: json['id'] as int,
      houseNumber: json['house_number'] as String,
      features: json['features'] as String?,
      rent: json['rent'] as String?,
      status: json['status'] as String?,
      idresidencia: json['idresidencia'] as int?,
      reciboFisico: json['recibo_fisico'] as String?,
    );
  }
}

