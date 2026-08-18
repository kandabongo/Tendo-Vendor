import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/vendor_details.view_model.dart';
import 'package:fuodz/views/pages/vendor/widgets/request_payout.btn.dart';
import 'package:fuodz/views/pages/vendor/widgets/vendor_sales.chart.dart';
import 'package:fuodz/widgets/alternative.view.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/currency_hstack.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:numeral/extension.dart';

import 'widgets/document_request.view.dart';
import 'widgets/online_status.toggle.dart';
import 'widgets/vendor_profile.switch.dart';

class VendorDetailsPage extends StatefulWidget {
  const VendorDetailsPage({Key? key}) : super(key: key);

  @override
  _VendorDetailsPageState createState() => _VendorDetailsPageState();
}

class _VendorDetailsPageState extends State<VendorDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VendorDetailsViewModel>.reactive(
      viewModelBuilder: () => VendorDetailsViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          body: SafeArea(
            child: AlternativeView(
              ismain: !(vm.isBusy || vm.vendor == null),
              alt: BusyIndicator().centered(),
              main: AlternativeView(
                ismain: !vm.hasError,
                alt: _buildErrorFetchingDetals(context, vm),
                main: SmartRefresher(
                  enablePullDown: true,
                  controller: vm.refreshController,
                  onRefresh: () => vm.fetchVendorDetails(),
                  child: SingleChildScrollView(
                    child: VStack([
                      "Vendor Details".tr().text.xl2.semiBold.make().p20(),
                      //vendor switcher
                      VendorProfileSwitcher(vm).px20(),
                      //
                      DocumentRequestView(),
                      //online status
                      OnlineStatusToggle(vm).px20(),

                      //subscription section
                      VStack([
                        //subscription indicator
                        if (vm.vendor?.useSubscription ?? false)
                          _buildSubscriptionSection(context, vm),
                        UiSpacer.vSpace(6),
                        //subscription payment indicator
                        if (_hasExpiredSubscription(vm))
                          _buildExpiredSubscriptionSection(context, vm),
                      ]).px20().py12(),

                      //
                      _buildTransactionsStatsSection(context, vm),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  //misc
  bool _hasExpiredSubscription(VendorDetailsViewModel vm) {
    return (vm.vendor == null) ||
        (vm.vendor!.useSubscription) && !(vm.vendor!.hasSubscription);
  }

  //
  Widget _buildErrorFetchingDetals(
    BuildContext context,
    VendorDetailsViewModel vm,
  ) {
    return VStack([
      Icon(FlutterIcons.alert_triangle_fea, color: Colors.red, size: 60).py12(),
      "Something went wrong".tr().text.xl.semiBold.makeCentered(),
      "${vm.modelError ?? 'An error occurred fetching vendor details. Please try again'.tr()}"
          .text
          .center
          .gray500
          .makeCentered()
          .py8(),
      CustomButton(
        title: "Reload".tr(),
        icon: FlutterIcons.refresh_cw_fea,
        onPressed: () => vm.fetchVendorDetails(),
      ).w32(context).py12(),
    ], crossAlignment: CrossAxisAlignment.center).centered().p20();
  }

  Widget _buildSubscriptionSection(
    BuildContext context,
    VendorDetailsViewModel vm,
  ) {
    return HStack([
      "Subscription Status".tr().text.medium.lg.make().expand(),
      UiSpacer.hSpace(),
      ((vm.vendor!.hasSubscription) ? "Subscribed" : "No Subscription")
          .text
          .semiBold
          .xl
          .color(
            (vm.vendor!.hasSubscription)
                ? AppColor.openColor
                : AppColor.closeColor,
          )
          .make(),
    ]);
  }

  Widget _buildExpiredSubscriptionSection(
    BuildContext context,
    VendorDetailsViewModel vm,
  ) {
    return HStack([
      "Your subscription has expired".tr().text.lg.white.make().expand(),
      CustomButton(
        child:
            "Subscribe"
                .tr()
                .text
                .xl
                .medium
                .color(Colors.red.shade400)
                .makeCentered(),
        color: Colors.white,
        onPressed: vm.openSubscriptionPage,
      ),
    ]).p8().box.color(Colors.red.shade400).roundedSM.make().wFull(context);
  }

  Widget _buildTransactionsStatsSection(
    BuildContext context,
    VendorDetailsViewModel vm,
  ) {
    return VStack([
      // transactions/orders stats
      VendorSalesChart(vm: vm),
      //total orders
      HStack([
            //
            "Total Orders".tr().text.lg.white.make().expand(),
            UiSpacer.horizontalSpace(),
            "${vm.totalOrders.decimal()}".text.xl.semiBold.white.make(),
          ])
          .p20()
          .box
          .rounded
          .shadow
          .color(AppColor.accentColor.withValues(alpha: 0.8))
          .make()
          .py16(),

      ////earnings
      HStack([
        //
        "Total Earnings \n(Currently)".tr().text.lg.white.make().expand(),
        UiSpacer.horizontalSpace(),
        CurrencyHStack([
          "${vm.currencySymbol} ".text.xl.semiBold.white.make(),
          "${vm.totalEarning.currencyValueFormat()} ".text.xl.semiBold.white
              .make(),
        ]),
      ]).p20().box.rounded.outerShadow.color(AppColor.accentColor).make(),
      //request payout
      RequestPayoutButton(vm: vm),
    ]).px20();
  }
}
