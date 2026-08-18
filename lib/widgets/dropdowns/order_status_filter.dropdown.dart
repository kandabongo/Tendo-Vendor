import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/widgets/bottomsheets/order_status_filter.bottomsheet.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class OrderStatusFilterDropdown extends StatelessWidget {
  const OrderStatusFilterDropdown({
    required this.statuses,
    required this.selectedStatus,
    required this.onChanged,
    super.key,
  });

  final List<String> statuses;
  final String selectedStatus;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isFiltered = selectedStatus != "All";

    return Tooltip(
      message: "Filter".tr(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return OrderStatusFilterBottomSheet(
                statuses: statuses,
                selectedStatus: selectedStatus,
                onSelected: onChanged,
              );
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isFiltered
                    ? AppColor.primaryColor.withValues(alpha: 0.1)
                    : Colors.grey.shade200,
          ),
          child: Icon(
            Icons.filter_list,
            color: isFiltered ? AppColor.primaryColor : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
