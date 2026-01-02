import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/estado_asistencia.dart';
import '../../domain/entities/registro_asistencia.dart';
import '../../domain/entities/historial_asistencia.dart';
import '../../domain/usecases/get_estado_asistencia_usecase.dart';
import '../../domain/usecases/marcar_entrada_usecase.dart';
import '../../domain/usecases/marcar_salida_usecase.dart';
import '../../domain/usecases/get_historial_asistencia_usecase.dart';

class AsistenciaProvider with ChangeNotifier {
  final GetEstadoAsistenciaUseCase getEstadoAsistenciaUseCase;
  final MarcarEntradaUseCase marcarEntradaUseCase;
  final MarcarSalidaUseCase marcarSalidaUseCase;
  final GetHistorialAsistenciaUseCase getHistorialAsistenciaUseCase;

  AsistenciaProvider(
    this.getEstadoAsistenciaUseCase,
    this.marcarEntradaUseCase,
    this.marcarSalidaUseCase,
    this.getHistorialAsistenciaUseCase,
  );

  // Estados
  bool _isLoading = false;
  bool _isLoadingEstado = false;
  bool _isLoadingHistorial = false;
  bool _isMarcandoEntrada = false;
  bool _isMarcandoSalida = false;
  bool _isObteniendoUbicacion = false;
  bool _isTomandoFoto = false;
  
  EstadoAsistencia? _estadoAsistencia;
  HistorialAsistencia? _historialAsistencia;
  Failure? _error;
  Failure? _errorHistorial;
  
  // Ubicación
  Position? _currentPosition;
  bool _tienePermisosUbicacion = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingEstado => _isLoadingEstado;
  bool get isLoadingHistorial => _isLoadingHistorial;
  bool get isMarcandoEntrada => _isMarcandoEntrada;
  bool get isMarcandoSalida => _isMarcandoSalida;
  bool get isObteniendoUbicacion => _isObteniendoUbicacion;
  bool get isTomandoFoto => _isTomandoFoto;
  EstadoAsistencia? get estadoAsistencia => _estadoAsistencia;
  HistorialAsistencia? get historialAsistencia => _historialAsistencia;
  Failure? get error => _error;
  Failure? get errorHistorial => _errorHistorial;
  Position? get currentPosition => _currentPosition;
  bool get tienePermisosUbicacion => _tienePermisosUbicacion;

  // Cargar estado de asistencia
  Future<void> loadEstadoAsistencia(String token) async {
    _isLoadingEstado = true;
    _error = null;
    notifyListeners();

    final result = await getEstadoAsistenciaUseCase(token);

    _isLoadingEstado = false;

    if (result is Success<EstadoAsistencia>) {
      _estadoAsistencia = result.data;
      _error = null;
    } else if (result is Error<EstadoAsistencia>) {
      _error = result.failure;
      _estadoAsistencia = null;
    }

    notifyListeners();
  }

