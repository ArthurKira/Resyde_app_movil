import 'horario_perfil.dart';

class ResidenciaAsignada {
  final int idPersonalResidencia;
  final String cargo;
  final int idResidencia;
  final String nombreResidencia;
  final bool tieneHorarioHoy;
  final HorarioPerfil? horarioHoy;

  const ResidenciaAsignada({
    required this.idPersonalResidencia,
    required this.cargo,
    required this.idResidencia,
    required this.nombreResidencia,
    required this.tieneHorarioHoy,
    this.horarioHoy,
  });
}

