import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/departamento.dart';
import '../../domain/repositories/departamentos_repository.dart';
import '../datasources/departamentos_remote_datasource.dart';

class DepartamentosRepositoryImpl implements DepartamentosRepository {
  final DepartamentosRemoteDataSource remoteDataSource;

  DepartamentosRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<Departamento>>> getDepartamentos(String token, String schema) async {
    try {
      final response = await remoteDataSource.getDepartamentos(token, schema);
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

