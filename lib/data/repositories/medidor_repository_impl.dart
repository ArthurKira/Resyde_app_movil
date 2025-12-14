import 'dart:io';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/repositories/medidor_repository.dart';
import '../datasources/medidor_remote_datasource.dart';

class MedidorRepositoryImpl implements MedidorRepository {
  final MedidorRemoteDataSource remoteDataSource;

  MedidorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<void>> uploadMedidorImage({
    required String token,
    required int reciboId,
    required String schema,
    required File imagen,
    required String lecturaActual,
  }) async {
    try {
      await remoteDataSource.uploadMedidorImage(
        token: token,
        reciboId: reciboId,
        schema: schema,
        imagen: imagen,
        lecturaActual: lecturaActual,
      );
      return const Success(null);
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

