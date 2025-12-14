import '../../domain/entities/residente.dart';

class ResidentesResponse {
  final List<Residente> data;
  final PaginationMeta? meta;

  ResidentesResponse({required this.data, this.meta});

  factory ResidentesResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    final residentes = dataList
        .map((item) => _ResidenteJson.fromJson(item as Map<String, dynamic>))
        .toList();

    final metaData = json['meta'] as Map<String, dynamic>?;
    final meta = metaData != null ? PaginationMeta.fromJson(metaData) : null;

    return ResidentesResponse(data: residentes, meta: meta);
  }
}

class PaginationMeta {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final String? schema;

  PaginationMeta({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    this.schema,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 15,
      total: json['total'] as int? ?? 0,
      lastPage: json['last_page'] as int? ?? 1,
      schema: json['schema'] as String?,
    );
  }
}

class _ResidenteJson {
  static Residente fromJson(Map<String, dynamic> json) {
    return Residente(
      id: json['id'] as int,
      fullname: json['fullname'] as String,
      gender: json['gender'] as String?,
      nationalId: json['national_id'] as String?,
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
      registrationDate: json['registration_date'] as String?,
      house: json['house'] as int?,
      status: json['status'] as String?,
      exitDate: json['exit_date'] as String?,
      agreementDocument: json['agreement_document'] as String?,
      estacionamiento: json['estacionamiento'] as String?,
      estacionamiento2: json['estacionamiento2'] as String?,
      estacionamiento3: json['estacionamiento3'] as String?,
      correoEnvio: json['correo_envio'] as int?,
      emailCc: json['email_cc'] as String?,
      emailCc2: json['email_cc2'] as String?,
      flagReserva: json['flag_reserva'] as String?,
    );
  }
}

