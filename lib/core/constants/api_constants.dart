class ApiConstants {
  static const String baseUrl = 'https://apiresyde.uclub.net.pe/api';
  //static const String baseUrl = 'http://localhost:8000/api';
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String residenciasEndpoint = '$baseUrl/residencias';
  static const String recibosEndpoint = '$baseUrl/recibos';
  static const String residentesEndpoint = '$baseUrl/residentes';
  static const String departamentosEndpoint = '$baseUrl/departamentos';
  
  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
}

