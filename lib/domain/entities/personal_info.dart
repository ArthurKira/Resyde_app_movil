class PersonalInfo {
  final int idPersonal;
  final String nombres;
  final String apellidos;
  final String dniCe;
  final String estado;

  const PersonalInfo({
    required this.idPersonal,
    required this.nombres,
    required this.apellidos,
    required this.dniCe,
    required this.estado,
  });

  String get nombreCompleto => '$nombres $apellidos';
}

