class Residente {
  final int id;
  final String fullname;
  final String? gender;
  final String? nationalId;
  final String? phoneNumber;
  final String? email;
  final String? registrationDate;
  final int? house;
  final String? status;
  final String? exitDate;
  final String? agreementDocument;
  final String? estacionamiento;
  final String? estacionamiento2;
  final String? estacionamiento3;
  final int? correoEnvio;
  final String? emailCc;
  final String? emailCc2;
  final String? flagReserva;

  const Residente({
    required this.id,
    required this.fullname,
    this.gender,
    this.nationalId,
    this.phoneNumber,
    this.email,
    this.registrationDate,
    this.house,
    this.status,
    this.exitDate,
    this.agreementDocument,
    this.estacionamiento,
    this.estacionamiento2,
    this.estacionamiento3,
    this.correoEnvio,
    this.emailCc,
    this.emailCc2,
    this.flagReserva,
  });
}

