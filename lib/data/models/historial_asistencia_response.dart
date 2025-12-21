import '../../domain/entities/historial_asistencia.dart';
import '../../domain/entities/registro_asistencia.dart';

class HistorialAsistenciaResponse {
  final bool success;
  final int total;
  final List<Map<String, dynamic>> historial;

  HistorialAsistenciaResponse({
    required this.success,
    required this.total,
    required this.historial,
  });

  factory HistorialAsistenciaResponse.fromJson(Map<String, dynamic> json) {
    return HistorialAsistenciaResponse(
      success: json['success'] as bool? ?? false,
      total: json['total'] as int? ?? 0,
      historial: (json['historial'] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }

  HistorialAsistencia toHistorialAsistencia() {
    return HistorialAsistencia(
      success: success,
      total: total,
      historial: historial.map((item) => _parseRegistro(item)).toList(),
    );
  }

  RegistroAsistencia _parseRegistro(Map<String, dynamic> json) {
    return RegistroAsistencia(
      idRegistro: json['id_registro'] as int? ?? 0,
      fechaEntrada: json['fecha_entrada'] as String? ?? '',
      horaEntrada: json['hora_entrada'] as String? ?? '',
      latitudEntrada: json['latitud_entrada']?.toString(),
      longitudEntrada: json['longitud_entrada']?.toString(),
      fechaSalida: json['fecha_salida'] as String?,
      horaSalida: json['hora_salida'] as String?,
      latitudSalida: json['latitud_salida']?.toString(),
      longitudSalida: json['longitud_salida']?.toString(),
      estado: json['estado'] as String? ?? '',
      observaciones: json['observaciones'] as String?,
    );
  }
}

