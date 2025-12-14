import 'dart:io';
import '../../core/utils/result.dart';
import '../repositories/medidor_repository.dart';

class UploadMedidorImageUseCase {
  final MedidorRepository repository;

  UploadMedidorImageUseCase(this.repository);

  Future<Result<void>> call({
    required String token,
    required int reciboId,
    required String schema,
    required File imagen,
    required String lecturaActual,
  }) async {
    return await repository.uploadMedidorImage(
      token: token,
      reciboId: reciboId,
      schema: schema,
      imagen: imagen,
      lecturaActual: lecturaActual,
    );
  }
}

