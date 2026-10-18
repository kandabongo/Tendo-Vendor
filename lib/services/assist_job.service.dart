import 'package:fuodz/requests/assist_job.request.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

/// Runs an Assist accept / decline and tells the provider what happened.
/// Shared by the ringing alert and the order details page so both behave identically.
class AssistJobService {
  /// Accept the offer. The caller decides what to do next from the returned result
  /// (see [AssistJobResult.isFinal]); the message to the provider is already shown.
  static Future<AssistJobResult> accept(int orderId) async {
    final result = await AssistJobRequest().acceptJob(orderId);

    switch (result.outcome) {
      case AssistJobOutcome.accepted:
        ToastService.toastSuccessful("Job accepted".tr());
        break;
      case AssistJobOutcome.insufficientBalance:
        // A dialog rather than a toast: the provider has to act (top up) to get jobs.
        await AlertService.error(
          title: "Cannot accept this job".tr(),
          text: result.message.isNotEmpty
              ? result.message
              : AssistJobRequest.insufficientBalanceMessage.tr(),
        );
        break;
      case AssistJobOutcome.unavailable:
        ToastService.toastError(
          result.message.isNotEmpty
              ? result.message
              : "This job is no longer available".tr(),
        );
        break;
      case AssistJobOutcome.networkError:
      case AssistJobOutcome.failed:
        // A blank message means "already being processed" (repeated tap): stay quiet.
        if (result.message.isNotEmpty) {
          ToastService.toastError(result.message);
        }
        break;
      case AssistJobOutcome.declined:
        break;
    }
    return result;
  }

  /// Decline the offer; dispatch carries on to the next eligible provider.
  static Future<AssistJobResult> decline(int orderId) async {
    final result = await AssistJobRequest().declineJob(orderId);

    switch (result.outcome) {
      case AssistJobOutcome.declined:
        ToastService.toastSuccessful("Job declined".tr());
        break;
      case AssistJobOutcome.unavailable:
        // Already expired or released - nothing left to decline.
        ToastService.toastError(
          result.message.isNotEmpty
              ? result.message
              : "This job offer is no longer available".tr(),
        );
        break;
      default:
        if (result.message.isNotEmpty) {
          ToastService.toastError(result.message);
        }
    }
    return result;
  }
}
