// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:resyde/main.dart';
import 'package:resyde/data/datasources/auth_local_datasource.dart';
import 'package:resyde/data/datasources/auth_remote_datasource.dart';
import 'package:resyde/data/repositories/auth_repository_impl.dart';
import 'package:resyde/domain/repositories/auth_repository.dart';
import 'package:resyde/domain/usecases/login_usecase.dart';
import 'package:resyde/presentation/providers/auth_provider.dart';

void main() {
  testWidgets('Login page displays correctly', (WidgetTester tester) async {
    // Setup test dependencies
    final sharedPreferences = await SharedPreferences.getInstance();
    final authRemoteDataSource = AuthRemoteDataSourceImpl();
    final authLocalDataSource = AuthLocalDataSourceImpl(sharedPreferences);
    final AuthRepository authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
    );
    final loginUseCase = LoginUseCase(authRepository);
    final authProvider = AuthProvider(loginUseCase, authRepository);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: authProvider,
        child: MyApp(
          authProvider: authProvider,
          authLocalDataSource: authLocalDataSource,
        ),
      ),
    );

    // Verify that login page is displayed
    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.text('Inicia sesión para continuar'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
