class RegistroAsistencia {
  final int idRegistro;
  final String fechaEntrada;
  final String horaEntrada;
  final String? latitudEntrada;
  final String? longitudEntrada;
  final String? fechaSalida;
  final String? horaSalida;
  final String? latitudSalida;
  final String? longitudSalida;
  final String estado;
  final String? observaciones;

  const RegistroAsistencia({
    required this.idRegistro,
    required this.fechaEntrada,
    required this.horaEntrada,
    this.latitudEntrada,
    this.longitudEntrada,
    this.fechaSalida,
    this.horaSalida,
    this.latitudSalida,
    this.longitudSalida,
    required this.estado,
    this.observaciones,
  });
}

