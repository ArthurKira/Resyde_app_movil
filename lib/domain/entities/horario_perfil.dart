class HorarioPerfil {
  final String horaEntrada;
  final String horaSalida;
  final List<String> diasSemana;
  final String fechaInicio;
  final String? fechaFin;

  const HorarioPerfil({
    required this.horaEntrada,
    required this.horaSalida,
    required this.diasSemana,
    required this.fechaInicio,
    this.fechaFin,
  });
}

