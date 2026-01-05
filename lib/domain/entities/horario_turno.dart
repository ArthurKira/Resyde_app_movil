class HorarioTurno {
  final String fechaEntrada;
  final String horaEntrada;
  final String fechaSalida;
  final String horaSalida;
  final List<String> diasSemana;
  final String? fechaInicio;
  final String? fechaFin;

  const HorarioTurno({
    required this.fechaEntrada,
    required this.horaEntrada,
    required this.fechaSalida,
    required this.horaSalida,
    required this.diasSemana,
    this.fechaInicio,
    this.fechaFin,
  });

  // Helper para verificar si es un turno nocturno
  bool get esTurnoNocturno {
    try {
      // Si la fecha de entrada es diferente a la fecha de salida, es turno nocturno
      return fechaEntrada != fechaSalida;
    } catch (e) {
      return false;
    }
  }
}

