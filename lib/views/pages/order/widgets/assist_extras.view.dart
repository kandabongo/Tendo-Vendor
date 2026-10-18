import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/assist_invoice.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/requests/assist_extras.request.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

/// Job charges for an Assist job, with the two things a provider can add on site:
/// additional work (needs the customer's approval before it counts) and materials.
/// Every figure shown comes from the server.
class AssistExtrasView extends StatefulWidget {
  const AssistExtrasView({required this.order, Key? key}) : super(key: key);

  final Order order;

  @override
  State<AssistExtrasView> createState() => _AssistExtrasViewState();
}

class _AssistExtrasViewState extends State<AssistExtrasView> {
  final AssistExtrasRequest _request = AssistExtrasRequest();

  AssistInvoice? _invoice;
  String? _error;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final invoice = await _request.getInvoice(widget.order.id);
      if (!mounted) return;
      setState(() {
        _invoice = invoice;
        _error = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = "$error";
        _loading = false;
      });
    }
  }

  String _money(double amount) =>
      "${AppStrings.currencySymbol} ${amount.toStringAsFixed(2)}";

  /// Runs one change, then reloads the figures from the server.
  Future<bool> _change(Future<void> Function() action, String doneMessage) async {
    if (_busy) return false; //repeated taps
    setState(() => _busy = true);
    bool ok = false;
    try {
      await action();
      ToastService.toastSuccessful(doneMessage);
      ok = true;
    } catch (error) {
      ToastService.toastError("$error");
    }
    await _load();
    if (mounted) setState(() => _busy = false);
    return ok;
  }

  Widget _row(String label, String value, {bool bold = false, Color? color}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: bold ? 16 : 14,
      color: color,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color = Colors.orange;
    String text = "Waiting for customer".tr();
    if (status == "approved") {
      color = Colors.green;
      text = "Approved".tr();
    } else if (status == "rejected") {
      color = Colors.red;
      text = "Rejected".tr();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final invoice = _invoice;
    if (invoice == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Job charges".tr(), style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(_error ?? "", style: const TextStyle(color: Colors.red)),
          TextButton(onPressed: _load, child: Text("Retry".tr())),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Job charges".tr(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        _row("Service".tr(), _money(invoice.service)),
        if (invoice.additionalWork > 0)
          _row("Additional work".tr(), _money(invoice.additionalWork)),
        if (invoice.additionalWorkPending > 0)
          _row(
            "Waiting for customer".tr(),
            _money(invoice.additionalWorkPending),
            color: Colors.orange,
          ),
        if (invoice.materials > 0) _row("Materials".tr(), _money(invoice.materials)),
        if (invoice.transport > 0) _row("Transport".tr(), _money(invoice.transport)),
        const Divider(),
        _row("Total".tr(), _money(invoice.total), bold: true),
        if (invoice.commission != null)
          _row(
            "Tendo commission".tr(),
            _money(invoice.commission!),
            color: Colors.grey,
          ),

        //additional work requests
        if (invoice.extraWorkItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text("Additional work".tr(), style: const TextStyle(fontWeight: FontWeight.w600)),
          for (final work in invoice.extraWorkItems)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(work.description),
                        const SizedBox(height: 2),
                        _statusChip(work.status),
                      ],
                    ),
                  ),
                  Text(_money(work.amount)),
                  if (work.isPending && !invoice.locked)
                    IconButton(
                      tooltip: "Withdraw".tr(),
                      icon: const Icon(Icons.close, size: 20),
                      onPressed:
                          _busy
                              ? null
                              : () => _change(
                                () => _request.withdrawAdditionalWork(work.id),
                                "Request withdrawn".tr(),
                              ),
                    ),
                ],
              ),
            ),
        ],

        //materials
        if (invoice.materialItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text("Materials".tr(), style: const TextStyle(fontWeight: FontWeight.w600)),
          for (final item in invoice.materialItems)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${item.name} (${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 2)}"
                      "${item.unit.isNotEmpty ? " ${item.unit}" : ""} x ${_money(item.unitPrice)})",
                    ),
                  ),
                  Text(_money(item.total)),
                  if (!invoice.locked)
                    IconButton(
                      tooltip: "Remove".tr(),
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed:
                          _busy
                              ? null
                              : () => _change(
                                () => _request.removeMaterial(item.id),
                                "Item removed".tr(),
                              ),
                    ),
                ],
              ),
            ),
        ],

        if (!invoice.locked) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  title: "Request extra work".tr(),
                  loading: _busy,
                  onPressed: _openExtraWorkSheet,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomButton(
                  title: "Add material".tr(),
                  loading: _busy,
                  onPressed: _openMaterialSheet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Extra work is only charged after the customer approves it.".tr(),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ],
    );
  }

  /* ---------------------------------------------------------------- forms */

  Future<void> _openExtraWorkSheet() async {
    final description = TextEditingController();
    final amount = TextEditingController();
    await _showForm(
      title: "Request extra work".tr(),
      fields: [
        _field(description, "What needs to be done".tr(), lines: 3),
        _field(amount, "Price".tr(), number: true),
      ],
      submitLabel: "Send to customer".tr(),
      onSubmit: () async {
        final price = double.tryParse(amount.text.trim());
        if (description.text.trim().length < 3 || price == null || price <= 0) {
          throw "Please describe the work and enter a price".tr();
        }
        await _request.requestAdditionalWork(
          orderId: widget.order.id,
          description: description.text.trim(),
          amount: price,
        );
      },
      doneMessage: "Request sent to the customer".tr(),
    );
  }

  Future<void> _openMaterialSheet() async {
    final name = TextEditingController();
    final quantity = TextEditingController(text: "1");
    final unit = TextEditingController();
    final price = TextEditingController();
    await _showForm(
      title: "Add material".tr(),
      fields: [
        _field(name, "Item".tr()),
        Row(
          children: [
            Expanded(child: _field(quantity, "Quantity".tr(), number: true)),
            const SizedBox(width: 10),
            Expanded(child: _field(unit, "Unit (m, each...)".tr())),
          ],
        ),
        _field(price, "Price per unit".tr(), number: true),
      ],
      submitLabel: "Add".tr(),
      onSubmit: () async {
        final qty = double.tryParse(quantity.text.trim());
        final unitPrice = double.tryParse(price.text.trim());
        if (name.text.trim().length < 2 || qty == null || qty <= 0 || unitPrice == null || unitPrice <= 0) {
          throw "Please enter the item, quantity and price".tr();
        }
        await _request.addMaterial(
          orderId: widget.order.id,
          name: name.text.trim(),
          quantity: qty,
          unitPrice: unitPrice,
          unit: unit.text.trim(),
        );
      },
      doneMessage: "Item added".tr(),
    );
  }

  Widget _field(TextEditingController controller, String label, {bool number = false, int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: lines,
        keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  Future<void> _showForm({
    required String title,
    required List<Widget> fields,
    required String submitLabel,
    required Future<void> Function() onSubmit,
    required String doneMessage,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                ...fields,
                CustomButton(
                  title: submitLabel,
                  onPressed: () async {
                    final ok = await _change(onSubmit, doneMessage);
                    if (ok && sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                  },
                ).wFull(sheetContext),
              ],
            ),
          ),
        );
      },
    );
  }
}
