class Departamento {
  final int id;
  final String houseNumber;
  final String? features;
  final String? rent;
  final String? status;
  final int? idresidencia;
  final String? reciboFisico;

  const Departamento({
    required this.id,
    required this.houseNumber,
    this.features,
    this.rent,
    this.status,
    this.idresidencia,
    this.reciboFisico,
  });
}

