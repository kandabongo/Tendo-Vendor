import 'package:flutter/material.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/vendor_details.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OnlineStatusToggle extends StatelessWidget {
  const OnlineStatusToggle(this.vm, {super.key});

  final VendorDetailsViewModel vm;

  @override
  Widget build(BuildContext context) {
    return VStack([
      HStack([
        "Status".tr().text.medium.lg.make().expand(),
        ((vm.vendor!.isOpen) ? "Open".tr() : "Close".tr()).text.semiBold.xl
            .color((vm.vendor!.isOpen) ? Colors.green : Colors.red)
            .make(),
        10.widthBox,
        vm.busy(vm.vendor!.isOpen)
            ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
            : Switch.adaptive(
              value: vm.vendor!.isOpen,
              activeColor: Colors.green,
              activeTrackColor: Colors.green.withOpacity(0.8),
              inactiveThumbColor: Colors.red,
              inactiveTrackColor: Colors.red.withOpacity(0.8),
              onChanged: (_) => vm.toggleVendorAvailablity(),
            ),
      ]),
      //
      UiSpacer.divider(),
    ]);
  }
}