  // Obtener ubicación GPS
  Future<Result<Position>> obtenerUbicacion() async {
    _isObteniendoUbicacion = true;
    notifyListeners();

    try {
      // Verificar permisos
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isObteniendoUbicacion = false;
        notifyListeners();
        return const Error(NetworkFailure('El servicio de ubicación está deshabilitado. Por favor, actívalo en la configuración.'));
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _isObteniendoUbicacion = false;
          _tienePermisosUbicacion = false;
          notifyListeners();
          return const Error(NetworkFailure('Los permisos de ubicación fueron denegados.'));
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _isObteniendoUbicacion = false;
        _tienePermisosUbicacion = false;
        notifyListeners();
        return const Error(NetworkFailure('Los permisos de ubicación fueron denegados permanentemente. Por favor, actívalos en la configuración.'));
      }

      _tienePermisosUbicacion = true;

      // Obtener ubicación
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _currentPosition = position;
      _isObteniendoUbicacion = false;
      notifyListeners();

      return Success(position);
    } catch (e) {
      _isObteniendoUbicacion = false;
      _tienePermisosUbicacion = false;
      notifyListeners();
      return Error(NetworkFailure('Error al obtener ubicación: ${e.toString()}'));
    }
  }

  // Tomar foto con la cámara
  Future<Result<File>> tomarFoto() async {
    _isTomandoFoto = true;
    _error = null;
    notifyListeners();

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Calidad de imagen (0-100)
      );

      _isTomandoFoto = false;

      if (image == null) {
        // Usuario canceló la cámara
        return const Error(NetworkFailure('No se seleccionó imagen. La foto es obligatoria.'));
      }

      final file = File(image.path);
      notifyListeners();
      return Success(file);
    } catch (e) {
      _isTomandoFoto = false;
      notifyListeners();
      return Error(NetworkFailure('Error al tomar foto: ${e.toString()}'));
    }
  }

  // Marcar entrada
  Future<Result<RegistroAsistencia>> marcarEntrada(String token) async {
    _isMarcandoEntrada = true;
    _error = null;
    notifyListeners();

    // 1. Obtener ubicación primero
    final ubicacionResult = await obtenerUbicacion();
    if (ubicacionResult is Error<Position>) {
      _isMarcandoEntrada = false;
      _error = ubicacionResult.failure;
      notifyListeners();
      return ubicacionResult as Result<RegistroAsistencia>;
    }

    final position = (ubicacionResult as Success<Position>).data;

    // 2. Tomar foto
    final fotoResult = await tomarFoto();
    if (fotoResult is Error<File>) {
      _isMarcandoEntrada = false;
      _error = fotoResult.failure;
      notifyListeners();
      return fotoResult as Result<RegistroAsistencia>;
    }

    final foto = (fotoResult as Success<File>).data;

    // 3. Marcar entrada con foto
    final result = await marcarEntradaUseCase(
      token,
      position.latitude,
      position.longitude,
      foto,
    );

    _isMarcandoEntrada = false;

    if (result is Success<RegistroAsistencia>) {
      _error = null;
      // Recargar estado después de marcar entrada
      await loadEstadoAsistencia(token);
    } else if (result is Error<RegistroAsistencia>) {
      _error = result.failure;
    }

    notifyListeners();
    return result;
  }

  // Marcar salida
  Future<Result<RegistroAsistencia>> marcarSalida(String token) async {
    _isMarcandoSalida = true;
    _error = null;
    notifyListeners();

    // 1. Obtener ubicación primero
    final ubicacionResult = await obtenerUbicacion();
    if (ubicacionResult is Error<Position>) {
      _isMarcandoSalida = false;
      _error = ubicacionResult.failure;
      notifyListeners();
      return ubicacionResult as Result<RegistroAsistencia>;
    }

    final position = (ubicacionResult as Success<Position>).data;

    // 2. Tomar foto
    final fotoResult = await tomarFoto();
    if (fotoResult is Error<File>) {
      _isMarcandoSalida = false;
      _error = fotoResult.failure;
      notifyListeners();
      return fotoResult as Result<RegistroAsistencia>;
    }

    final foto = (fotoResult as Success<File>).data;

    // 3. Marcar salida con foto
    final result = await marcarSalidaUseCase(
      token,
      position.latitude,
      position.longitude,
      foto,
    );

    _isMarcandoSalida = false;

    if (result is Success<RegistroAsistencia>) {
      _error = null;
      // Recargar estado después de marcar salida
      await loadEstadoAsistencia(token);
    } else if (result is Error<RegistroAsistencia>) {
      _error = result.failure;
    }

    notifyListeners();
    return result;
  }

  // Cargar historial
  Future<void> loadHistorialAsistencia(
    String token, {
    int? limite,
    String? desde,
    String? hasta,
  }) async {
    _isLoadingHistorial = true;
    _errorHistorial = null;
    notifyListeners();

    final result = await getHistorialAsistenciaUseCase(
      token,
      limite: limite,
      desde: desde,
      hasta: hasta,
    );

    _isLoadingHistorial = false;

    if (result is Success<HistorialAsistencia>) {
      _historialAsistencia = result.data;
      _errorHistorial = null;
    } else if (result is Error<HistorialAsistencia>) {
      _errorHistorial = result.failure;
      _historialAsistencia = null;
    }

    notifyListeners();
  }

  void clearError() {
    _error = null;
    _errorHistorial = null;
    notifyListeners();
  }
}

