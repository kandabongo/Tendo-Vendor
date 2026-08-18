import 'dart:io';
import 'package:double_back_to_close/double_back_to_close.dart';

import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_upgrade_settings.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/views/pages/finance/vendor_finance_report.page.dart';
import 'package:fuodz/views/pages/profile/profile.page.dart';
import 'package:fuodz/view_models/home.vm.dart';
import 'package:fuodz/views/pages/vendor/vendor_details.page.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/bottom_nav_bar.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:stacked/stacked.dart';
import 'package:upgrader/upgrader.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'order/orders.page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DoubleBack(
      message: "Press back again to close".tr(),
      child: ViewModelBuilder<HomeViewModel>.reactive(
        viewModelBuilder: () => HomeViewModel(context),
        onViewModelReady: (model) => model.initialise(),
        builder: (context, model, child) {
          return BasePage(
            body: UpgradeAlert(
              showIgnore: !AppUpgradeSettings.forceUpgrade(),
              shouldPopScope: () => !AppUpgradeSettings.forceUpgrade(),
              dialogStyle:
                  Platform.isIOS
                      ? UpgradeDialogStyle.cupertino
                      : UpgradeDialogStyle.material,
              child: PageView(
                controller: model.pageViewController,
                onPageChanged: model.onPageChanged,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  OrdersPage(),
                  //
                  Utils.vendorSectionPage(model.currentVendor!),
                  VendorDetailsPage(),
                  //
                  if (model.canViewReport)
                    //show report page
                    VendorFinanceReportPage(),

                  //
                  ProfilePage(),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).bottomSheetTheme.backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: SafeArea(
                child: BottomNavBar(
                  currentIndex: model.currentIndex,
                  onTap: model.onTabChange,
                  items: [
                    BottomNavBarItem(
                      icon: HugeIcons.strokeRoundedInboxCheck,
                      label: 'Orders'.tr(),
                    ),
                    BottomNavBarItem(
                      icon: Utils.vendorIconIndicator(model.currentVendor!),
                      label:
                          Utils.vendorTypeIndicator(
                            model.currentVendor!,
                          ).tr(),
                    ),
                    BottomNavBarItem(
                      icon: HugeIcons.strokeRoundedShoppingBag01,
                      label: 'Vendor'.tr(),
                    ),

                    //show report page
                    if (model.canViewReport)
                      BottomNavBarItem(
                        icon: HugeIcons.strokeRoundedPieChart01,
                        label: 'Report'.tr(),
                      ),

                    //
                    BottomNavBarItem(
                      icon: HugeIcons.strokeRoundedMenu01,
                      label: 'More'.tr(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
