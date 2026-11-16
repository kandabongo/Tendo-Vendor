import 'package:flutter/material.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/requests/provider_mobility.request.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

/// Provider Mobility settings: standing transport preference (own / taxi / either)
/// and the own-vehicle travel rate per km. The server owns the truth: it clamps the
/// rate to the admin bounds and audits the change. This view model does a light
/// client-side check purely for fast feedback, then defers to the server's answer.
class ProviderMobilityViewModel extends MyBaseViewModel {
  ProviderMobilityViewModel(BuildContext context) {
    this.viewContext = context;
  }

  final ProviderMobilityRequest _request = ProviderMobilityRequest();
  final TextEditingController rateTEC = TextEditingController();

  final List<String> transportModes = const ["own", "taxi", "either"];
  String transportMode = "own";
  double rateMin = 0;
  double rateMax = 0;
  double? effectiveRate;

  @override
  void initialise() async {
    await loadMobility();
  }

  Future<void> loadMobility() async {
    setBusy(true);
    try {
      final ApiResponse res = await _request.getMobility();
      if (res.allGood) {
        final body = res.body is Map ? res.body as Map : const {};
        transportMode = (body["transport_mode"] ?? "own").toString();
        rateMin = _toDouble(body["rate_min"]) ?? 0;
        rateMax = _toDouble(body["rate_max"]) ?? 0;
        effectiveRate = _toDouble(body["effective_rate_per_km"]);
        final rate = body["assist_travel_rate_per_km"];
        rateTEC.text = rate == null ? "" : (_toDouble(rate)?.toString() ?? "");
      } else {
        toastError(res.message);
      }
    } catch (e) {
      toastError("$e");
    }
    setBusy(false);
  }

  void setTransportMode(String? value) {
    if (value == null) return;
    transportMode = value;
    notifyListeners();
  }

  Future<void> save() async {
    double? rate;
    if (rateTEC.text.trim().isNotEmpty) {
      rate = double.tryParse(rateTEC.text.trim());
      if (rate == null || rate < 0) {
        toastError("Please enter a valid travel rate per km".tr());
        return;
      }
      if (rateMax > 0 && rate > rateMax) {
        toastError("Rate cannot exceed the maximum allowed".tr());
        return;
      }
      if (rate < rateMin) {
        toastError("Rate cannot be below the minimum allowed".tr());
        return;
      }
    }

    setBusy(true);
    try {
      final ApiResponse res = await _request.updateMobility(
        transportMode: transportMode,
        ratePerKm: rate,
      );
      if (res.allGood) {
        final body = res.body is Map ? res.body as Map : const {};
        effectiveRate = _toDouble(body["effective_rate_per_km"]) ?? effectiveRate;
        if (body["assist_travel_rate_per_km"] != null) {
          rateTEC.text =
              _toDouble(body["assist_travel_rate_per_km"])?.toString() ?? rateTEC.text;
        }
        toastSuccessful(
          res.message.isNotEmpty ? res.message : "Mobility settings updated".tr(),
        );
      } else {
        toastError(res.message);
      }
    } catch (e) {
      toastError("$e");
    }
    setBusy(false);
  }

  String modeLabel(String mode) {
    switch (mode) {
      case "taxi":
        return "Tendo Taxi".tr();
      case "either":
        return "Own vehicle or Tendo Taxi".tr();
      default:
        return "Own vehicle".tr();
    }
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
