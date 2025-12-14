import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/residente.dart';
import '../../domain/repositories/residentes_repository.dart';
import '../datasources/residentes_remote_datasource.dart';

class ResidentesRepositoryImpl implements ResidentesRepository {
  final ResidentesRemoteDataSource remoteDataSource;

  ResidentesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<Residente>>> getResidentes(String token, String schema) async {
    try {
      final response = await remoteDataSource.getResidentes(token, schema);
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

