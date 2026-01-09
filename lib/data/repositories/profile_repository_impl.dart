import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/user_profile_response.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<UserProfile>> getUserProfile() async {
    try {
      final user = await localDataSource.getSavedUser();
      final token = user?.token;
      
      if (token == null) {
        return Error(CacheFailure('No hay sesión activa'));
      }

      final result = await remoteDataSource.getUserProfile(token);
      
      if (result is Success<UserProfileResponse>) {
        return Success(result.data.toUserProfile());
      } else {
        return Error((result as Error).failure);
      }
    } catch (e) {
      return Error(ServerFailure('Error al obtener perfil: ${e.toString()}'));
    }
  }
}

