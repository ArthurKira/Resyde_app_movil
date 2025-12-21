import '../../domain/entities/registro_asistencia.dart';

class MarcarEntradaResponse {
  final bool success;
  final String message;
  final Map<String, dynamic> registro;

  MarcarEntradaResponse({
    required this.success,
    required this.message,
    required this.registro,
  });

  factory MarcarEntradaResponse.fromJson(Map<String, dynamic> json) {
    return MarcarEntradaResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      registro: json['registro'] as Map<String, dynamic>? ?? {},
    );
  }

  RegistroAsistencia toRegistroAsistencia() {
    return RegistroAsistencia(
      idRegistro: registro['id_registro'] as int? ?? 0,
      fechaEntrada: registro['fecha_entrada'] as String? ?? '',
      horaEntrada: registro['hora_entrada'] as String? ?? '',
      latitudEntrada: registro['latitud_entrada']?.toString(),
      longitudEntrada: registro['longitud_entrada']?.toString(),
      fechaSalida: registro['fecha_salida'] as String?,
      horaSalida: registro['hora_salida'] as String?,
      latitudSalida: registro['latitud_salida']?.toString(),
      longitudSalida: registro['longitud_salida']?.toString(),
      estado: registro['estado'] as String? ?? '',
      observaciones: registro['observaciones'] as String?,
    );
  }
}

