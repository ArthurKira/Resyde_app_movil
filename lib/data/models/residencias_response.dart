import '../../domain/entities/residencia.dart';

class ResidenciasResponse {
  final List<Residencia> data;

  ResidenciasResponse({required this.data});

  factory ResidenciasResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    final residencias = dataList
        .map((item) => _ResidenciaJson.fromJson(item as Map<String, dynamic>))
        .toList();

    return ResidenciasResponse(data: residencias);
  }
}

class _ResidenciaJson {
  static Residencia fromJson(Map<String, dynamic> json) {
    return Residencia(
      idResidencia: json['id_residencia'] as int,
      nombre: json['nombre'] as String,
      schemaRelacionado: json['schema_relacionado'] as String,
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      fechaCreacion: json['fecha_creacion'] as String?,
      usuarioCreacion: json['usuario_creacion'] as int?,
      fechaModificacion: json['fecha_modificacion'] as String?,
      usuarioModificacion: json['usuario_modificacion'] as int?,
      usersCount: json['users_count'] as int? ?? 0,
    );
  }
}

