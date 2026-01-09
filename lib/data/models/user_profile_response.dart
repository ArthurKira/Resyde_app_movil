import '../../domain/entities/user_profile.dart';
import '../../domain/entities/personal_info.dart';
import '../../domain/entities/residencia_asignada.dart';
import '../../domain/entities/horario_perfil.dart';

class UserProfileResponse {
  final bool success;
  final Map<String, dynamic> user;

  UserProfileResponse({
    required this.success,
    required this.user,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      success: json['success'] as bool? ?? false,
      user: json['user'] as Map<String, dynamic>? ?? {},
    );
  }

  UserProfile toUserProfile() {
    final personalData = user['personal'] as Map<String, dynamic>?;
    final residenciasData = user['residencias'] as List<dynamic>? ?? [];

    return UserProfile(
      id: user['id'] as int? ?? 0,
      name: user['name'] as String? ?? '',
      email: user['email'] as String? ?? '',
      personal: _parsePersonalInfo(personalData),
      totalResidencias: user['total_residencias'] as int? ?? 0,
      tieneAlgunHorarioHoy: user['tiene_algun_horario_hoy'] as bool? ?? false,
      residencias: residenciasData
          .map((item) => _parseResidenciaAsignada(item as Map<String, dynamic>))
          .toList(),
    );
  }

  PersonalInfo _parsePersonalInfo(Map<String, dynamic>? json) {
    if (json == null) {
      return const PersonalInfo(
        idPersonal: 0,
        nombres: '',
        apellidos: '',
        dniCe: '',
        estado: '',
      );
    }

    return PersonalInfo(
      idPersonal: json['id_personal'] as int? ?? 0,
      nombres: json['nombres'] as String? ?? '',
      apellidos: json['apellidos'] as String? ?? '',
      dniCe: json['dni_ce'] as String? ?? '',
      estado: json['estado'] as String? ?? '',
    );
  }

  ResidenciaAsignada _parseResidenciaAsignada(Map<String, dynamic> json) {
    final residenciaData = json['residencia'] as Map<String, dynamic>?;
    final horarioHoyData = json['horario_hoy'] as Map<String, dynamic>?;

    return ResidenciaAsignada(
      idPersonalResidencia: json['id_personal_residencia'] as int? ?? 0,
      cargo: json['cargo'] as String? ?? '',
      idResidencia: residenciaData?['id_residencia'] as int? ?? 0,
      nombreResidencia: residenciaData?['nombre'] as String? ?? '',
      tieneHorarioHoy: json['tiene_horario_hoy'] as bool? ?? false,
      horarioHoy: horarioHoyData != null ? _parseHorarioPerfil(horarioHoyData) : null,
    );
  }

  HorarioPerfil _parseHorarioPerfil(Map<String, dynamic> json) {
    return HorarioPerfil(
      horaEntrada: json['hora_entrada'] as String? ?? '',
      horaSalida: json['hora_salida'] as String? ?? '',
      diasSemana: (json['dias_semana'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      fechaInicio: json['fecha_inicio'] as String? ?? '',
      fechaFin: json['fecha_fin'] as String?,
    );
  }
}

