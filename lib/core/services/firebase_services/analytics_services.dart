import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsService {
  AnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  Future<void> logScreen({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  Future<void> logDetailCourt({
    required String courtId,
    required String courtName,
  }) async {
    await _analytics.logEvent(
      name: 'detail_court_started',
      parameters: {
        'court_id': courtId,
        'court_name': courtName,
      },
    );
  }

  Future<void> logPaymentStarted({
    required String currency,
    required double value,
  }) async {
    await _analytics.logEvent(
      name: 'payment_started',
      parameters: {
        'currency': currency,
        'value': value,
      },
    );
  }

  Future<void> logPaymentSuccess({
    required String orderId,
    required String currency,
    required double value,
  }) async {
    await _analytics.logPurchase(
      transactionId: orderId,
      currency: currency,
      value: value,
    );
  }

  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  Future<void> logAddToCart({
    required String productId,
    required String productName,
    required double price,
    required int quantity,
  }) async {
    await _analytics.logEvent(
      name: 'add_to_cart',
      parameters: {
        'product_id': productId,
        'product_name': productName,
        'price': price,
        'quantity': quantity,
      },
    );
  }

  Future<void> logLogin() async {
    await _analytics.logLogin(loginMethod: 'email');
  }

  Future<void> logLogout() async {
    await _analytics.logEvent(name: 'logout');
  }
}

final analyticsProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(FirebaseAnalytics.instance);
});
