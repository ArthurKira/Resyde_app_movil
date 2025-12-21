import '../../core/utils/result.dart';
import '../entities/registro_asistencia.dart';
import '../repositories/asistencia_repository.dart';

class MarcarSalidaUseCase {
  final AsistenciaRepository repository;

  MarcarSalidaUseCase(this.repository);

  Future<Result<RegistroAsistencia>> call(
    String token,
    double latitud,
    double longitud,
  ) async {
    return await repository.marcarSalida(token, latitud, longitud);
  }
}

