import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/models/menu.dart';
import 'package:velocity_x/velocity_x.dart';

class ManageMenuListItem extends StatelessWidget {
  //
  const ManageMenuListItem(
    this.menu, {
    this.isLoading = false,
    required this.onEditPressed,
    required this.onDeletePressed,
    Key? key,
  }) : super(key: key);

  //
  final Menu menu;
  final bool isLoading;
  final Function(Menu) onEditPressed;
  final Function(Menu) onDeletePressed;

  @override
  Widget build(BuildContext context) {
    //
    return HStack(
      [
        //name
        menu.name.text
            .scale(0.95)
            .semiBold
            .maxLines(1)
            .ellipsis
            .make()
            .expand(),

        //actions
        IconButton(
          visualDensity: VisualDensity.compact,
          iconSize: 18,
          padding: EdgeInsets.zero,
          color: context.primaryColor,
          onPressed: isLoading ? null : () => onEditPressed(menu),
          icon: Icon(FlutterIcons.edit_2_fea),
        ),

        IconButton(
          visualDensity: VisualDensity.compact,
          iconSize: 18,
          padding: EdgeInsets.zero,
          onPressed: isLoading ? null : () => onDeletePressed(menu),
          color: Colors.red,
          icon: Icon(FlutterIcons.trash_fea),
        ),
      ],
      spacing: 8,
      alignment: MainAxisAlignment.spaceBetween,
    ).box.padding(EdgeInsets.symmetric(horizontal: 12, vertical: 8)).make();
  }
}
