import 'package:dio/dio.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/requests/order.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/http.service.dart';

/// What happened when the provider tried to accept or decline an Assist job offer.
enum AssistJobOutcome {
  /// The job is now assigned to this provider.
  accepted,

  /// The offer was released (declined).
  declined,

  /// Wallet cannot cover the commission. The server released the offer to the next provider.
  insufficientBalance,

  /// Offer expired, was taken by another provider, or the job is no longer open.
  unavailable,

  /// The request never reached the server (or no answer came back). Safe to try again.
  networkError,

  /// Any other server-side refusal.
  failed,
}

class AssistJobResult {
  AssistJobResult(this.outcome, this.message, {this.order});

  final AssistJobOutcome outcome;
  final String message;

  /// The up-to-date job when the server confirmed an acceptance.
  final Order? order;

  bool get isSuccess =>
      outcome == AssistJobOutcome.accepted ||
      outcome == AssistJobOutcome.declined;

  /// The offer is finished for this provider - the screen showing it should close.
  bool get isFinal =>
      outcome != AssistJobOutcome.networkError &&
      outcome != AssistJobOutcome.failed;
}

/// Accept / decline of a dispatched Assist job offer.
///
/// The server alone decides: it checks the wallet, claims the offer, assigns the provider and
/// guarantees that exactly one provider can win a job. This class only sends the request and
/// turns the answer into an [AssistJobResult]. Nothing is calculated or assumed locally.
class AssistJobRequest extends HttpService {
  /// Server code for a wallet that cannot cover the commission.
  static const String insufficientBalanceCode = 'INSUFFICIENT_BALANCE';

  /// Wording agreed for providers. Used only if the server sends no message.
  static const String insufficientBalanceMessage =
      "Insufficient balance. Please top up your wallet to accept this job.";

  static const String _networkMessage =
      "Please check your internet connection and try again";

  /// Jobs with a request currently on the wire: blocks repeated button presses.
  static final Set<int> _inFlight = <int>{};

  Future<AssistJobResult> acceptJob(int orderId) async {
    if (!_inFlight.add(orderId)) {
      return AssistJobResult(AssistJobOutcome.failed, "");
    }
    try {
      final response = await _send(Api.assistAcceptAssignment, orderId);
      if (response == null) {
        return _afterNoAnswer(orderId);
      }

      final body = response.data is Map ? response.data as Map : const {};
      final message = (body["message"] ?? "").toString();

      if (response.statusCode == 200) {
        Order? job = await _fetchJob(orderId);
        if (job == null && body["order"] is Map) {
          try {
            job = Order.fromJson(body["order"]);
          } catch (_) {}
        }
        return AssistJobResult(AssistJobOutcome.accepted, message, order: job);
      }

      if (body["code"] == insufficientBalanceCode) {
        return AssistJobResult(
          AssistJobOutcome.insufficientBalance,
          message.isNotEmpty ? message : insufficientBalanceMessage,
        );
      }

      // Refused for another reason (offer expired, taken by someone else...). If a repeated
      // press or a lost response means the job is in fact ours, say so instead of an error.
      final mine = await _ownedByMe(orderId);
      if (mine != null) {
        return AssistJobResult(AssistJobOutcome.accepted, "", order: mine);
      }

      final status = response.statusCode ?? 0;
      return AssistJobResult(
        status >= 500 ? AssistJobOutcome.failed : AssistJobOutcome.unavailable,
        message,
      );
    } finally {
      _inFlight.remove(orderId);
    }
  }

  Future<AssistJobResult> declineJob(int orderId) async {
    if (!_inFlight.add(orderId)) {
      return AssistJobResult(AssistJobOutcome.failed, "");
    }
    try {
      final response = await _send(Api.assistRejectAssignment, orderId);
      if (response == null) {
        return AssistJobResult(AssistJobOutcome.networkError, _networkMessage);
      }
      final body = response.data is Map ? response.data as Map : const {};
      final message = (body["message"] ?? "").toString();

      if (response.statusCode == 200) {
        return AssistJobResult(AssistJobOutcome.declined, message);
      }
      // "No longer available": the offer already expired or was released. Nothing to decline.
      return AssistJobResult(AssistJobOutcome.unavailable, message);
    } finally {
      _inFlight.remove(orderId);
    }
  }

  /// POST { order_id }. Returns null when no answer could be obtained.
  Future<Response?> _send(String url, int orderId) async {
    try {
      return await post(url, {"order_id": orderId});
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// The request may have been processed even though no answer arrived. Look at the job
  /// before reporting a failure.
  Future<AssistJobResult> _afterNoAnswer(int orderId) async {
    final mine = await _ownedByMe(orderId);
    if (mine != null) {
      return AssistJobResult(AssistJobOutcome.accepted, "", order: mine);
    }
    return AssistJobResult(AssistJobOutcome.networkError, _networkMessage);
  }

  /// The job, when it is assigned to the signed-in provider; otherwise null.
  Future<Order?> _ownedByMe(int orderId) async {
    try {
      final order = await _fetchJob(orderId);
      final me = (await AuthServices.getCurrentUser()).vendor_id;
      if (order != null && me != null && order.vendorId == me) {
        return order;
      }
    } catch (_) {}
    return null;
  }

  Future<Order?> _fetchJob(int orderId) async {
    try {
      return await OrderRequest().getOrderDetails(id: orderId);
    } catch (_) {
      return null;
    }
  }
}
