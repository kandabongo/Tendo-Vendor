import 'package:flutter_test/flutter_test.dart';
import 'package:fuodz/constants/api.dart';

/// Pure-Dart contract tests for the Assist Provider Mobility endpoints. These run
/// under `flutter test` without a device or network and guard the API paths the
/// provider app calls against the backend routes.
void main() {
  group('Assist mobility API endpoints', () {
    test('mobility and transport endpoints match the backend routes', () {
      expect(Api.assistProviderMobility, '/assist/provider/mobility');
      expect(Api.assistTransportOwn, '/assist/order/transport/own');
      expect(Api.assistTransportTaxiLink, '/assist/order/transport/taxi/link');
      expect(Api.assistTransportTaxiUnlink, '/assist/order/transport/taxi/unlink');
    });

    test('quote path builder embeds the order id', () {
      expect(Api.assistTransportQuote(42), '/assist/order/42/transport/quote');
      expect(Api.assistTransportQuote(1), '/assist/order/1/transport/quote');
    });
  });
}
