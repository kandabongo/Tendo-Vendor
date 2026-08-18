import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/context.dart';
import 'package:fuodz/models/menu.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/menu_filter.vm.dart';
import 'package:fuodz/views/pages/menu/menu_list.page.dart';
import 'package:fuodz/widgets/states/loading.shimmer.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class MenuFilterList extends StatelessWidget {
  const MenuFilterList({required this.onMenuSelected, super.key});

  final ValueChanged<Menu?> onMenuSelected;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MenuFilterViewModel>.reactive(
      viewModelBuilder: () => MenuFilterViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        if (vm.isBusy) {
          return SizedBox(
            height: 40,
            width: double.infinity,
            child: LoadingShimmer(heightPercentage: 2),
          );
        }
        return SizedBox(
          height: 40,
          width: double.infinity,
          child: HStack([
            HStack([
              _MenuChip(
                label: "All".tr(),
                isSelected: vm.selectedMenu == null,
                onTap: () => vm.selectMenu(null, onSelected: onMenuSelected),
              ),

              ...vm.menus.map((menu) {
                return _MenuChip(
                  label: menu.name,
                  isSelected: vm.selectedMenu?.id == menu.id,
                  onTap: () => vm.selectMenu(menu, onSelected: onMenuSelected),
                );
              }),
            ], spacing: 10).scrollHorizontal().expand(),
            //manage menu
            InkWell(
              onTap: () async {
                await context.push((context) => MenuListPage());
                vm.fetchMenus();
              },
              borderRadius: BorderRadius.circular(Sizes.radiusExtraLarge),
              child: Container(
                margin: EdgeInsets.only(right: 8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.list_rounded,
                  size: 18,
                  color: Utils.textColorByPrimaryColor(),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}

class _MenuChip extends StatelessWidget {
  const _MenuChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Sizes.radiusSmall),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primaryColor : null,
          border: Border.all(
            color:
                isSelected
                    ? AppColor.primaryColor
                    : context.textTheme.bodyLarge!.color!.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(Sizes.radiusExtraLarge),
        ),
        child:
            label.text
                .color(
                  isSelected
                      ? Utils.textColorByColor(AppColor.primaryColor)
                      : null,
                )
                .make(),
      ),
    );
  }
}
