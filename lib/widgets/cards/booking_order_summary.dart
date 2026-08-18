import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/widgets/cards/amount_tile.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class BookingOrderSummary extends StatelessWidget {
  const BookingOrderSummary(this.order, {Key? key}) : super(key: key);

  final Order order;
  @override
  Widget build(BuildContext context) {
    final currencySymbol = AppStrings.currencySymbol;
    return VStack([
      "Order Summary".tr().text.semiBold.xl.make().pOnly(bottom: Vx.dp12),
      AmountTile("Subtotal".tr(), order.subTotal.currencyValueFormat()).py2(),
      AmountTile(
        "Discount".tr(),
        "- " + "$currencySymbol ${order.discount}".currencyFormat(),
      ).py2(),
      AmountTile(
        "Tax (%s)".tr().fill([order.taxRate.toString()]),
        "+ " + "$currencySymbol ${order.tax}".currencyFormat(),
      ).py2(),
      DottedLine(dashColor: context.textTheme.bodyLarge!.color!).py8(),
      if (order.bookingOrder!.bookingOrderFees.isNotEmpty) ...[
        ...((order.bookingOrder!.bookingOrderFees).map((fee) {
          return AmountTile(
            "${fee.name}".tr(),
            "+ " + " $currencySymbol ${fee.calculatedAmount}".currencyFormat(),
          ).py2();
        }).toList()),
        DottedLine(dashColor: context.textTheme.bodyLarge!.color!).py8(),
      ],
      AmountTile(
        "Total Amount".tr(),
        "$currencySymbol ${order.total}".currencyFormat(),
      ),
    ]);
  }
}
