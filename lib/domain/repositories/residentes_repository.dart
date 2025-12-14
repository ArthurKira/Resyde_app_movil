import '../entities/residente.dart';
import '../../core/utils/result.dart';

abstract class ResidentesRepository {
  Future<Result<List<Residente>>> getResidentes(String token, String schema);
}

