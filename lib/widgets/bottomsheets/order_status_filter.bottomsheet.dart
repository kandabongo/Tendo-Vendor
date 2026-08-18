import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class OrderStatusFilterBottomSheet extends StatelessWidget {
  const OrderStatusFilterBottomSheet({
    required this.statuses,
    required this.selectedStatus,
    required this.onSelected,
    super.key,
  });

  final List<String> statuses;
  final String selectedStatus;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: VStack([
        //
        "Filter by Status".tr().text.semiBold.xl.make(),
        //
        Flexible(
          child: Scrollbar(
            child: ListView(
              shrinkWrap: true,
              children: [
                ...statuses.map((status) {
                  final isSelected = status == selectedStatus;
                  return RadioListTile<String>(
                    value: status,
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      Navigator.of(context).pop();
                      if (value != null) onSelected(value);
                    },
                    activeColor: AppColor.primaryColor,
                    title: status.toLowerCase().tr().allWordsCapitilize().text
                        .color(isSelected ? AppColor.primaryColor : null)
                        .make(),
                  );
                }),
              ],
            ),
          ),
        ),
      ], spacing: 8).p20(),
    );
  }
}
