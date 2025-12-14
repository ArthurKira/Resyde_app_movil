import '../../core/utils/result.dart';
import '../entities/recibo.dart';
import '../repositories/recibos_repository.dart';

class GetRecibosUseCase {
  final RecibosRepository repository;

  GetRecibosUseCase(this.repository);

  Future<Result<List<Recibo>>> call({
    required String token,
    required String schema,
    String? year,
    String? month,
    int? tenant,
    int? house,
    String? status,
    int? page,
    int? perPage,
  }) async {
    return await repository.getRecibos(
      token: token,
      schema: schema,
      year: year,
      month: month,
      tenant: tenant,
      house: house,
      status: status,
      page: page,
      perPage: perPage,
    );
  }
}

