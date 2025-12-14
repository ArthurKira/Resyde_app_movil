import '../../core/utils/result.dart';
import '../entities/departamento.dart';
import '../repositories/departamentos_repository.dart';

class GetDepartamentosUseCase {
  final DepartamentosRepository repository;

  GetDepartamentosUseCase(this.repository);

  Future<Result<List<Departamento>>> call(String token, String schema) async {
    return await repository.getDepartamentos(token, schema);
  }
}

