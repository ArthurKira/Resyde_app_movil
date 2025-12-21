import '../../core/utils/result.dart';
import '../entities/historial_asistencia.dart';
import '../repositories/asistencia_repository.dart';

class GetHistorialAsistenciaUseCase {
  final AsistenciaRepository repository;

  GetHistorialAsistenciaUseCase(this.repository);

  Future<Result<HistorialAsistencia>> call(
    String token, {
    int? limite,
    String? desde,
    String? hasta,
  }) async {
    return await repository.getHistorialAsistencia(
      token,
      limite: limite,
      desde: desde,
      hasta: hasta,
    );
  }
}

