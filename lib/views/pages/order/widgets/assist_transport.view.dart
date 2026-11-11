import 'package:flutter/material.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/requests/provider_mobility.request.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

/// Provider-side transport panel for an Assist job.
///
/// Shows how the provider will attend the job (own vehicle / Tendo Taxi), the server-computed
/// travel allowance and any linked taxi booking, and lets the provider elect own vehicle or
/// link a Tendo Taxi booking. All figures come from the server transport quote; nothing is
/// computed locally, and the requests are guarded against duplicate submissions.
///
/// Note: the Vendor app has no in-app taxi booking screen, so "Use Tendo Taxi" links an
/// existing Tendo Taxi booking by its number. Full in-app booking needs the taxi module.
class AssistTransportView extends StatefulWidget {
  const AssistTransportView({required this.order, Key? key}) : super(key: key);

  final Order order;

  @override
  State<AssistTransportView> createState() => _AssistTransportViewState();
}

class _AssistTransportViewState extends State<AssistTransportView> {
  final ProviderMobilityRequest _request = ProviderMobilityRequest();

  bool _loading = true;
  bool _working = false;
  String? _error;
  Map _quote = const {};

  @override
  void initState() {
    super.initState();
    _loadQuote();
  }

  Future<void> _loadQuote() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _request.transportQuote(widget.order.id);
      if (res.allGood && res.body is Map) {
        _quote = res.body as Map;
      } else {
        _error = res.message;
      }
    } catch (e) {
      _error = "$e";
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _run(Future Function() action) async {
    if (_working) return;
    setState(() => _working = true);
    try {
      final res = await action();
      if (res.allGood) {
        await _loadQuote();
      } else {
        setState(() => _error = res.message);
      }
    } catch (e) {
      setState(() => _error = "$e");
    }
    if (mounted) setState(() => _working = false);
  }

  Future<void> _linkTaxiDialog() async {
    final controller = TextEditingController();
    final taxiId = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Link Tendo Taxi".tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Book your ride in Tendo Taxi, then enter the booking/trip number here to link it to this job."
                    .tr(),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Taxi booking number".tr(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text("Cancel".tr()),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(int.tryParse(controller.text.trim())),
              child: Text("Link".tr()),
            ),
          ],
        );
      },
    );
    if (taxiId != null) {
      await _run(() => _request.linkTaxi(widget.order.id, taxiId));
    }
  }

  String _money(dynamic v) {
    final d = v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;
    return d.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final mode = _quote["transport_mode"]?.toString();
    final travel = _money(_quote["travel_allowance"]);
    final service = _money(_quote["service_charge"]);
    final total = _money(_quote["total_payable"]);
    final linkedTaxi = _quote["linked_taxi_order_id"];

    final List<Widget> children = [
      Text("Transport".tr(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      _row("Service charge".tr(), "K$service"),
      if (mode == "own") _row("Travel allowance (own vehicle)".tr(), "K$travel"),
      if (mode == "taxi")
        _row("Linked taxi booking".tr(),
            linkedTaxi == null ? "-" : "#$linkedTaxi"),
      const Divider(),
      _row("Total payable (Assist)".tr(), "K$total", bold: true),
      if (mode == "taxi")
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "Taxi fare is paid separately through the taxi booking.".tr(),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ),
      const SizedBox(height: 12),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(_error!,
              style: const TextStyle(color: Colors.red, fontSize: 13)),
        ),
      Row(
        children: [
          Expanded(
            child: CustomButton(
              title: "Use Own Vehicle".tr(),
              loading: _working,
              onPressed: () =>
                  _run(() => _request.electOwnVehicle(widget.order.id)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              title: "Use Tendo Taxi".tr(),
              loading: _working,
              onPressed: _linkTaxiDialog,
            ),
          ),
        ],
      ),
      if (mode != null)
        TextButton(
          onPressed: _working
              ? null
              : () => _run(() => _request.unlinkTaxi(widget.order.id)),
          child: Text("Clear transport selection".tr(),
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ),
    ];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
