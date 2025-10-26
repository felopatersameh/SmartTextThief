import 'package:flutter_test/flutter_test.dart';

import 'package:smart_text_thief/Config/setting.dart';
import 'package:smart_text_thief/Features/login/cubit/authentication_cubit.dart';
import 'package:smart_text_thief/Core/Resources/strings.dart';

void main() {
   group('Authentication Cubit Tests', () {
    late AuthenticationCubit authenticationCubit;

    setUp(() {
      authenticationCubit = AuthenticationCubit();
    });

    tearDown(() {
      authenticationCubit.close();
    });

    test('initial state is correct', () {
      expect(authenticationCubit.state, isA<AuthenticationState>());
    });

    test('loginByEmail method exists and is callable', () async {
      // Test that the method exists and can be called
      expect(authenticationCubit.loginByEmail, isA<Function>());

      // Call the method to ensure it doesn't throw
      await authenticationCubit.loginByEmail();

      // Verify state changes after calling
      expect(authenticationCubit.state.loading, false);
      expect(authenticationCubit.state.sucess, true);
      expect(authenticationCubit.state.message, 'sucssed Login ');
    });

    // test('loginByGoogle method exists and is callable', () async {
    //   // Test that the method exists and can be called
    //   expect(authenticationCubit.loginByGoogle, isA<Function>());

    //   // Call the method to ensure it doesn't throw
    //   // await authenticationCubit.loginByGoogle();

    //   // Verify state changes after calling
    //   expect(authenticationCubit.state.loading, false);
    //   expect(authenticationCubit.state.sucess, true);
    //   expect(authenticationCubit.state.message, 'sucssed Login By Google');
    // });

    test('loginByfacebook method exists and is callable', () async {
      // Test that the method exists and can be called
      expect(authenticationCubit.loginByfacebook, isA<Function>());

      // Call the method to ensure it doesn't throw
      await authenticationCubit.loginByfacebook();

      // Verify state changes after calling
      expect(authenticationCubit.state.loading, false);
      expect(authenticationCubit.state.sucess, true);
      expect(authenticationCubit.state.message, 'sucssed Login By Facebook');
    });
  });

  group('Navigation Tests', () {
    testWidgets('App router navigation methods exist', (
      WidgetTester tester,
    ) async {
      // Test that navigation methods are accessible
      expect(AppRouter.nextScreenNoPath, isA<Function>());
      expect(AppRouter.nextScreenAndClear, isA<Function>());
      expect(AppRouter.backScreen, isA<Function>());
      expect(AppRouter.goNamedByPath, isA<Function>());
      expect(AppRouter.replaceScreen, isA<Function>());
    });

    testWidgets('App router has correct initial route', (
      WidgetTester tester,
    ) async {
      expect(
        AppRouter.router.routerDelegate.currentConfiguration.uri.path,
        '',
      );
    });
  });

  group('String Constants Tests', () {
    test('App strings are properly defined', () {
      expect(AppStrings.welcome, equals('Welcome to Future Choices'));
      expect(AppStrings.welcomeHint, equals('Join us to experience selection'));
      expect(AppStrings.login, equals('Login'));
      expect(AppStrings.email, equals('Email '));
      expect(AppStrings.password, equals('Password'));
      expect(AppStrings.forgotPassword, equals('Forgot Password ? '));
      expect(AppStrings.orSignInWithGoogle, equals('Sign in with Google'));
      expect(AppStrings.orSignInWithFacebook, equals('Sign in with Facebook'));
      expect(AppStrings.orContinue, equals('Or continue with'));
    });

    test('Route names are properly defined', () {
      expect(NameRoutes.splash, equals('/'));
      expect(NameRoutes.login, equals('login'));
      // expect(NameRoutes.main, equals('main'));
    });
  });

  group('Extension Tests', () {
    test('PathStringExtension works correctly', () {
      expect('test'.ensureWithSlash(), equals('/test'));
      expect('/test'.ensureWithSlash(), equals('/test'));
      expect('test/'.removeSlash(), equals('test'));
      expect('test'.removeSlash(), equals('test'));
    });
  });
}
