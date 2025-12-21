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
  ) async {
    return await repository.marcarEntrada(token, latitud, longitud);
  }
}

