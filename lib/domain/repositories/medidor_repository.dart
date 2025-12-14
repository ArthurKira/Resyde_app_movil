import 'dart:io';
import '../../core/utils/result.dart';

abstract class MedidorRepository {
  Future<Result<void>> uploadMedidorImage({
    required String token,
    required int reciboId,
    required String schema,
    required File imagen,
    required String lecturaActual,
  });
}

