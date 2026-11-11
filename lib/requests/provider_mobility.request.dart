import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/services/http.service.dart';

/// Assist Provider Mobility API.
///
/// Server-authoritative: the backend clamps the travel rate to the admin bounds,
/// computes the travel allowance from trusted coordinates, and owns all commission
/// maths. This class only sends requests and returns the parsed [ApiResponse];
/// nothing financial is calculated locally.
///
/// Mutating per-job calls (elect own / link taxi / unlink) are guarded against
/// duplicate submissions by an in-flight set keyed on the order id, so a repeated
/// button press cannot create a second transport record or a duplicate booking link.
class ProviderMobilityRequest extends HttpService {
  static final Set<int> _inFlight = <int>{};

  /// Current provider mobility configuration + admin bounds.
  /// body: { transport_mode, assist_travel_rate_per_km, effective_rate_per_km, rate_min, rate_max }
  Future<ApiResponse> getMobility() async {
    final apiResult = await get(Api.assistProviderMobility);
    return ApiResponse.fromResponse(apiResult);
  }

  /// Update the standing transport preference and/or own-vehicle rate per km.
  /// The server clamps the rate into [rate_min, rate_max] and audits the change.
  Future<ApiResponse> updateMobility({
    String? transportMode,
    double? ratePerKm,
  }) async {
    final body = <String, dynamic>{};
    if (transportMode != null) body["transport_mode"] = transportMode;
    if (ratePerKm != null) body["assist_travel_rate_per_km"] = ratePerKm;
    final apiResult = await post(Api.assistProviderMobility, body);
    return ApiResponse.fromResponse(apiResult);
  }

  /// Elect own-vehicle transport for a job. The server stamps the allowance.
  Future<ApiResponse> electOwnVehicle(int orderId) async {
    return _guarded(orderId, () async {
      final apiResult = await post(Api.assistTransportOwn, {"order_id": orderId});
      return ApiResponse.fromResponse(apiResult);
    });
  }

  /// Link a Tendo Taxi booking (made through the existing taxi flow) to the job.
  Future<ApiResponse> linkTaxi(int orderId, int taxiOrderId) async {
    return _guarded(orderId, () async {
      final apiResult = await post(Api.assistTransportTaxiLink, {
        "order_id": orderId,
        "taxi_order_id": taxiOrderId,
      });
      return ApiResponse.fromResponse(apiResult);
    });
  }

  /// Clear the transport selection (fallback / switch away from taxi).
  Future<ApiResponse> unlinkTaxi(int orderId) async {
    return _guarded(orderId, () async {
      final apiResult = await post(Api.assistTransportTaxiUnlink, {"order_id": orderId});
      return ApiResponse.fromResponse(apiResult);
    });
  }

  /// Quotation breakdown for a job: service_charge, travel_allowance/taxi, total_payable.
  Future<ApiResponse> transportQuote(int orderId) async {
    final apiResult = await get(Api.assistTransportQuote(orderId));
    return ApiResponse.fromResponse(apiResult);
  }

  /// Runs [action] only if no mutating call for [orderId] is already in flight,
  /// preventing a double booking / duplicate transport charge from repeated taps.
  Future<ApiResponse> _guarded(
    int orderId,
    Future<ApiResponse> Function() action,
  ) async {
    if (!_inFlight.add(orderId)) {
      return ApiResponse(
        code: 409,
        message: "Please wait - your previous request is still processing.",
        body: const {},
        errors: const ["IN_FLIGHT"],
      );
    }
    try {
      return await action();
    } finally {
      _inFlight.remove(orderId);
    }
  }
}
