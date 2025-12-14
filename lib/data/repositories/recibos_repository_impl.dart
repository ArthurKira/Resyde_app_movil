import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/recibo.dart';
import '../../domain/repositories/recibos_repository.dart';
import '../datasources/recibos_remote_datasource.dart';

class RecibosRepositoryImpl implements RecibosRepository {
  final RecibosRemoteDataSource remoteDataSource;

  RecibosRepositoryImpl({required this.remoteDataSource});

  @override
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
  }) async {
    try {
      final response = await remoteDataSource.getRecibos(
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
      
      // Aquí podríamos devolver la metadata también, pero por ahora solo devolvemos los datos
      // La metadata se manejará en el provider a través de una solución temporal
      return Success(response.data);
    } on Exception catch (e) {
      String errorMessage = e.toString();
      
      // Limpiar el mensaje de error (remover "Exception: " si está presente)
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      
      if (errorMessage.contains('Tiempo de espera')) {
        return const Error(NetworkFailure('Tiempo de espera agotado'));
      }
      
      // Si el error contiene "Undefined property", es un error del backend PHP
      if (errorMessage.contains('Undefined property')) {
        return Error(NetworkFailure('Error en el servidor: Problema con los datos. Por favor contacta al administrador.'));
      }
      
      return Error(NetworkFailure('Error al obtener los recibos: $errorMessage'));
    } catch (e) {
      return Error(NetworkFailure('Error de conexión: ${e.toString()}'));
    }
  }
}

