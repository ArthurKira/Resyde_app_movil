class UserPersonal {
  final int idPersonal;
  final String nombres;
  final String apellidos;
  final String? dniCe;
  final String? estado;

  const UserPersonal({
    required this.idPersonal,
    required this.nombres,
    required this.apellidos,
    this.dniCe,
    this.estado,
  });
}

class PersonalResidencia {
  final int id;
  final int idResidencia;
  final String? cargo;
  final bool activo;

  const PersonalResidencia({
    required this.id,
    required this.idResidencia,
    this.cargo,
    required this.activo,
  });
}

class HorarioActual {
  final String horaEntrada;
  final String horaSalida;
  final String diasSemana;

  const HorarioActual({
    required this.horaEntrada,
    required this.horaSalida,
    required this.diasSemana,
  });
}

