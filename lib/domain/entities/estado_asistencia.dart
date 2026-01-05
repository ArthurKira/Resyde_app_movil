import 'registro_asistencia.dart';
import 'horario_turno.dart';

class EstadoAsistencia {
  final bool success;
  final String fecha;
  final bool tieneEntrada;
  final bool tieneSalida;
  final bool puedeMarcarEntrada;
  final bool puedeMarcarSalida;
  final bool tieneHorario;
  final bool enVacaciones;
  final bool enLicencia;
  final RegistroAsistencia? registro;
  final String? mensaje;
  final HorarioTurno? horarioRegistro;
  final HorarioTurno? horarioHoy;

  const EstadoAsistencia({
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
}

