import '../../core/utils/result.dart';
import '../entities/residencia.dart';
import '../repositories/residencias_repository.dart';

class GetResidenciasUseCase {
  final ResidenciasRepository repository;

  GetResidenciasUseCase(this.repository);

  Future<Result<List<Residencia>>> call(String token) async {
    return await repository.getResidencias(token);
  }
}

