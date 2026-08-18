import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/menu_list.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/list_items/manage_menu.list_item.dart';
import 'package:fuodz/widgets/states/empty.state.dart';
import 'package:fuodz/widgets/states/error.state.dart';
import 'package:fuodz/widgets/states/grouped_loading.shimmer.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class MenuListPage extends StatelessWidget {
  const MenuListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MenuListViewModel>.reactive(
      viewModelBuilder: () => MenuListViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: true,
          title: "Menus".tr(),
          showLeadingAction: true,
          appBarColor: context.primaryColor,
          appBarItemColor: Utils.textColorByPrimaryColor(),
          child: CustomListView(
            padding: EdgeInsets.all(Sizes.paddingSizeDefault),
            dataSet: vm.menus,
            isLoading: vm.isBusy,
            loadingWidget: GroupedLoadingShimmer(columns: 3),
            hasError: vm.hasError,
            errorWidget: LoadingError(onrefresh: vm.fetchMenus),
            emptyWidget: Center(
              child: EmptyState(
                title: "No Menu".tr(),
                description: "You have not created any menu yet".tr(),
              ),
            ),
            itemBuilder: (context, index) {
              final menu = vm.menus[index];
              return ManageMenuListItem(
                menu,
                isLoading: vm.busy(menu.id),
                onEditPressed: vm.editMenu,
                onDeletePressed: vm.deleteMenu,
              );
            },
            separatorBuilder: (p0, p1) => 5.heightBox,
          ),
          fab: FloatingActionButton(
            child: Icon(FlutterIcons.plus_ant),
            onPressed: vm.newMenu,
            backgroundColor: context.primaryColor,
            foregroundColor: Utils.textColorByPrimaryColor(),
          ),
        );
      },
    );
  }
}
