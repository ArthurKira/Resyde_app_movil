import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<User>> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await remoteDataSource.login(request);

      // Verificar que tengamos token y user para considerar el login exitoso
      if (response.token != null && response.user != null) {
        final user = response.toUser();
        await localDataSource.saveUser(user);
        return Success(user);
      } else {
        return Error(
          AuthenticationFailure(
            response.message ?? 'Error al iniciar sesión',
          ),
        );
      }
    } on Exception catch (e) {
      if (e.toString().contains('Tiempo de espera')) {
        return const Error(NetworkFailure('Tiempo de espera agotado'));
      }
      return Error(AuthenticationFailure(e.toString()));
    } catch (e) {
      return Error(NetworkFailure('Error de conexión: ${e.toString()}'));
    }
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearUser();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await localDataSource.getSavedUser();
  }
}

