import '../../core/utils/result.dart';
import '../entities/estado_asistencia.dart';
import '../repositories/asistencia_repository.dart';

class GetEstadoAsistenciaUseCase {
  final AsistenciaRepository repository;

  GetEstadoAsistenciaUseCase(this.repository);

  Future<Result<EstadoAsistencia>> call(String token) async {
    return await repository.getEstadoAsistencia(token);
  }
}

