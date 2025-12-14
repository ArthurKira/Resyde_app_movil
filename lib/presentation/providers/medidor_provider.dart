import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/usecases/upload_medidor_image_usecase.dart';

class MedidorProvider with ChangeNotifier {
  final UploadMedidorImageUseCase uploadMedidorImageUseCase;

  MedidorProvider(this.uploadMedidorImageUseCase);

  bool _isLoading = false;
  Failure? _error;

  bool get isLoading => _isLoading;
  Failure? get error => _error;

  Future<Result<void>> uploadMedidorImage({
    required String token,
    required int reciboId,
    required String schema,
    required File imagen,
    required String lecturaActual,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await uploadMedidorImageUseCase(
      token: token,
      reciboId: reciboId,
      schema: schema,
      imagen: imagen,
      lecturaActual: lecturaActual,
    );

    _isLoading = false;

    if (result is Error<void>) {
      _error = result.failure;
    } else {
      _error = null;
    }

    notifyListeners();
    return result;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

