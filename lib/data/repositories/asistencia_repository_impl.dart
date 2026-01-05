import 'dart:io';
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
    File foto,
  ) async {
    try {
      final response = await remoteDataSource.marcarEntrada(
        token,
        latitud,
        longitud,
        foto,
      );
      return Success(response.toRegistroAsistencia());
    } on Exception catch (e) {
      String errorMessage = e.toString();
      
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      
      if (errorMessage.contains('Ya tiene entrada marcada')) {
        return const Error(ValidationFailure('Ya tienes una entrada marcada para hoy. Debes marcar salida primero.'));
      }
      
      if (errorMessage.contains('Tiempo de espera')) {
        return const Error(NetworkFailure('Tiempo de espera agotado. Verifica tu conexión e intenta de nuevo.'));
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
    File foto,
  ) async {
    try {
      final response = await remoteDataSource.marcarSalida(
        token,
        latitud,
        longitud,
        foto,
      );
      return Success(response.toRegistroAsistencia());
    } on Exception catch (e) {
      String errorMessage = e.toString();
      
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      
      // Mensajes específicos para turnos nocturnos y validaciones
      if (errorMessage.contains('48 horas')) {
        return const Error(ValidationFailure('No puedes marcar salida: han pasado más de 48 horas desde tu entrada. Contacta a tu supervisor.'));
      }
      
      if (errorMessage.contains('No tiene entrada marcada sin salida')) {
        return const Error(ValidationFailure('No tienes una entrada pendiente para cerrar. Debes marcar entrada primero.'));
      }
      
      if (errorMessage.contains('debe ser posterior') || errorMessage.contains('hora de salida')) {
        return const Error(ValidationFailure('La hora de salida debe ser después de la hora de entrada.'));
      }
      
      if (errorMessage.contains('Tiempo de espera')) {
        return const Error(NetworkFailure('Tiempo de espera agotado. Verifica tu conexión e intenta de nuevo.'));
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

