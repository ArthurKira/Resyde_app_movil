import 'personal_info.dart';
import 'residencia_asignada.dart';

class UserProfile {
  final int id;
  final String name;
  final String email;
  final PersonalInfo personal;
  final int totalResidencias;
  final bool tieneAlgunHorarioHoy;
  final List<ResidenciaAsignada> residencias;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.personal,
    required this.totalResidencias,
    required this.tieneAlgunHorarioHoy,
    required this.residencias,
  });
}

