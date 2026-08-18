import 'package:flutter/material.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/view_models/orders.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/dropdowns/order_status_filter.dropdown.dart';
import 'package:fuodz/widgets/list_items/order.list_item.dart';
import 'package:fuodz/widgets/list_items/order_booking.list_item.dart';
import 'package:fuodz/widgets/states/error.state.dart';
import 'package:fuodz/widgets/states/order.empty.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with AutomaticKeepAliveClientMixin<OrdersPage> {
  //
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: ViewModelBuilder<OrdersViewModel>.reactive(
        viewModelBuilder: () => OrdersViewModel(context),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return BasePage(
            body: VStack([
              //
              HStack([
                "Orders".tr().text.xl2.semiBold.make().expand(),
                //
                //order status
                OrderStatusFilterDropdown(
                  statuses: vm.statuses,
                  selectedStatus: vm.selectedStatus,
                  onChanged: vm.statusChanged,
                ),
              ]).p(Sizes.paddingSizeDefault),

              //
              CustomListView(
                canRefresh: true,
                canPullUp: true,
                refreshController: vm.refreshController,
                onRefresh: vm.fetchMyOrders,
                onLoading: () => vm.fetchMyOrders(initialLoading: false),
                isLoading: vm.isBusy,
                dataSet: vm.orders,
                hasError: vm.hasError,
                padding: EdgeInsets.all(Sizes.paddingSizeDefault),
                errorWidget: LoadingError(onrefresh: vm.fetchMyOrders),
                //
                emptyWidget: EmptyOrder(),
                separatorBuilder: (_, __) => Sizes.paddingSizeDefault.heightBox,
                itemBuilder: (context, index) {
                  //
                  final order = vm.orders[index];
                  if (order.bookingOrder != null) {
                    return OrderBookingListItem(
                      order: order,
                      orderPressed: () => vm.openOrderDetails(order),
                    );
                  }
                  return OrderListItem(
                    order: order,
                    orderPressed: () => vm.openOrderDetails(order),
                  );
                },
              ).expand(),
            ], spacing: 0),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
