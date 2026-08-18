import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/products.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/custom_text_form_field.dart';
import 'package:fuodz/widgets/list_items/manage_product.list_item.dart';
import 'package:fuodz/widgets/states/error.state.dart';
import 'package:fuodz/widgets/states/grouped_loading.shimmer.dart';
import 'package:fuodz/widgets/states/product.empty.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'widgets/menu_filter.list.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with AutomaticKeepAliveClientMixin<ProductsPage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: ViewModelBuilder<ProductViewModel>.reactive(
        viewModelBuilder: () => ProductViewModel(context),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return BasePage(
            fab: FloatingActionButton(
              backgroundColor: AppColor.primaryColor,
              onPressed: vm.newProduct,
              child: Icon(
                FlutterIcons.plus_ant,
                color: Utils.textColorByColor(context.primaryColor),
              ),
            ),
            body:
                VStack([
                  //
                  "Products".tr().text.xl2.semiBold.make().py(20),
                  //search bar
                  CustomTextFormField(
                    hintText: "Search".tr(),
                    onFieldSubmitted: vm.productSearch,
                  ),
                  Sizes.paddingSizeDefault.heightBox,
                  //menu
                  MenuFilterList(onMenuSelected: vm.filterByMenu),
                  Sizes.paddingSizeDefault.heightBox,
                  //
                  CustomListView(
                    canRefresh: true,
                    canPullUp: true,
                    refreshController: vm.refreshController,
                    onRefresh: vm.fetchMyProducts,
                    onLoading: () => vm.fetchMyProducts(initialLoading: false),
                    isLoading: vm.isBusy,
                    dataSet: vm.products,
                    hasError: vm.hasError,
                    errorWidget: LoadingError(onrefresh: vm.fetchMyProducts),
                    loadingWidget: GroupedLoadingShimmer(
                      columns: 4,
                      padding: 0,
                    ),
                    emptyWidget: EmptyProduct(),
                    itemBuilder: (context, index) {
                      //
                      final product = vm.products[index];
                      return ManageProductListItem(
                        product,
                        isLoading: vm.busy(product.id),
                        onPressed: vm.openProductDetails,
                        onEditPressed: vm.editProduct,
                        onToggleStatusPressed: vm.changeProductStatus,
                        onDeletePressed: vm.deleteProduct,
                      );
                    },
                    separatorBuilder: (p0, p1) => 5.heightBox,
                  ).expand(),
                ]).px20(),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
