class Recibo {
  final int id;
  final int tenant;
  final int phone;
  final int house;
  final String year;
  final String month;
  final String particulars;
  final String total;
  final String? comments;
  final String status;
  final String? fechaEmision;
  final String? fechaVencimiento;
  final String? medidorImage;
  final ResidenteRecibo? residente;
  final DepartamentoRecibo? departamento;
  final String? schema;
  final String? residenciaNombre;

  const Recibo({
    required this.id,
    required this.tenant,
    required this.phone,
    required this.house,
    required this.year,
    required this.month,
    required this.particulars,
    required this.total,
    this.comments,
    required this.status,
    this.fechaEmision,
    this.fechaVencimiento,
    this.medidorImage,
    this.residente,
    this.departamento,
    this.schema,
    this.residenciaNombre,
  });
}

class ResidenteRecibo {
  final String? nombre;
  final String? telefono;
  final String? email;

  const ResidenteRecibo({
    this.nombre,
    this.telefono,
    this.email,
  });
}

class DepartamentoRecibo {
  final String? houseNumero;
  final String? nombreEdificio;

  const DepartamentoRecibo({
    this.houseNumero,
    this.nombreEdificio,
  });
}

