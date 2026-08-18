import 'package:fuodz/services/alert.service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/models/user.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/requests/vendor.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/crashlytics.service.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/views/pages/shared/custom_webview.page.dart';
import 'package:fuodz/widgets/bottomsheets/payout.bottomsheet.dart';
import 'package:fuodz/widgets/bottomsheets/vendor_switcher.bottomsheet.dart';

import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/extensions/context.dart';

class VendorDetailsViewModel extends MyBaseViewModel {
  //
  int? touchedIndex;
  double totalEarning = 0.00;
  int totalOrders = 0;
  List<double> weeklySales = [0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00];
  Vendor? vendor;
  User? user;
  VendorRequest vendorRequest = VendorRequest();
  RefreshController refreshController = RefreshController();
  String weekFirstDay = "";
  String weekLastDay = "";

  dynamic toggleVendorAvailability;

  //
  VendorDetailsViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  initialise() async {
    weekFirstDay = await WeekFirstDay();
    weekLastDay = await WeekLastDay();
    user = await AuthServices.getCurrentUser();
    fetchVendorDetails();
  }

  //
  fetchVendorDetails() async {
    //
    clearErrors();
    setBusy(true);
    //
    try {
      final response = await vendorRequest.getVendorDetails();
      totalEarning = double.parse(response["total_earnig"].toString());
      totalOrders = response["total_orders"];
      vendor = Vendor.fromJson(response["vendor"]);
      weeklySales =
          (response["report"] as List)
              .map((e) => double.parse(e["value"].toString()))
              .toList();
      notifyListeners();
      clearErrors();
    } catch (error, stackTrace) {
      CrashlyticsService.recordError(
        error,
        stackTrace,
        reason: "fetchVendoretails",
      );
      setError(
        "An error occurred fetching vendor details. Please try again".tr(),
      );
    }
    setBusy(false);
  }

  openVendorProfileSwitcher() async {
    await showModalBottomSheet(
      context: viewContext,
      builder: (context) {
        return VendorSwitcherBottomSheetView();
      },
    );
  }

  toggleVendorAvailablity() async {
    final willOpen = !vendor!.isOpen;
    final confirmed = await AlertService.showConfirm(
      title: willOpen ? "Open".tr() : "Close".tr(),
      text: willOpen
          ? "Are you sure you want to open your store?".tr()
          : "Are you sure you want to close your store?".tr(),
      confirmBtnText: "Yes".tr(),
    );
    if (!confirmed) {
      return;
    }

    setBusyForObject(vendor!.isOpen, true);

    //
    final apiResponse = await vendorRequest.toggleVendorAvailablity(vendor!);
    if (apiResponse.allGood) {
      vendor!.isOpen = !vendor!.isOpen;
      notifyListeners();
    }

    //
    AlertService.dynamic(
      type: apiResponse.allGood ? AlertType.success : AlertType.error,
      title: "Vendor Details".tr(),
      text: apiResponse.message,
    );
    setBusyForObject(vendor!.isOpen, false);
  }

  openSubscriptionPage() async {
    try {
      final url = await Api.redirectAuth(
        url: Api.subscription,
        route: "my.subscribe",
      );
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);
      } else {
        await viewContext.push(
          (context) => CustomWebviewPage(selectedUrl: url),
        );
      }
      fetchVendorDetails();
    } catch (error) {
      print("Error ==> $error");
    }
  }

  // DateTime.weekday indices (Mon = 1 .. Sun = 7) of the day the week
  // starts on, and the number of days to subtract from `today` to reach it.
  int get _weekStartWeekday => Utils.isArabic ? DateTime.saturday : DateTime.monday;

  // Order of DateTime.weekday values (Mon = 1 .. Sun = 7), starting from
  // the first day of the week, used to lay out the chart's x-axis.
  List<int> get weekdayOrder {
    final start = _weekStartWeekday;
    return List.generate(7, (i) => ((start - 1 + i) % 7) + 1);
  }

  Future<String> WeekFirstDay() async {
    DateTime today = DateTime.now();
    final daysSinceStart = (today.weekday - _weekStartWeekday + 7) % 7;
    final formattedDate = today.subtract(Duration(days: daysSinceStart));
    await Jiffy.setLocale(translator.activeLocale.languageCode);
    return Jiffy.parseFromMillisecondsSinceEpoch(
      formattedDate.millisecondsSinceEpoch,
    ).yMMMEd;
  }

  Future<String> WeekLastDay() async {
    DateTime today = DateTime.now();
    final daysSinceStart = (today.weekday - _weekStartWeekday + 7) % 7;
    final formattedDate = today.add(
      Duration(days: DateTime.daysPerWeek - 1 - daysSinceStart),
    );
    await Jiffy.setLocale(translator.activeLocale.languageCode);
    return Jiffy.parseFromMillisecondsSinceEpoch(
      formattedDate.millisecondsSinceEpoch,
    ).yMMMEd;
  }

  //
  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) {
            return Colors.blueGrey;
          },
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            const names = {
              DateTime.monday: 'Monday',
              DateTime.tuesday: 'Tuesday',
              DateTime.wednesday: 'Wednesday',
              DateTime.thursday: 'Thursday',
              DateTime.friday: 'Friday',
              DateTime.saturday: 'Saturday',
              DateTime.sunday: 'Sunday',
            };
            final weekDay = names[weekdayOrder[group.x.toInt()]]!.tr();
            return BarTooltipItem(
              "$weekDay\n",
              TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: (rod.fromY - 1).toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          if (barTouchResponse?.spot != null &&
              event is! PointerUpEvent &&
              event is! PointerExitEvent) {
            touchedIndex = barTouchResponse?.spot?.touchedBarGroupIndex;
          } else {
            touchedIndex = -1;
          }
          notifyListeners();
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 10,
            getTitlesWidget: (double value, TitleMeta meta) {
              final style = TextStyle(
                color: Utils.textColorByTheme(),
                fontWeight: FontWeight.w400,
                fontSize: 12,
              );
              const shortNames = {
                DateTime.monday: 'Mon',
                DateTime.tuesday: 'Tue',
                DateTime.wednesday: 'Wed',
                DateTime.thursday: 'Thur',
                DateTime.friday: 'Fri',
                DateTime.saturday: 'Sat',
                DateTime.sunday: 'Sun',
              };
              final index = value.toInt();
              final Widget text =
                  index >= 0 && index < weekdayOrder.length
                      ? shortNames[weekdayOrder[index]]!.tr().text
                          .textStyle(style)
                          .make()
                      : ''.text.make();

              return SideTitleWidget(
                meta: meta,
                // fitInside: SideTitleFitInsideData(enabled: true, axisPosition: meta.axisPosition, parentAxisSize: meta.parentAxisSize, distanceFromEdge: meta.),
                // axisSide: meta.axisSide,
                space: 0,
                child: text,
              );
            },
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          axisNameWidget:
              "Amount".tr().text.color(Utils.textColorByTheme()).make(),
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return "${meta.formattedValue}".text.sm
                  .color(Utils.textColorByTheme())
                  .make();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: showingGroups(),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = Colors.white,
    double width = 20,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: barColor,
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            color: AppColor.primaryColorDark
                .withValues(alpha: 0.90)
                .withAlpha(150),
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
    final salesIndex = weekdayOrder[i] - 1; // weekday (1-7) -> weeklySales index (0-6)
    return makeGroupData(
      i,
      weeklySales[salesIndex],
      isTouched: i == touchedIndex,
    );
  });

  //
  requestPayout() async {
    showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PayoutBottomSheet(totalEarningAmount: totalEarning);
      },
    );
  }
}
