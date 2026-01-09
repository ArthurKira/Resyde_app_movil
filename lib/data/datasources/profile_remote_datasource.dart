import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../models/user_profile_response.dart';

class ProfileRemoteDataSource {
  final http.Client client;

  ProfileRemoteDataSource({http.Client? client}) : client = client ?? http.Client();

  Future<Result<UserProfileResponse>> getUserProfile(String token) async {
    try {
      final response = await client.get(
        Uri.parse(ApiConstants.mobileUserEndpoint),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Accept': ApiConstants.accept,
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final profileResponse = UserProfileResponse.fromJson(jsonResponse);
        return Success(profileResponse);
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['message'] ?? 'Error al obtener perfil';
        return Error(ServerFailure(errorMessage));
      }
    } catch (e) {
      return Error(ServerFailure('Error de conexión: ${e.toString()}'));
    }
  }
}

