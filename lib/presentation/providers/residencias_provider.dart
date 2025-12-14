import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/residencia.dart';
import '../../domain/usecases/get_residencias_usecase.dart';

class ResidenciasProvider with ChangeNotifier {
  final GetResidenciasUseCase getResidenciasUseCase;

  ResidenciasProvider(this.getResidenciasUseCase);

  bool _isLoading = false;
  List<Residencia> _residencias = [];
  Failure? _error;

  bool get isLoading => _isLoading;
  List<Residencia> get residencias => _residencias;
  Failure? get error => _error;

  Future<void> loadResidencias(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getResidenciasUseCase(token);

    _isLoading = false;

    if (result is Success<List<Residencia>>) {
      _residencias = result.data;
      _error = null;
    } else if (result is Error<List<Residencia>>) {
      _error = result.failure;
      _residencias = [];
    }

    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

