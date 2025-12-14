class Residencia {
  final int idResidencia;
  final String nombre;
  final String schemaRelacionado;
  final String? telefono;
  final String? email;
  final String? fechaCreacion;
  final int? usuarioCreacion;
  final String? fechaModificacion;
  final int? usuarioModificacion;
  final int usersCount;

  const Residencia({
    required this.idResidencia,
    required this.nombre,
    required this.schemaRelacionado,
    this.telefono,
    this.email,
    this.fechaCreacion,
    this.usuarioCreacion,
    this.fechaModificacion,
    this.usuarioModificacion,
    required this.usersCount,
  });
}

