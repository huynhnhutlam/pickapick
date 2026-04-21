import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pickle_pick/core/enum/quick_action_type_enum.dart';
import 'package:pickle_pick/core/error/failures.dart';
import 'package:pickle_pick/core/keys/app_keys.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/features/booking/domain/entities/court.dart';
import 'package:pickle_pick/features/booking/presentation/providers/court_providers.dart';
import 'package:pickle_pick/features/home/domain/entities/app_banner.dart';
import 'package:pickle_pick/features/home/presentation/providers/home_providers.dart';
import 'package:pickle_pick/features/home/presentation/screens/home_screen.dart';
import 'package:pickle_pick/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:pickle_pick/features/shop/domain/entities/product.dart';

import '../../../../shared/mocks.dart';
import '../../../../test_helper.dart';
import '../robots/home_robot.dart';

void main() {
  late MockHomeRepository mockHomeRepository;
  late MockCourtRepository mockCourtRepository;
  late MockShopRepository mockShopRepository;
  late MockStackRouter mockRouter;

  setUpAll(() {
    registerFallbackValue(const BookingRoute());
    registerFallbackValue(const ShopRoute());
    registerFallbackValue(CourtDetailRoute(courtId: ''));
    registerFallbackValue(
      ProductDetailsRoute(
        product: const Product(
          id: '',
          title: '',
          description: '',
          images: [],
          price: 0,
          category: '',
          variants: [],
          rating: 0,
          reviews: 0,
          isFavorite: false,
          stock: 0,
        ),
      ),
    );
  });

  setUp(() async {
    mockHomeRepository = MockHomeRepository();
    mockCourtRepository = MockCourtRepository();
    mockShopRepository = MockShopRepository();
    mockRouter = MockStackRouter();

    when(() => mockRouter.push(any())).thenAnswer((_) async => null);
  });

  Future<void> pumpHomeScreen(
    WidgetTester tester, {
    StackRouter? router,
  }) async {
    // Correct way to set surface size in modern Flutter tests
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());

    await tester.pumpTestApp(
      const HomeScreen(),
      overrides: [
        homeRepositoryProvider.overrideWithValue(mockHomeRepository),
        courtRepositoryProvider.overrideWithValue(mockCourtRepository),
        shopRepositoryProvider.overrideWithValue(mockShopRepository),
      ],
      router: router,
    );
    // Wait for providers and staggered animations to complete
    await tester.pumpAndSettle();
  }

  group('HomeScreen render', () {
    testWidgets('should display main home sections on successful build',
        (tester) async {
      final robot = HomeRobot(tester);

      when(() => mockHomeRepository.getBanners())
          .thenAnswer((_) async => right([]));

      await pumpHomeScreen(tester);

      robot.expectHomeHeaderVisible();
      robot.expectSearchBarVisible();
      robot.expectBannerVisible();
      robot.expectQuickActionsVisible();
      robot.expectFeaturedCourtsVisible();
      robot.expectFeaturedProductsVisible();

      verify(() => mockHomeRepository.getBanners()).called(1);
      verifyNoMoreInteractions(mockHomeRepository);
    });

    testWidgets('should render banner content when fetch succeeds',
        (tester) async {
      final robot = HomeRobot(tester);
      final testBanners = [
        const AppBanner(
          id: '1',
          title: 'Banner 1',
          subtitle: 'Subtitle 1',
          imageUrl: 'https://example.com/1.png',
          sortOrder: 1,
        ),
      ];

      when(() => mockHomeRepository.getBanners())
          .thenAnswer((_) async => right(testBanners));

      await pumpHomeScreen(tester);

      robot.expectBannerVisible();
      robot.expectBannerItemVisible(0);

      expect(find.text('Banner 1'), findsOneWidget);
      expect(find.text('Subtitle 1'), findsOneWidget);

      verify(() => mockHomeRepository.getBanners()).called(1);
      verifyNoMoreInteractions(mockHomeRepository);
    });

    testWidgets('should hide banner page view when fetch fails',
        (tester) async {
      when(() => mockHomeRepository.getBanners())
          .thenAnswer((_) async => left(const ServerFailure('Error')));

      await pumpHomeScreen(tester);

      expect(find.byKey(WidgetKeys.homeBannerPageView), findsNothing);

      verify(() => mockHomeRepository.getBanners()).called(1);
      verifyNoMoreInteractions(mockHomeRepository);
    });
  });

  group('HomeScreen navigation', () {
    testWidgets('should navigate to BookingRoute when banner action is tapped',
        (tester) async {
      final robot = HomeRobot(tester);
      final testBanners = [
        const AppBanner(
          id: '1',
          title: 'Banner 1',
          subtitle: 'Subtitle 1',
          imageUrl: 'test',
          actionUrl: 'booking',
        ),
      ];

      when(() => mockHomeRepository.getBanners())
          .thenAnswer((_) async => right(testBanners));

      await pumpHomeScreen(tester, router: mockRouter);

      await robot.tapBannerAction(0);

      verify(() => mockRouter.push(any(that: isA<BookingRoute>()))).called(1);
      verifyNoMoreInteractions(mockRouter);
      verify(() => mockHomeRepository.getBanners()).called(1);
      verifyNoMoreInteractions(mockHomeRepository);
    });

    testWidgets(
        'should navigate to BookingRoute when nearby quick action is tapped',
        (tester) async {
      final robot = HomeRobot(tester);

      when(() => mockHomeRepository.getBanners())
          .thenAnswer((_) async => right([]));

      await pumpHomeScreen(tester, router: mockRouter);

      // Nearby quick action is currently expected to be at index 0.
      await robot.tapQuickAction(QuickActionType.nearby);

      verify(() => mockRouter.push(any(that: isA<BookingRoute>()))).called(1);
      verifyNoMoreInteractions(mockRouter);
      verify(() => mockHomeRepository.getBanners()).called(1);
      verifyNoMoreInteractions(mockHomeRepository);
    });

    testWidgets('should navigate to BookingRoute when search bar is tapped',
        (tester) async {
      final robot = HomeRobot(tester);

      when(() => mockHomeRepository.getBanners())
          .thenAnswer((_) async => right([]));
      when(() => mockCourtRepository.getCourts())
          .thenAnswer((_) async => right([]));
      when(() => mockShopRepository.getFeaturedProducts())
          .thenAnswer((_) async => []);

      await pumpHomeScreen(tester, router: mockRouter);

      await robot.tapSearchBar();

      verify(() => mockRouter.push(any(that: isA<BookingRoute>()))).called(1);
      verifyNoMoreInteractions(mockRouter);
    });

    testWidgets(
        'should navigate to BookingRoute when featured courts see all is tapped',
        (tester) async {
      final robot = HomeRobot(tester);
      when(() => mockHomeRepository.getBanners())
          .thenAnswer((_) async => right([]));
      when(() => mockCourtRepository.getCourts())
          .thenAnswer((_) async => right([]));
      when(() => mockShopRepository.getFeaturedProducts())
          .thenAnswer((_) async => []);

      await pumpHomeScreen(tester, router: mockRouter);

      await robot.tapFeaturedCourtsSeeAll();

      verify(() => mockRouter.push(any(that: isA<BookingRoute>()))).called(1);
    });

    testWidgets(
        'should navigate to ShopRoute when featured products see all is tapped',
        (tester) async {
      final robot = HomeRobot(tester);
      when(() => mockHomeRepository.getBanners())
          .thenAnswer((_) async => right([]));
      when(() => mockCourtRepository.getCourts())
          .thenAnswer((_) async => right([]));
      when(() => mockShopRepository.getFeaturedProducts())
          .thenAnswer((_) async => []);

      await pumpHomeScreen(tester, router: mockRouter);

      await robot.tapFeaturedProductsSeeAll();
      verify(() => mockRouter.push(any(that: isA<ShopRoute>()))).called(1);
    });

    testWidgets(
        'should navigate to CourtDetailRoute when a court card is tapped',
        (tester) async {
      final robot = HomeRobot(tester);
      final testCourts = [
        const Court(
          id: 'court-1',
          name: 'Court 1',
          address: 'Address 1',
          images: ['https://example.com/court1.png'],
          pricePerHour: 100,
          rating: 4.5,
          reviewCount: 10,
          description: 'Desc',
          amenities: [],
          rules: [],
          openingHours: '8-22',
        ),
      ];

      when(() => mockHomeRepository.getBanners())
          .thenAnswer((_) async => right([]));
      when(() => mockCourtRepository.getCourts())
          .thenAnswer((_) async => right(testCourts));
      when(() => mockShopRepository.getFeaturedProducts())
          .thenAnswer((_) async => []);

      await pumpHomeScreen(tester, router: mockRouter);

      await robot.tapFeaturedCourt('court-1');

      verify(() => mockRouter.push(any(that: isA<CourtDetailRoute>())))
          .called(1);
    });

    testWidgets(
        'should navigate to ProductDetailsRoute when a product card is tapped',
        (tester) async {
      final robot = HomeRobot(tester);
      final testProducts = [
        const Product(
          id: 'prod-1',
          title: 'Product 1',
          description: 'Desc',
          images: ['https://example.com/p1.png'],
          price: 100000,
          category: 'Balls',
          variants: [],
          rating: 4.8,
          reviews: 20,
          isFavorite: false,
          stock: 10,
        ),
      ];

      when(() => mockHomeRepository.getBanners())
          .thenAnswer((_) async => right([]));
      when(() => mockCourtRepository.getCourts())
          .thenAnswer((_) async => right([]));
      when(() => mockShopRepository.getFeaturedProducts())
          .thenAnswer((_) async => testProducts);

      await pumpHomeScreen(tester, router: mockRouter);

      await robot.tapFeaturedProduct('prod-1');

      verify(() => mockRouter.push(any(that: isA<ProductDetailsRoute>())))
          .called(1);
    });
  });
}
