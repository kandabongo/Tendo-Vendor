import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/services/http.service.dart';

class BookingRequest extends HttpService {
  //
  Future<Order> updateHandler(int id, String status) async {
    final apiResult = await post(
      Api.propertyBookingStatus.replaceAll("{id}", "$id"),
      {"status": status},
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      if (apiResponse.body["order"] != null) {
        return Order.fromJson(apiResponse.body["order"]);
      }
      return Order.fromJson(apiResponse.body);
    }
    throw apiResponse.message;
  }

  Future<Order> updateBookingStatus(
    int id,
    String status, {
    String? code,
  }) async {
    final apiResult = await post(
      Api.propertyBookingStatus.replaceAll("{id}", "$id"),
      {"status": status, "verification_code": code},
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      if (apiResponse.body["order"] != null) {
        return Order.fromJson(apiResponse.body["order"]);
      }
      return Order.fromJson(apiResponse.body);
    }
    throw apiResponse.message;
  }
}
