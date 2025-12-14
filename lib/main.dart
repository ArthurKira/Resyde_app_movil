import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/residencias_remote_datasource.dart';
import 'data/datasources/recibos_remote_datasource.dart';
import 'data/datasources/residentes_remote_datasource.dart';
import 'data/datasources/departamentos_remote_datasource.dart';
import 'data/datasources/medidor_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/residencias_repository_impl.dart';
import 'data/repositories/recibos_repository_impl.dart';
import 'data/repositories/residentes_repository_impl.dart';
import 'data/repositories/departamentos_repository_impl.dart';
import 'data/repositories/medidor_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/residencias_repository.dart';
import 'domain/repositories/recibos_repository.dart';
import 'domain/repositories/residentes_repository.dart';
import 'domain/repositories/departamentos_repository.dart';
import 'domain/repositories/medidor_repository.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/get_residencias_usecase.dart';
import 'domain/usecases/get_recibos_usecase.dart';
import 'domain/usecases/get_residentes_usecase.dart';
import 'domain/usecases/get_departamentos_usecase.dart';
import 'domain/usecases/upload_medidor_image_usecase.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/residencias_provider.dart';
import 'presentation/providers/recibos_provider.dart';
import 'presentation/providers/medidor_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar dependencias
  final sharedPreferences = await SharedPreferences.getInstance();
  final authRemoteDataSource = AuthRemoteDataSourceImpl();
  final authLocalDataSource = AuthLocalDataSourceImpl(sharedPreferences);
  final AuthRepository authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    localDataSource: authLocalDataSource,
  );
  final loginUseCase = LoginUseCase(authRepository);
  final authProvider = AuthProvider(loginUseCase, authRepository);

  // Verificar si hay sesión activa
  await authProvider.checkSession();

  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;

  const MyApp({
    super.key,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    // Inicializar dependencias de residencias
    final residenciasRemoteDataSource = ResidenciasRemoteDataSourceImpl();
    final ResidenciasRepository residenciasRepository = ResidenciasRepositoryImpl(
      remoteDataSource: residenciasRemoteDataSource,
    );
    final getResidenciasUseCase = GetResidenciasUseCase(residenciasRepository);
    final residenciasProvider = ResidenciasProvider(getResidenciasUseCase);

    // Inicializar dependencias de recibos
    final recibosRemoteDataSource = RecibosRemoteDataSourceImpl();
    final RecibosRepository recibosRepository = RecibosRepositoryImpl(
      remoteDataSource: recibosRemoteDataSource,
    );
    final getRecibosUseCase = GetRecibosUseCase(recibosRepository);

    // Inicializar dependencias de residentes
    final residentesRemoteDataSource = ResidentesRemoteDataSourceImpl();
    final ResidentesRepository residentesRepository = ResidentesRepositoryImpl(
      remoteDataSource: residentesRemoteDataSource,
    );
    final getResidentesUseCase = GetResidentesUseCase(residentesRepository);

    // Inicializar dependencias de departamentos
    final departamentosRemoteDataSource = DepartamentosRemoteDataSourceImpl();
    final DepartamentosRepository departamentosRepository = DepartamentosRepositoryImpl(
      remoteDataSource: departamentosRemoteDataSource,
    );
    final getDepartamentosUseCase = GetDepartamentosUseCase(departamentosRepository);

    final recibosProvider = RecibosProvider(
      getRecibosUseCase,
      getResidentesUseCase,
      getDepartamentosUseCase,
    );

    // Inicializar dependencias de medidor
    final medidorRemoteDataSource = MedidorRemoteDataSourceImpl();
    final MedidorRepository medidorRepository = MedidorRepositoryImpl(
      remoteDataSource: medidorRemoteDataSource,
    );
    final uploadMedidorImageUseCase = UploadMedidorImageUseCase(medidorRepository);
    final medidorProvider = MedidorProvider(uploadMedidorImageUseCase);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: residenciasProvider),
        ChangeNotifierProvider.value(value: recibosProvider),
        ChangeNotifierProvider.value(value: medidorProvider),
      ],
      child: MaterialApp(
        title: 'Resyde',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: _getInitialRoute(authProvider),
      ),
    );
  }
  
  // Función helper para determinar la ruta inicial
  // Solo se ejecuta una vez al inicio, no escucha cambios
  static Widget _getInitialRoute(AuthProvider authProvider) {
    // Mostrar loading mientras se verifica la sesión inicial
            if (authProvider.isCheckingSession) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
    
    // Solo verificar el estado inicial UNA VEZ
    // La navegación después del login se maneja explícitamente en login_page.dart
    // Esto previene conflictos con la navegación manual
            return authProvider.isAuthenticated
                ? const HomePage()
                : const LoginPage();
  }
}
