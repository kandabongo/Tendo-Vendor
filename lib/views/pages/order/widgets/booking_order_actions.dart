import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/booking_order_details.vm.dart';
import 'package:fuodz/widgets/alternative.view.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/states/loading.shimmer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class BookingOrderActions extends StatelessWidget {
  const BookingOrderActions(this.vm, {Key? key}) : super(key: key);

  final BookingOrderDetailsViewModel vm;

  @override
  Widget build(BuildContext context) {
    bool ispending = vm.order.status == "pending";
    bool awaitingConfirmation = vm.order.status == "awaiting_host_approval";
    bool actionsNeeded =
        !["failed", "cancelled", "delivered"].contains(vm.order.status);
    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          border: Border(top: BorderSide(color: Vx.zinc200)),
        ),
        child: AlternativeView(
          ismain: !vm.isBusy,
          alt: LoadingShimmer(),
          main: VStack([
            //pending action
            if (awaitingConfirmation || ispending)
              HStack([
                CustomButton(
                  elevation: 0.5,
                  color: Colors.red,
                  title: "Reject".tr(),
                  onPressed: () => vm.processOrderCancellation(),
                ).expand(),
                UiSpacer.hSpace(),
                CustomButton(
                  elevation: 0.5,
                  color: Colors.green,
                  title: "Confirm".tr(),
                  onPressed: () => vm.processBookingStatusUpdate('confirmed'),
                ).expand(),
              ]),

            // Confirmed -> Checkin
            if (vm.order.status == "confirmed")
              CustomButton(
                elevation: 0.5,
                title: "Check In".tr(),
                color: AppColor.primaryColor,
                onPressed: () => vm.verifyUserCode('checkin'),
              ).wFull(context),

            // Checkin -> Checkout
            if (vm.order.status == "checkin")
              CustomButton(
                elevation: 0.5,
                title: "Check Out".tr(),
                color: Colors.orange,
                onPressed: () => vm.verifyUserCode('checkout'),
              ).wFull(context),

            // note pending actions
            if (!ispending &&
                ![
                  "confirmed",
                  "checkin",
                  "checkout",
                ].contains(vm.order.status) &&
                actionsNeeded)
              VStack([
                HStack([
                  //edit order
                  if (vm.order.canEditStatus)
                    Expanded(
                      flex: 3,
                      child: CustomButton(
                        elevation: 0.5,
                        title: "Update Status".tr(),
                        icon: FlutterIcons.rss_fea,
                        onPressed: vm.changeOrderStatus,
                      ),
                    ),
                  //cancel order
                  if (vm.order.canCancel)
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        elevation: 0.5,
                        color: Colors.red,
                        title: "Cancel".tr(),
                        icon: FlutterIcons.close_ant,
                        onPressed: vm.processOrderCancellation,
                      ),
                    ),
                ], spacing: 10),
              ], spacing: 20),
          ], spacing: 12),
        ),
      ),
    );
  }
}
