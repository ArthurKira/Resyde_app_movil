import '../../core/utils/result.dart';
import '../entities/residente.dart';
import '../repositories/residentes_repository.dart';

class GetResidentesUseCase {
  final ResidentesRepository repository;

  GetResidentesUseCase(this.repository);

  Future<Result<List<Residente>>> call(String token, String schema) async {
    return await repository.getResidentes(token, schema);
  }
}

