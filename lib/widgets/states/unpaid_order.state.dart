import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class UnpaidOrderState extends StatelessWidget {
  const UnpaidOrderState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child:
          VStack([
            Icon(
              FlutterIcons.warning_mdi,
              color: Colors.white,
              size: 40,
            ).centered(),
            10.heightBox,
            "Payment Pending"
                .tr()
                .text
                .color(Colors.white)
                .xl4
                .bold
                .center
                .makeCentered(),
            4.heightBox,
            "Until payment is made, the order should not be processed."
                .tr()
                .text
                .color(Colors.white)
                .lg
                .center
                .makeCentered(),
          ]).centered().p16(),
    );
  }
}
