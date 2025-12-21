import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/estado_asistencia.dart';
import '../../domain/entities/registro_asistencia.dart';
import '../../domain/entities/historial_asistencia.dart';
import '../../domain/repositories/asistencia_repository.dart';
import '../datasources/asistencia_remote_datasource.dart';

class AsistenciaRepositoryImpl implements AsistenciaRepository {
  final AsistenciaRemoteDataSource remoteDataSource;

  AsistenciaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<EstadoAsistencia>> getEstadoAsistencia(String token) async {
    try {
      final response = await remoteDataSource.getEstadoAsistencia(token);
      return Success(response.toEstadoAsistencia());
    } on Exception catch (e) {
      String errorMessage = e.toString();
      
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      
      if (errorMessage.contains('Tiempo de espera')) {
        return const Error(NetworkFailure('Tiempo de espera agotado'));
      }
      
      return Error(NetworkFailure('Error al obtener estado de asistencia: $errorMessage'));
    } catch (e) {
      return Error(NetworkFailure('Error de conexión: ${e.toString()}'));
    }
  }

  @override
  Future<Result<RegistroAsistencia>> marcarEntrada(
    String token,
    double latitud,
    double longitud,
  ) async {
    try {
      final response = await remoteDataSource.marcarEntrada(
        token,
        latitud,
        longitud,
      );
      return Success(response.toRegistroAsistencia());
    } on Exception catch (e) {
      String errorMessage = e.toString();
      
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      
      if (errorMessage.contains('Tiempo de espera')) {
        return const Error(NetworkFailure('Tiempo de espera agotado'));
      }
      
      return Error(NetworkFailure('Error al marcar entrada: $errorMessage'));
    } catch (e) {
      return Error(NetworkFailure('Error de conexión: ${e.toString()}'));
    }
  }

  @override
  Future<Result<RegistroAsistencia>> marcarSalida(
    String token,
    double latitud,
    double longitud,
  ) async {
    try {
      final response = await remoteDataSource.marcarSalida(
        token,
        latitud,
        longitud,
      );
      return Success(response.toRegistroAsistencia());
    } on Exception catch (e) {
      String errorMessage = e.toString();
      
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      
      if (errorMessage.contains('Tiempo de espera')) {
        return const Error(NetworkFailure('Tiempo de espera agotado'));
      }
      
      return Error(NetworkFailure('Error al marcar salida: $errorMessage'));
    } catch (e) {
      return Error(NetworkFailure('Error de conexión: ${e.toString()}'));
    }
  }

  @override
  Future<Result<HistorialAsistencia>> getHistorialAsistencia(
    String token, {
    int? limite,
    String? desde,
    String? hasta,
  }) async {
    try {
      final response = await remoteDataSource.getHistorialAsistencia(
        token,
        limite: limite,
        desde: desde,
        hasta: hasta,
      );
      return Success(response.toHistorialAsistencia());
    } on Exception catch (e) {
      String errorMessage = e.toString();
      
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      
      if (errorMessage.contains('Tiempo de espera')) {
        return const Error(NetworkFailure('Tiempo de espera agotado'));
      }
      
      return Error(NetworkFailure('Error al obtener historial: $errorMessage'));
    } catch (e) {
      return Error(NetworkFailure('Error de conexión: ${e.toString()}'));
    }
  }
}

