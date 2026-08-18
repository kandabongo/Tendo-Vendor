import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_ui_settings.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/booking_order_details.vm.dart';
import 'package:fuodz/view_models/order_details.vm.dart';
import 'package:fuodz/views/pages/order/widgets/booking_order_actions.dart';
import 'package:fuodz/views/pages/order/widgets/order_status.view.dart';
import 'package:fuodz/widgets/alternative.view.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/cards/booking_order_summary.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:fuodz/widgets/states/custom_loading.state.dart';
import 'package:fuodz/widgets/states/unpaid_order.state.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class OrderBookingDetailsPage extends StatelessWidget {
  const OrderBookingDetailsPage({required this.order, Key? key})
    : super(key: key);

  final Order order;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BookingOrderDetailsViewModel>.reactive(
      viewModelBuilder: () => BookingOrderDetailsViewModel(context, order),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          title: "Booking Details".tr(),
          showAppBar: true,
          showLeadingAction: true,
          elevation: 0,
          onBackPressed: vm.onBackPressed,
          isLoading: vm.isBusy,
          actions: [
            IconButton(icon: Icon(Icons.print), onPressed: vm.printOrder),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: vm.fetchOrderDetails,
            ),
          ],
          body: AlternativeView(
            ismain: !vm.order.isUnpaid,
            alt: UnpaidOrderState(),
            main: CustomLoadingStateView(
              loading: vm.isBusy,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Sizes.paddingSizeDefault),
                child: VStack([
                  // User Info Card
                  _buildUserCard(context, vm),
                  UiSpacer.verticalSpace(),

                  // Status
                  OrderStatusView(
                    vm,
                  ).box.p12.rounded.border(color: Vx.zinc200).make(),
                  UiSpacer.verticalSpace(),

                  // Booking Details (Dates, Property, Guests)
                  _buildBookingDetailsCard(context, vm),
                  UiSpacer.verticalSpace(),

                  // Special Requests
                  if (vm.order.bookingOrder != null &&
                      vm.order.bookingOrder!.specialRequests != null &&
                      vm.order.bookingOrder!.specialRequests!.isNotEmpty)
                    VStack([
                          "Special Requests".tr().text.gray500.medium.sm.make(),
                          (vm.order.bookingOrder!.specialRequests!)
                              .text
                              .medium
                              .lg
                              .italic
                              .make(),
                        ])
                        .p12()
                        .box
                        .color(context.cardColor)
                        .rounded
                        .border(color: Vx.zinc200)
                        .make(),

                  // Note
                  if (vm.order.note.isNotEmpty && vm.order.note != "--")
                    VStack([
                          "Note".tr().text.gray500.medium.sm.make(),
                          (vm.order.note).text.medium.lg.italic.make(),
                        ])
                        .p12()
                        .box
                        .color(context.cardColor)
                        .rounded
                        .border(color: Vx.zinc200)
                        .make(),

                  // Order Summary
                  BookingOrderSummary(vm.order)
                      .p12()
                      .box
                      .color(context.cardColor)
                      .rounded
                      .border(color: Vx.zinc200)
                      .make(),

                  //
                  UiSpacer.verticalSpace(),
                  BookingOrderActions(vm),
                ]),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserCard(BuildContext context, OrderDetailsViewModel vm) {
    return HStack([
          // Avatar
          CustomImage(
            imageUrl: vm.order.user.photo,
            width: 60,
            height: 60,
            boxFit: BoxFit.cover,
          ).box.roundedFull.clip(Clip.antiAlias).make(),

          16.widthBox,

          // Name & Actions
          VStack([
            "Guest".tr().text.xs.gray500.make(),
            vm.order.user.name.text.xl.semiBold.make(),
            Sizes.paddingSizeSmall.heightBox,
            // Actions
            HStack([
              if (vm.order.canChatCustomer && AppUISettings.canCallDriver)
                CustomButton(
                  elevation: 0.5,
                  icon: FlutterIcons.phone_call_fea,
                  iconColor: Colors.white,
                  color: AppColor.primaryColor,
                  shapeRadius: Sizes.radiusSmall,
                  onPressed: vm.callCustomer,
                ).h(30).fittedBox(),

              if (vm.order.canChatCustomer && AppUISettings.canCustomerChat)
                CustomButton(
                  elevation: 0.5,
                  icon: FlutterIcons.chat_ent,
                  iconColor: Colors.white,
                  color: AppColor.primaryColor,
                  shapeRadius: Sizes.radiusSmall,
                  onPressed: vm.chatCustomer,
                ).h(30).fittedBox(),
            ], spacing: Sizes.paddingSizeDefault).py4(),
          ]).expand(),
        ], crossAlignment: CrossAxisAlignment.start)
        .p12()
        .box
        .color(context.cardColor)
        .rounded
        .border(color: Vx.zinc200)
        .make();
  }

  Widget _buildBookingDetailsCard(
    BuildContext context,
    BookingOrderDetailsViewModel vm,
  ) {
    final booking = vm.order.bookingOrder;
    final property = booking?.property;

    return VStack([
          // Property Info
          if (property != null)
            GestureDetector(
              onTap: () => vm.showPropertyDetails(property),
              child: HStack([
                CustomImage(
                  imageUrl: property.mainPhoto,
                  width: 50,
                  height: 50,
                  boxFit: BoxFit.cover,
                ).cornerRadius(8),
                12.widthBox,
                VStack([
                  property.name.text.lg.medium.make(),
                  5.heightBox,
                  property.address.text.sm.gray500.make(),
                ]).expand(),
                //arrow
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
              ]),
            ),

          if (property != null) Divider().py12(),

          // Check-in / Check-out
          HStack([
            _buildDateItem(
              "Check-in".tr(),
              booking?.checkInDate,
              booking?.checkInTime ?? "12:00 PM",
            ).expand(),
            Container(
              height: 40,
              width: 1,
              color: Colors.grey.withOpacity(0.3),
            ).px16(),
            _buildDateItem(
              "Check-out".tr(),
              booking?.checkOutDate,
              booking?.checkOutTime ?? "11:00 AM",
            ).expand(),
          ]),

          Divider().py12(),

          // Guest Count
          HStack([
            Icon(Icons.people, color: Colors.grey, size: 20),
            8.widthBox,
            "${booking?.numberOfGuests ?? 1} ${"Guests".tr()}".text.medium
                .make(),
            Spacer(),
            "${booking?.numberOfNights ?? 1} ${"Nights".tr()}"
                .text
                .medium
                .gray500
                .make(),
          ]),

          // Guest Breakdown
          if (booking != null) ...[
            UiSpacer.verticalSpace(space: 10),
            Wrap(
              spacing: 12,
              children: [
                if (booking.numberOfAdults > 0)
                  _guestChip("Adults".tr(), booking.numberOfAdults),
                if (booking.numberOfChildren > 0)
                  _guestChip("Children".tr(), booking.numberOfChildren),
                if (booking.numberOfInfants > 0)
                  _guestChip("Infants".tr(), booking.numberOfInfants),
                if (booking.numberOfPets > 0)
                  _guestChip("Pets".tr(), booking.numberOfPets),
              ],
            ),
          ],

          // Cancellation Policy
          if (booking?.cancellationPolicy != null) ...[
            Divider().py12(),
            HStack([
              "Cancellation Policy".tr().text.sm.gray500.make().expand(),
              (booking?.cancellationPolicy?.name ?? "").text.medium.make(),
            ]),
          ],
        ])
        .p16()
        .box
        .color(context.cardColor)
        .rounded
        .border(color: Vx.zinc200)
        .make();
  }

  Widget _guestChip(String label, int count) {
    return HStack([
          count.text.bold.sm.make(),
          4.widthBox,
          label.text.sm.gray500.make(),
        ])
        .pSymmetric(h: 8, v: 4)
        .box
        .color(Colors.grey.withOpacity(0.1))
        .rounded
        .make();
  }

  Widget _buildDateItem(String label, DateTime? date, String time) {
    return VStack([
      label.text.xs.gray500.make(),
      if (date != null)
        Jiffy.parse(
          date.toString(),
        ).format(pattern: 'dd MMM yyyy').text.semiBold.make(),
      time.text.sm.gray500.make(),
    ]);
  }
}
