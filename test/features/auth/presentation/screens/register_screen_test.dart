import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/features/auth/data/auth_service.dart';
import 'package:pickle_pick/features/auth/presentation/providers/auth_providers.dart';
import 'package:pickle_pick/features/auth/presentation/screens/register_screen.dart';
import 'package:pickle_pick/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../test_helper.dart';
import '../robots/auth_robot.dart';

class MockAuthService extends Mock implements AuthService {}

class MockStackRouter extends Mock implements StackRouter {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockUser extends Mock implements User {}

void main() {
  late MockAuthService mockAuthService;
  late MockStackRouter mockRouter;

  setUpAll(() {
    registerFallbackValue(LoginRoute());
    registerFallbackValue(const MainWrapperRoute());
    registerFallbackValue(FakePageRouteInfo());
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockRouter = MockStackRouter();

    when(() => mockAuthService.currentUser).thenReturn(null);
    when(() => mockAuthService.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockRouter.push(any())).thenAnswer((_) async => null);
    when(() => mockRouter.replaceAll(any())).thenAnswer((_) async {});
    when(() => mockRouter.back()).thenAnswer((_) async {});
  });

  Future<AppLocalizations> pumpRegisterScreen(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpTestApp(
      const RegisterScreen(),
      locale: locale,
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
      ],
      router: mockRouter,
      settle: true,
    );

    return AppLocalizations.of(
      tester.element(find.byType(RegisterScreen)),
    )!;
  }

  group('RegisterScreen', () {
    testWidgets('should display all required fields', (tester) async {
      final robot = AuthRobot(tester);

      await pumpRegisterScreen(tester);

      robot.expectRegisterScreenVisible();
      expect(robot.fullNameField, findsOneWidget);
      expect(robot.emailField, findsOneWidget);
      expect(robot.phoneField, findsOneWidget);
      expect(robot.passwordField, findsOneWidget);
      expect(robot.confirmPasswordField, findsOneWidget);
      expect(robot.registerButton, findsOneWidget);
    });

    testWidgets('should show localized validation errors for empty fields',
        (tester) async {
      final robot = AuthRobot(tester);
      final l10n = await pumpRegisterScreen(tester);

      await tester.ensureVisible(robot.registerButton);
      await robot.tapRegister();

      robot.expectErrorText(l10n.valEmptyName);
      robot.expectErrorText(l10n.valEmptyEmail);
      robot.expectErrorText(l10n.valEmptyPassword);

      verifyNever(
        () => mockAuthService.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          fullName: any(named: 'fullName'),
          phone: any(named: 'phone'),
        ),
      );
    });

    testWidgets('should call signUp and navigate on success', (tester) async {
      final robot = AuthRobot(tester);
      final mockUser = MockUser();
      final mockResponse = MockAuthResponse();
      final completer = Completer<AuthResponse>();

      when(() => mockResponse.user).thenReturn(mockUser);
      when(
        () => mockAuthService.signUp(
          email: 'test@example.com',
          password: 'password123',
          fullName: 'Test User',
          phone: '0123456789',
        ),
      ).thenAnswer((_) => completer.future);

      await pumpRegisterScreen(tester);

      await robot.enterFullName('Test User');
      await robot.enterEmail('test@example.com');
      await robot.enterPhone('0123456789');
      await robot.enterPassword('password123');
      await robot.enterConfirmPassword('password123');

      await tester.ensureVisible(robot.registerButton);
      await robot.tapRegister();

      await tester.pump();
      robot.expectLoading(true);

      completer.complete(mockResponse);
      await tester.pumpAndSettle();

      verify(
        () => mockAuthService.signUp(
          email: 'test@example.com',
          password: 'password123',
          fullName: 'Test User',
          phone: '0123456789',
        ),
      ).called(1);

      verify(
        () => mockRouter.replaceAll(
          any(
            that: isA<List<PageRouteInfo>>().having(
              (routes) => routes.first,
              'first route',
              isA<MainWrapperRoute>(),
            ),
          ),
        ),
      ).called(1);
      verifyNever(() => mockRouter.push(any()));
    });

    testWidgets('should show snackbar on registration failure', (tester) async {
      final robot = AuthRobot(tester);

      when(
        () => mockAuthService.signUp(
          email: 'test@example.com',
          password: 'password123',
          fullName: 'Test User',
          phone: '0123456789',
        ),
      ).thenThrow(const AuthException('Email already in use'));

      await pumpRegisterScreen(tester);

      await robot.enterFullName('Test User');
      await robot.enterEmail('test@example.com');
      await robot.enterPhone('0123456789');
      await robot.enterPassword('password123');
      await robot.enterConfirmPassword('password123');

      await tester.ensureVisible(robot.registerButton);
      await robot.tapRegister();

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      verify(
        () => mockAuthService.signUp(
          email: 'test@example.com',
          password: 'password123',
          fullName: 'Test User',
          phone: '0123456789',
        ),
      ).called(1);

      verifyNever(() => mockRouter.replaceAll(any()));
      verifyNever(() => mockRouter.push(any()));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Email already in use'), findsOneWidget);
    });

    testWidgets('should navigate back to login screen when tapping Login Now',
        (tester) async {
      final robot = AuthRobot(tester);

      await pumpRegisterScreen(tester);

      await robot.tapLoginNow();

      verify(() => mockRouter.back()).called(1);
      verifyNever(() => mockRouter.push(any()));
      verifyNever(() => mockRouter.replaceAll(any()));
    });
  });
}
