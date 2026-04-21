import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pickle_pick/core/error/failures.dart';
import 'package:pickle_pick/features/home/domain/entities/app_banner.dart';
import 'package:pickle_pick/features/home/presentation/providers/home_providers.dart';

import '../../../../shared/mocks.dart';

void main() {
  group('homeBannersProvider', () {
    late MockHomeRepository mockHomeRepository;

    setUp(() {
      mockHomeRepository = MockHomeRepository();
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(mockHomeRepository),
        ],
      );
    }

    const testBanner = AppBanner(
      id: '1',
      title: 'T1',
      subtitle: 'S1',
      imageUrl: 'I1',
    );

    test(
        'should resolve with banner list and end in AsyncData when repository returns Right',
        () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final testBanners = [testBanner];
      when(() => mockHomeRepository.getBanners())
          .thenAnswer((_) async => right(testBanners));

      final result = await container.read(homeBannersProvider.future);
      final state = container.read(homeBannersProvider);

      expect(result, testBanners);
      expect(state, isA<AsyncData<List<AppBanner>>>());
      expect(state.asData!.value, testBanners);

      verify(() => mockHomeRepository.getBanners()).called(1);
      verifyNoMoreInteractions(mockHomeRepository);
    });

    test('should transition to AsyncError when repository returns Left',
        () async {
      final container = createContainer();
      addTearDown(container.dispose);

      const errorMessage = 'Failed to fetch';
      when(() => mockHomeRepository.getBanners())
          .thenAnswer((_) async => left(const ServerFailure(errorMessage)));

      await expectLater(
        container.read(homeBannersProvider.future),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains(errorMessage),
          ),
        ),
      );

      final state = container.read(homeBannersProvider);

      expect(state, isA<AsyncError<List<AppBanner>>>());
      expect(state.asError!.error.toString(), contains(errorMessage));

      verify(() => mockHomeRepository.getBanners()).called(1);
      verifyNoMoreInteractions(mockHomeRepository);
    });
  });
}
