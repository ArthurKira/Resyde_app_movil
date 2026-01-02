import 'dart:io';
import '../../core/utils/result.dart';
import '../entities/registro_asistencia.dart';
import '../repositories/asistencia_repository.dart';

class MarcarEntradaUseCase {
  final AsistenciaRepository repository;

  MarcarEntradaUseCase(this.repository);

  Future<Result<RegistroAsistencia>> call(
    String token,
    double latitud,
    double longitud,
    File foto,
  ) async {
    return await repository.marcarEntrada(token, latitud, longitud, foto);
  }
}

