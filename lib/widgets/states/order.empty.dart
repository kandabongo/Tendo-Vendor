import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:fuodz/widgets/states/empty.state.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class EmptyOrder extends StatelessWidget {
  const EmptyOrder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: EmptyState(
          imageUrl: AppImages.emptyCart,
          title: "No Order".tr(),
          description:
              "When you are assigned an order, they will appear here".tr(),
        ),
      ),
    );
  }
}
