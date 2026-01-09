
import 'dart:io';

class ApiConstants {
  //static const String baseUrl = 'https://apiresyde.uclub.net.pe/api';
  
  // Función para obtener la URL base según la plataforma
  static String get baseUrl {
    // Producción
    // return 'https://apiresyde.uclub.net.pe/api';
    
    //Desarrollo local - detecta la plataforma automáticamente (comentado para producción)
    if (Platform.isAndroid) {
      // Android Emulador: 10.0.2.2 mapea al localhost de la Mac
      // Dispositivo físico Android: usa la IP de tu Mac (ej: 192.168.100.61)
      return 'http://10.0.2.2:8000/api'; // Android Emulador
      // return 'http://192.168.100.61:8000/api'; // Android dispositivo físico
    } else if (Platform.isIOS) {
      // iOS Emulador: puede usar 127.0.0.1 directamente
      // Dispositivo físico iOS: usa la IP de tu Mac (ej: 192.168.100.61)
      return 'http://127.0.0.1:8000/api'; // iOS Emulador
      // return 'http://192.168.100.61:8000/api'; // iOS dispositivo físico
    } else {
      // Para web u otras plataformas
      return 'http://127.0.0.1:8000/api';
    }
  }
  
  static String get loginEndpoint => '$baseUrl/auth/login';
  static String get residenciasEndpoint => '$baseUrl/residencias';
  static String get recibosEndpoint => '$baseUrl/recibos';
  static String get residentesEndpoint => '$baseUrl/residentes';
  static String get departamentosEndpoint => '$baseUrl/departamentos';
  
  // Asistencia endpoints
  static String get mobileUserEndpoint => '$baseUrl/mobile/user';
  static String get asistenciaEstadoEndpoint => '$baseUrl/mobile/asistencia/estado';
  static String get asistenciaMarcarEntradaEndpoint => '$baseUrl/mobile/asistencia/marcar-entrada';
  static String get asistenciaMarcarSalidaEndpoint => '$baseUrl/mobile/asistencia/marcar-salida';
  static String get asistenciaHistorialEndpoint => '$baseUrl/mobile/asistencia/historial';
  
  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
}

