import '../../domain/entities/estado_asistencia.dart';
import '../../domain/entities/registro_asistencia.dart';
import '../../domain/entities/horario_turno.dart';
import '../../domain/entities/personal_residencia.dart';
import '../../domain/entities/residencia_info.dart';

class EstadoAsistenciaResponse {
  final bool success;
  final String fecha;
  final bool tieneEntrada;
  final bool tieneSalida;
  final bool puedeMarcarEntrada;
  final bool puedeMarcarSalida;
  final bool tieneHorario;
  final bool enVacaciones;
  final bool enLicencia;
  final Map<String, dynamic>? registro;
  final String? mensaje;
  final Map<String, dynamic>? horarioRegistro;
  final Map<String, dynamic>? horarioHoy;

  EstadoAsistenciaResponse({
    required this.success,
    required this.fecha,
    required this.tieneEntrada,
    required this.tieneSalida,
    required this.puedeMarcarEntrada,
    required this.puedeMarcarSalida,
    required this.tieneHorario,
    required this.enVacaciones,
    required this.enLicencia,
    this.registro,
    this.mensaje,
    this.horarioRegistro,
    this.horarioHoy,
  });

  factory EstadoAsistenciaResponse.fromJson(Map<String, dynamic> json) {
    return EstadoAsistenciaResponse(
      success: json['success'] as bool? ?? false,
      fecha: json['fecha'] as String? ?? '',
      tieneEntrada: json['tiene_entrada'] as bool? ?? false,
      tieneSalida: json['tiene_salida'] as bool? ?? false,
      puedeMarcarEntrada: json['puede_marcar_entrada'] as bool? ?? false,
      puedeMarcarSalida: json['puede_marcar_salida'] as bool? ?? false,
      tieneHorario: json['tiene_horario'] as bool? ?? false,
      enVacaciones: json['en_vacaciones'] as bool? ?? false,
      enLicencia: json['en_licencia'] as bool? ?? false,
      registro: json['registro'] as Map<String, dynamic>?,
      mensaje: json['mensaje'] as String?,
      horarioRegistro: json['horario_registro'] as Map<String, dynamic>?,
      horarioHoy: json['horario_hoy'] as Map<String, dynamic>?,
    );
  }

  EstadoAsistencia toEstadoAsistencia() {
    return EstadoAsistencia(
      success: success,
      fecha: fecha,
      tieneEntrada: tieneEntrada,
      tieneSalida: tieneSalida,
      puedeMarcarEntrada: puedeMarcarEntrada,
      puedeMarcarSalida: puedeMarcarSalida,
      tieneHorario: tieneHorario,
      enVacaciones: enVacaciones,
      enLicencia: enLicencia,
      registro: registro != null ? _parseRegistro(registro!) : null,
      mensaje: mensaje,
      horarioRegistro: horarioRegistro != null ? _parseHorarioTurno(horarioRegistro!) : null,
      horarioHoy: horarioHoy != null ? _parseHorarioTurno(horarioHoy!) : null,
    );
  }

  RegistroAsistencia? _parseRegistro(Map<String, dynamic> json) {
    try {
      return RegistroAsistencia(
        idRegistro: json['id_registro'] as int? ?? 0,
        fechaEntrada: json['fecha_entrada'] as String? ?? '',
        horaEntrada: json['hora_entrada'] as String? ?? '',
        latitudEntrada: json['latitud_entrada'] as String?,
        longitudEntrada: json['longitud_entrada'] as String?,
        fechaSalida: json['fecha_salida'] as String?,
        horaSalida: json['hora_salida'] as String?,
        latitudSalida: json['latitud_salida'] as String?,
        longitudSalida: json['longitud_salida'] as String?,
        estado: json['estado'] as String? ?? '',
        observaciones: json['observaciones'] as String?,
      );
    } catch (e) {
      return null;
    }
  }

  HorarioTurno? _parseHorarioTurno(Map<String, dynamic> json) {
    try {
      // Parsear personal_residencia si existe
      PersonalResidencia? personalResidencia;
      if (json['personal_residencia'] != null) {
        final prJson = json['personal_residencia'] as Map<String, dynamic>;
        personalResidencia = PersonalResidencia(
          id: prJson['id'] as int? ?? 0,
          cargo: prJson['cargo'] as String? ?? '',
        );
      }

      // Parsear residencia si existe
      ResidenciaInfo? residencia;
      if (json['residencia'] != null) {
        final resJson = json['residencia'] as Map<String, dynamic>;
        residencia = ResidenciaInfo(
          idResidencia: resJson['id_residencia'] as int? ?? 0,
          nombre: resJson['nombre'] as String? ?? '',
        );
      }

      return HorarioTurno(
        fechaEntrada: json['fecha_entrada'] as String? ?? '',
        horaEntrada: json['hora_entrada'] as String? ?? '',
        fechaSalida: json['fecha_salida'] as String? ?? '',
        horaSalida: json['hora_salida'] as String? ?? '',
        diasSemana: (json['dias_semana'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? [],
        fechaInicio: json['fecha_inicio'] as String?,
        fechaFin: json['fecha_fin'] as String?,
        personalResidencia: personalResidencia,
        residencia: residencia,
      );
    } catch (e) {
      return null;
    }
  }
}

