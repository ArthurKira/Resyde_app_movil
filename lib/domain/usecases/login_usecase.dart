import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Result<User>> call(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return const Error(ValidationFailure('Email y contraseña son requeridos'));
    }

    if (!_isValidEmail(email)) {
      return const Error(ValidationFailure('Email inválido'));
    }

    return await repository.login(email, password);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

