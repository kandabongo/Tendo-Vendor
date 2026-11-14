import 'package:dio/dio.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/services/http.service.dart';

/// Sends the provider's authenticated live GPS to the backend. The server ties
/// the update to the signed-in provider (manager) account, so the correct
/// provider is always associated with the location — the app never supplies an id.
class ProviderLocationRequest extends HttpService {
  Future<Response> syncLocation({
    required double lat,
    required double lng,
    double? rotation,
  }) async {
    return await post(Api.providerLocationSync, {
      "lat": lat,
      "lng": lng,
      if (rotation != null) "rotation": rotation,
    });
  }
}
