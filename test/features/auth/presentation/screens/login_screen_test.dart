import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/core/services/firebase_services/analytics_services.dart';
import 'package:pickle_pick/features/auth/data/auth_service.dart';
import 'package:pickle_pick/features/auth/presentation/providers/auth_providers.dart';
import 'package:pickle_pick/features/auth/presentation/screens/login_screen.dart';
import 'package:pickle_pick/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../test_helper.dart';
import '../robots/auth_robot.dart';

class MockAuthService extends Mock implements AuthService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockStackRouter extends Mock implements StackRouter {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockUser extends Mock implements User {}

void main() {
  late MockAuthService mockAuthService;
  late MockAnalyticsService mockAnalyticsService;
  late MockStackRouter mockRouter;

  setUpAll(() {
    registerFallbackValue(const RegisterRoute());
    registerFallbackValue(const MainWrapperRoute());
    registerFallbackValue(FakePageRouteInfo());
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockAnalyticsService = MockAnalyticsService();
    mockRouter = MockStackRouter();

    when(() => mockAuthService.currentUser).thenReturn(null);
    when(() => mockAuthService.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockRouter.push(any())).thenAnswer((_) async => null);
    when(() => mockRouter.replaceAll(any())).thenAnswer((_) async {});
    when(() => mockAnalyticsService.logLogin()).thenAnswer((_) async {});
  });

  Future<AppLocalizations> pumpLoginScreen(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpTestApp(
      const LoginScreen(),
      locale: locale,
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
        analyticsProvider.overrideWithValue(mockAnalyticsService),
      ],
      router: mockRouter,
      settle: true,
    );

    return AppLocalizations.of(
      tester.element(find.byType(LoginScreen)),
    )!;
  }

  group('LoginScreen', () {
    testWidgets('should display email and password fields', (tester) async {
      final robot = AuthRobot(tester);

      await pumpLoginScreen(tester);

      robot.expectLoginScreenVisible();
      expect(robot.emailField, findsOneWidget);
      expect(robot.passwordField, findsOneWidget);
      expect(robot.loginButton, findsOneWidget);
    });

    testWidgets('should show localized validation errors for empty fields',
        (tester) async {
      final robot = AuthRobot(tester);
      final l10n = await pumpLoginScreen(tester);

      await robot.tapLogin();

      robot.expectErrorText(l10n.valEmptyEmail);
      robot.expectErrorText(l10n.valEmptyPassword);

      verifyNever(
        () => mockAuthService.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('should show localized error for invalid email format',
        (tester) async {
      final robot = AuthRobot(tester);
      final l10n = await pumpLoginScreen(tester);

      await robot.enterEmail('invalid-email');
      await robot.tapLogin();

      robot.expectErrorText(l10n.valInvalidEmail);

      verifyNever(
        () => mockAuthService.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('should call signIn and navigate on success', (tester) async {
      final robot = AuthRobot(tester);
      final mockUser = MockUser();
      final mockResponse = MockAuthResponse();
      final completer = Completer<AuthResponse>();

      when(() => mockResponse.user).thenReturn(mockUser);
      when(
        () => mockAuthService.signIn(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) => completer.future);

      await pumpLoginScreen(tester);

      await robot.enterEmail('test@example.com');
      await robot.enterPassword('password123');

      await tester.ensureVisible(robot.loginButton);
      await robot.tapLogin();

      await tester.pump();
      robot.expectLoading(true);

      completer.complete(mockResponse);
      await tester.pumpAndSettle();

      verify(
        () => mockAuthService.signIn(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
      verify(() => mockAnalyticsService.logLogin()).called(1);
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
    });

    testWidgets('should show snackbar on login failure', (tester) async {
      final robot = AuthRobot(tester);

      when(
        () => mockAuthService.signIn(
          email: 'test@example.com',
          password: 'wrongpass',
        ),
      ).thenThrow(const AuthException('Invalid credentials'));

      await pumpLoginScreen(tester);

      await robot.enterEmail('test@example.com');
      await robot.enterPassword('wrongpass');

      await tester.ensureVisible(robot.loginButton);
      await robot.tapLogin();

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      verify(
        () => mockAuthService.signIn(
          email: 'test@example.com',
          password: 'wrongpass',
        ),
      ).called(1);

      verifyNever(() => mockAnalyticsService.logLogin());
      verifyNever(() => mockRouter.replaceAll(any()));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('should navigate to register screen when tapping Register Now',
        (tester) async {
      final robot = AuthRobot(tester);

      await pumpLoginScreen(tester);

      await robot.tapRegisterNow();

      verify(() => mockRouter.push(any(that: isA<RegisterRoute>()))).called(1);
    });
  });
}
