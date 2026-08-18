import 'package:flutter/material.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class OrderEditStatusBottomSheet extends StatefulWidget {
  OrderEditStatusBottomSheet(
    this.selectedStatus, {
    this.bookingOrder = false,
    required this.onConfirm,
    Key? key,
  }) : super(key: key);

  final Function(String) onConfirm;
  final String selectedStatus;
  final bool bookingOrder;
  @override
  _OrderEditStatusBottomSheetState createState() =>
      _OrderEditStatusBottomSheetState();
}

class _OrderEditStatusBottomSheetState
    extends State<OrderEditStatusBottomSheet> {
  //
  List<String> get statues {
    if (widget.bookingOrder) {
      return [
        'pending',
        'awaiting_host_approval',
        'confirmed',
        // 'checkin',
        // 'checkout',
        'cancelled',
        'delivered',
        "expired",
      ];
    }
    return [
      'pending',
      'preparing',
      'ready',
      'enroute',
      'failed',
      'cancelled',
      'delivered',
    ];
  }

  String? selectedStatus;

  @override
  void initState() {
    super.initState();

    //
    setState(() {
      selectedStatus = widget.selectedStatus;
    });
  }

  //
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: VStack([
        //
        "Change Order Status".tr().text.semiBold.xl.make(),
        //
        Scrollbar(
          interactive: true,
          thumbVisibility: true,
          trackVisibility: true,
          child: RadioGroup(
            groupValue: selectedStatus,
            onChanged: _changeSelectedStatus,
            child: GridView.count(
              // shrinkWrap: true,
              // physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.90,
              children: [
                ...statues.map((e) {
                  return RadioListTile(
                    value: e,
                    title: e.tr().allWordsCapitilize().text.lg.light.make(),
                    contentPadding: EdgeInsets.symmetric(),
                  ).card.elevation(0.67).make();
                }).toList(),
              ],
            ),
          ),
        ).expand(),
        //
        CustomButton(
          title: "Change".tr(),
          onPressed:
              selectedStatus != null
                  ? () => widget.onConfirm(selectedStatus!)
                  : null,
        ),
      ], spacing: 8).p20().hTwoThird(context),
    );
  }

  void _changeSelectedStatus(value) {
    setState(() {
      selectedStatus = value;
    });
  }
}
