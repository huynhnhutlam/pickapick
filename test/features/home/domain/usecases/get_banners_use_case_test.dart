import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pickle_pick/core/error/failures.dart';
import 'package:pickle_pick/features/home/domain/entities/app_banner.dart';
import 'package:pickle_pick/features/home/domain/usecases/get_banners_use_case.dart';

import '../../../../shared/mocks.dart';

void main() {
  late MockHomeRepository mockHomeRepository;
  late GetBannersUseCase useCase;

  setUp(() {
    mockHomeRepository = MockHomeRepository();
    useCase = GetBannersUseCase(mockHomeRepository);
  });

  group('GetBannersUseCase', () {
    const testBanner = AppBanner(
      id: '1',
      title: 'Test',
      subtitle: 'Test',
      imageUrl: 'test',
    );

    test('should call repository.getBanners and return banners on success',
        () async {
      // Arrange
      final testBanners = [testBanner];
      when(() => mockHomeRepository.getBanners())
          .thenAnswer((_) async => right(testBanners));

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, right(testBanners));
      verify(() => mockHomeRepository.getBanners()).called(1);
      verifyNoMoreInteractions(mockHomeRepository);
    });

    test('should call repository.getBanners and return failure on error',
        () async {
      // Arrange
      const failure = ServerFailure('Lỗi');
      when(() => mockHomeRepository.getBanners())
          .thenAnswer((_) async => left(failure));

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, left(failure));
      verify(() => mockHomeRepository.getBanners()).called(1);
      verifyNoMoreInteractions(mockHomeRepository);
    });
  });
}
