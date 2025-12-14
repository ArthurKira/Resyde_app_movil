import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/residencia.dart';
import '../../domain/repositories/residencias_repository.dart';
import '../datasources/residencias_remote_datasource.dart';

class ResidenciasRepositoryImpl implements ResidenciasRepository {
  final ResidenciasRemoteDataSource remoteDataSource;

  ResidenciasRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<Residencia>>> getResidencias(String token) async {
    try {
      final response = await remoteDataSource.getResidencias(token);
      return Success(response.data);
    } on Exception catch (e) {
      if (e.toString().contains('Tiempo de espera')) {
        return const Error(NetworkFailure('Tiempo de espera agotado'));
      }
      return Error(NetworkFailure(e.toString()));
    } catch (e) {
      return Error(NetworkFailure('Error de conexión: ${e.toString()}'));
    }
  }
}

