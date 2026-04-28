import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pickle_pick/features/auth/data/auth_service.dart';
import 'package:pickle_pick/features/auth/presentation/providers/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAuthService extends Mock implements AuthService {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockUser extends Mock implements User {}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('AuthNotifier', () {
    test('initial state is currentUser from service', () async {
      final mockUser = MockUser();
      when(() => mockAuthService.currentUser).thenReturn(mockUser);
      when(() => mockAuthService.authStateChanges)
          .thenAnswer((_) => const Stream.empty());

      final container = makeContainer();
      final listener = Listener<AsyncValue<User?>>();

      container.listen(
        authNotifierProvider,
        listener.call,
        fireImmediately: true,
      );

      final state = await container.read(authNotifierProvider.future);
      expect(state, mockUser);
    });

    test('signIn success updates state with user', () async {
      final mockUser = MockUser();
      final mockResponse = MockAuthResponse();
      when(() => mockResponse.user).thenReturn(mockUser);
      when(() => mockAuthService.currentUser).thenReturn(null);
      when(() => mockAuthService.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(
        () => mockAuthService.signIn(
          email: 'test@example.com',
          password: 'password',
        ),
      ).thenAnswer((_) async => mockResponse);

      final container = makeContainer();
      final notifier = container.read(authNotifierProvider.notifier);

      await notifier.signIn(email: 'test@example.com', password: 'password');

      final state = container.read(authNotifierProvider);
      expect(state.value, mockUser);
      verify(
        () => mockAuthService.signIn(
          email: 'test@example.com',
          password: 'password',
        ),
      ).called(1);
    });

    test('signIn failure sets error state', () async {
      const exception = AuthException('Invalid credentials');
      when(() => mockAuthService.currentUser).thenReturn(null);
      when(() => mockAuthService.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(
        () => mockAuthService.signIn(
          email: 'test@example.com',
          password: 'wrong',
        ),
      ).thenThrow(exception);

      final container = makeContainer();
      final notifier = container.read(authNotifierProvider.notifier);

      await notifier.signIn(email: 'test@example.com', password: 'wrong');

      final state = container.read(authNotifierProvider);
      expect(state.hasError, true);
      expect(state.error, exception);
    });

    test('signOut clears user state', () async {
      final mockUser = MockUser();
      when(() => mockAuthService.currentUser).thenReturn(mockUser);
      when(() => mockAuthService.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockAuthService.signOut()).thenAnswer((_) async {});

      final container = makeContainer();
      final notifier = container.read(authNotifierProvider.notifier);

      await notifier.signOut();

      final state = container.read(authNotifierProvider);
      expect(state.value, null);
      verify(() => mockAuthService.signOut()).called(1);
    });
  });
}

class Listener<T> extends Mock {
  void call(T? previous, T next);
}
