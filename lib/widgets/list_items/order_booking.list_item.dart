import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderBookingListItem extends StatelessWidget {
  const OrderBookingListItem({
    required this.order,
    required this.orderPressed,
    Key? key,
  }) : super(key: key);

  final Order order;
  final Function orderPressed;

  @override
  Widget build(BuildContext context) {
    final booking = order.bookingOrder;
    final property = booking?.property;
    final statusBgColor = AppColor.getStausColor(order.status);
    final statusTextColor = Utils.textColorByColor(statusBgColor);

    return VStack([
          // Top Row: User Info and Status
          HStack([
            // User Image
            CustomImage(
              imageUrl: order.user.photo,
              width: 40,
              height: 40,
              boxFit: BoxFit.cover,
            ).box.roundedFull.clip(Clip.antiAlias).make(),

            10.widthBox,

            // User Name & Order ID
            VStack([
              order.user.name.text.medium.semiBold.make(),
              Sizes.paddingSizeExtraSmall.heightBox,
              "#${order.code}".text.xs.gray500.make(),
            ]).expand(),

            // Status Badge
            "${order.status}"
                .tr()
                .capitalized
                .text
                .xs
                .color(statusTextColor)
                .make()
                .pSymmetric(h: 8, v: 4)
                .box
                .rounded
                .color(statusBgColor)
                .make(),
          ]),

          UiSpacer.verticalSpace(space: 10),
          Divider(height: 1),
          UiSpacer.verticalSpace(space: 10),

          // Property Name
          HStack([
            Icon(Icons.home, size: 16, color: Colors.grey),
            5.widthBox,
            (property?.name ?? "Property".tr()).text.sm.gray600
                .maxLines(1)
                .ellipsis
                .make()
                .expand(),
          ]),

          5.heightBox,

          // Dates
          HStack([
            Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            5.widthBox,
            if (booking != null)
              "${Jiffy.parse(booking.checkInDate.toString()).format(pattern: 'dd MMM')} - ${Jiffy.parse(booking.checkOutDate.toString()).format(pattern: 'dd MMM yyyy')}"
                  .text
                  .sm
                  .gray600
                  .make(),
          ]),

          UiSpacer.verticalSpace(space: 10),

          // Bottom Row: Price
          HStack([
            "Total".tr().text.sm.gray500.make(),
            Spacer(),
            "${AppStrings.currencySymbol} ${order.total}"
                .currencyFormat()
                .text
                .lg
                .bold
                .color(AppColor.primaryColor)
                .make(),
          ]),
        ])
        .p(Sizes.paddingSizeSmall)
        .box
        .border(color: Vx.zinc200)
        .withRounded(value: Sizes.radiusDefault)
        .make()
        .onInkTap(() => orderPressed());
  }
}
