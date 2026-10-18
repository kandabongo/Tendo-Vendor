import 'package:dio/dio.dart';
import 'package:fuodz/models/assist_invoice.dart';
import 'package:fuodz/services/http.service.dart';

/// Additional work and materials on an Assist job. The server decides every amount and every
/// permission; this class sends what the provider typed and reports the server's answer.
/// A failure is thrown as the message to show the provider.
class AssistExtrasRequest extends HttpService {
  static const String _networkMessage =
      "Please check your internet connection and try again";

  Future<AssistInvoice> getInvoice(int orderId) async {
    final response = await _run(() => get("/assist/order/$orderId/invoice"));
    if (response.statusCode == 200 && response.data is Map) {
      return AssistInvoice.fromJson(response.data);
    }
    throw _messageOf(response, "Could not load the job charges");
  }

  Future<void> requestAdditionalWork({
    required int orderId,
    required String description,
    required double amount,
  }) async {
    await _post("/assist/order/additional-work/request", {
      "order_id": orderId,
      "description": description,
      "amount": amount,
    }, "Could not send the request");
  }

  Future<void> withdrawAdditionalWork(int additionalWorkId) async {
    await _post("/assist/order/additional-work/withdraw", {
      "additional_work_id": additionalWorkId,
    }, "Could not withdraw the request");
  }

  Future<void> addMaterial({
    required int orderId,
    required String name,
    required double quantity,
    required double unitPrice,
    String? unit,
  }) async {
    await _post("/assist/order/materials/add", {
      "order_id": orderId,
      "name": name,
      "quantity": quantity,
      "unit_price": unitPrice,
      if (unit != null && unit.isNotEmpty) "unit": unit,
    }, "Could not add the item");
  }

  Future<void> removeMaterial(int materialId) async {
    await _post("/assist/order/materials/remove", {
      "material_id": materialId,
    }, "Could not remove the item");
  }

  Future<void> _post(String url, Map<String, dynamic> body, String fallback) async {
    final response = await _run(() => post(url, body));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }
    throw _messageOf(response, fallback);
  }

  Future<Response> _run(Future<Response> Function() call) async {
    try {
      return await call();
    } catch (_) {
      throw _networkMessage;
    }
  }

  String _messageOf(Response response, String fallback) {
    final data = response.data;
    if (data is Map && "${data["message"] ?? ""}".isNotEmpty) {
      return "${data["message"]}";
    }
    return fallback;
  }
}
