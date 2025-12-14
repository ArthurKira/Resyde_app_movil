import '../entities/recibo.dart';
import '../../core/utils/result.dart';

abstract class RecibosRepository {
  Future<Result<List<Recibo>>> getRecibos({
    required String token,
    required String schema,
    String? year,
    String? month,
    int? tenant,
    int? house,
    String? status,
    int? page,
    int? perPage,
  });
}

