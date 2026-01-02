import 'dart:io';
import '../entities/estado_asistencia.dart';
import '../entities/registro_asistencia.dart';
import '../entities/historial_asistencia.dart';
import '../../core/utils/result.dart';

abstract class AsistenciaRepository {
  Future<Result<EstadoAsistencia>> getEstadoAsistencia(String token);
  Future<Result<RegistroAsistencia>> marcarEntrada(
    String token,
    double latitud,
    double longitud,
    File foto,
  );
  Future<Result<RegistroAsistencia>> marcarSalida(
    String token,
    double latitud,
    double longitud,
    File foto,
  );
  Future<Result<HistorialAsistencia>> getHistorialAsistencia(
    String token, {
    int? limite,
    String? desde,
    String? hasta,
  });
}

