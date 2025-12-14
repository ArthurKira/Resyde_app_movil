import '../entities/residencia.dart';
import '../../core/utils/result.dart';

abstract class ResidenciasRepository {
  Future<Result<List<Residencia>>> getResidencias(String token);
}

