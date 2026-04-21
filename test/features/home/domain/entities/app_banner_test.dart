import 'package:flutter_test/flutter_test.dart';
import 'package:pickle_pick/features/home/domain/entities/app_banner.dart';

void main() {
  group('AppBanner', () {
    const testJson = {
      'id': '1',
      'title': 'Banner Title',
      'subtitle': 'Banner Subtitle',
      'image_url': 'https://example.com/image.png',
      'action_url': '/promo',
      'action_title': 'Click Me',
      'sort_order': 1,
    };

    test('should parse JSON into AppBanner correctly', () {
      final result = AppBanner.fromJson(testJson);

      expect(result.id, '1');
      expect(result.title, 'Banner Title');
      expect(result.subtitle, 'Banner Subtitle');
      expect(result.imageUrl, 'https://example.com/image.png');
      expect(result.actionUrl, '/promo');
      expect(result.actionTitle, 'Click Me');
      expect(result.sortOrder, 1);
    });

    test('should use default sortOrder = 0 when sort_order is missing', () {
      final jsonWithoutSortOrder = Map<String, dynamic>.from(testJson)
        ..remove('sort_order');

      final result = AppBanner.fromJson(jsonWithoutSortOrder);

      expect(result.sortOrder, 0);
    });

    test('should use default sortOrder = 0 when sort_order is null', () {
      final jsonWithNullSortOrder = Map<String, dynamic>.from(testJson)
        ..['sort_order'] = null;

      final result = AppBanner.fromJson(jsonWithNullSortOrder);

      expect(result.sortOrder, 0);
    });

    test('should convert AppBanner to JSON correctly', () {
      final banner = AppBanner.fromJson(testJson);

      final result = banner.toJson();

      expect(result, {
        'id': '1',
        'title': 'Banner Title',
        'subtitle': 'Banner Subtitle',
        'image_url': 'https://example.com/image.png',
        'action_url': '/promo',
        'action_title': 'Click Me',
        'sort_order': 1,
      });
    });

    test('should support value equality', () {
      final banner1 = AppBanner.fromJson(testJson);
      final banner2 = AppBanner.fromJson(testJson);

      expect(banner1, banner2);
    });
  });
}
