import '../../domain/entities/recibo.dart';

class RecibosResponse {
  final List<Recibo> data;
  final RecibosMetaData? meta;

  RecibosResponse({
    required this.data,
    this.meta,
  });

  factory RecibosResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    final recibos = dataList
        .map((item) => _ReciboJson.fromJson(item as Map<String, dynamic>))
        .toList();

    final metaData = json['meta'] as Map<String, dynamic>?;

    return RecibosResponse(
      data: recibos,
      meta: metaData != null ? RecibosMetaData.fromJson(metaData) : null,
    );
  }
}

class RecibosMetaData {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  RecibosMetaData({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory RecibosMetaData.fromJson(Map<String, dynamic> json) {
    return RecibosMetaData(
      currentPage: json['current_page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
      lastPage: json['last_page'] as int,
    );
  }
}

class _ReciboJson {
  static Recibo fromJson(Map<String, dynamic> json) {
    final residenteData = json['residente'] as Map<String, dynamic>?;
    final departamentoData = json['departamento'] as Map<String, dynamic>?;

    return Recibo(
      id: json['id'] as int,
      tenant: json['tenant'] as int,
      phone: json['phone'] as int,
      house: json['house'] as int,
      year: json['year'] as String,
      month: json['month'] as String,
      particulars: json['particulars'] as String? ?? '',
      total: json['total'] as String,
      comments: json['comments'] as String?,
      status: json['status'] as String,
      fechaEmision: json['fecha_emision'] as String?,
      fechaVencimiento: json['fecha_vencimiento'] as String?,
      medidorImage: json['medidor_image'] as String?,
      residente: residenteData != null
          ? ResidenteRecibo(
              nombre: residenteData['nombre'] as String?,
              telefono: residenteData['telefono'] as String?,
              email: residenteData['email'] as String?,
            )
          : null,
      departamento: departamentoData != null
          ? DepartamentoRecibo(
              houseNumero: departamentoData['house_numero'] as String?,
              nombreEdificio: departamentoData['nombre_edificio'] as String?,
            )
          : null,
      schema: json['schema'] as String?,
      residenciaNombre: json['residencia_nombre'] as String?,
    );
  }
}

