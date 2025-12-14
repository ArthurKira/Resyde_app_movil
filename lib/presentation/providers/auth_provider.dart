import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';

class AuthProvider with ChangeNotifier {
  final LoginUseCase loginUseCase;
  final AuthRepository authRepository;

  AuthProvider(this.loginUseCase, this.authRepository);

  bool _isLoading = false;
  bool _isCheckingSession = false;
  User? _currentUser;
  Failure? _error;

  bool get isLoading => _isLoading;
  bool get isCheckingSession => _isCheckingSession;
  User? get currentUser => _currentUser;
  Failure? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> checkSession() async {
    _isCheckingSession = true;
    notifyListeners();

    try {
      final user = await authRepository.getCurrentUser();
      _currentUser = user;
    } catch (e) {
      _currentUser = null;
    } finally {
      _isCheckingSession = false;
      notifyListeners();
    }
  }

  Future<Result<User>> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await loginUseCase(email, password);

    _isLoading = false;

    if (result is Success<User>) {
      _currentUser = result.data;
      _error = null;
    } else if (result is Error<User>) {
      _error = result.failure;
      _currentUser = null;
    }

    notifyListeners();
    return result;
  }

  Future<void> logout() async {
    await authRepository.logout();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

