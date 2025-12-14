import '../entities/departamento.dart';
import '../../core/utils/result.dart';

abstract class DepartamentosRepository {
  Future<Result<List<Departamento>>> getDepartamentos(String token, String schema);
}

