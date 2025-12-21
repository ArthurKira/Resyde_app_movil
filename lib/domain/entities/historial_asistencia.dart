import 'registro_asistencia.dart';

class HistorialAsistencia {
  final bool success;
  final int total;
  final List<RegistroAsistencia> historial;

  const HistorialAsistencia({
    required this.success,
    required this.total,
    required this.historial,
  });
}

