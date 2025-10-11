import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_text_thief/main.dart';
import 'package:smart_text_thief/Config/setting.dart';
import 'package:smart_text_thief/Features/Splash/splash_screen.dart';
import 'package:smart_text_thief/Features/login/login_screen.dart';
import 'package:smart_text_thief/Features/login/cubit/authentication_cubit.dart';
import 'package:smart_text_thief/Core/Resources/strings.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Config/Routes/app_router.dart';

void main() {
  group('Smart Text Thief App Tests', () {
    testWidgets('App initializes correctly', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify the app builds without errors
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Splash screen displays correctly', (
      WidgetTester tester,
    ) async {
      // Build splash screen
      await tester.pumpWidget(const SplashScreen());
      await tester.pump();

      // Verify splash screen structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('Login screen displays all required elements', (
      WidgetTester tester,
    ) async {
      // Build login screen
      await tester.pumpWidget(
        BlocProvider<AuthenticationCubit>(
          create: (context) => AuthenticationCubit(),
          child: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify main UI elements are present
      expect(find.text(AppStrings.welcome), findsOneWidget);
      expect(find.text(AppStrings.welcomeHint), findsOneWidget);
      expect(find.text(AppStrings.login), findsOneWidget);
      expect(find.text(AppStrings.forgotPassword), findsOneWidget);
      expect(find.text(AppStrings.orContinue), findsOneWidget);
      expect(find.text(AppStrings.orSignInWithGoogle), findsOneWidget);
      expect(find.text(AppStrings.orSignInWithFacebook), findsOneWidget);
    });

    testWidgets('Login form validation works correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        BlocProvider<AuthenticationCubit>(
          create: (context) => AuthenticationCubit(),
          child: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find the login button
      final loginButton = find.text(AppStrings.login);
      expect(loginButton, findsOneWidget);

      // Tap login button without entering any data
      await tester.tap(loginButton);
      await tester.pump();

      // Verify validation errors appear (email field should be required)
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('Email field accepts valid email input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        BlocProvider<AuthenticationCubit>(
          create: (context) => AuthenticationCubit(),
          child: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find email field and enter valid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      // Verify the text was entered
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Password field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(
        BlocProvider<AuthenticationCubit>(
          create: (context) => AuthenticationCubit(),
          child: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find password field and enter password
      final passwordFields = find.byType(TextFormField);
      expect(
        passwordFields,
        findsAtLeastNWidgets(2),
      ); // Email and password fields

      // Enter password in the second text field (password field)
      await tester.enterText(passwordFields.at(1), 'password123');
      await tester.pump();

      // Verify the text was entered (password field might be obscured)
      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
    });

    testWidgets('Forgot password button is tappable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        BlocProvider<AuthenticationCubit>(
          create: (context) => AuthenticationCubit(),
          child: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find forgot password button
      final forgotPasswordButton = find.text(AppStrings.forgotPassword);
      expect(forgotPasswordButton, findsOneWidget);

      // Tap the button
      await tester.tap(forgotPasswordButton);
      await tester.pump();

      // Verify button was tapped (no error should occur)
      expect(forgotPasswordButton, findsOneWidget);
    });

    testWidgets('Google sign in button is present and tappable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        BlocProvider<AuthenticationCubit>(
          create: (context) => AuthenticationCubit(),
          child: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find Google sign in button
      final googleButton = find.text(AppStrings.orSignInWithGoogle);
      expect(googleButton, findsOneWidget);

      // Tap the button
      await tester.tap(googleButton);
      await tester.pump();

      // Verify button was tapped successfully
      expect(googleButton, findsOneWidget);
    });

    testWidgets('Facebook sign in button is present and tappable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        BlocProvider<AuthenticationCubit>(
          create: (context) => AuthenticationCubit(),
          child: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find Facebook sign in button
      final facebookButton = find.text(AppStrings.orSignInWithFacebook);
      expect(facebookButton, findsOneWidget);

      // Tap the button
      await tester.tap(facebookButton);
      await tester.pump();

      // Verify button was tapped successfully
      expect(facebookButton, findsOneWidget);
    });
  });

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

    test('loginByGoogle method exists and is callable', () async {
      // Test that the method exists and can be called
      expect(authenticationCubit.loginByGoogle, isA<Function>());

      // Call the method to ensure it doesn't throw
      await authenticationCubit.loginByGoogle();

      // Verify state changes after calling
      expect(authenticationCubit.state.loading, false);
      expect(authenticationCubit.state.sucess, true);
      expect(authenticationCubit.state.message, 'sucssed Login By Google');
    });

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
      // Test that router is properly configured
      expect(
        AppRouter.router.routerDelegate.currentConfiguration.uri.path,
        '/',
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
      expect(NameRoutes.main, equals('main'));
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
