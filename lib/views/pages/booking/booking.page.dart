import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/view_models/booking.vm.dart';
import 'package:fuodz/views/pages/booking/widgets/property.list_item.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/custom_text_form_field.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ViewModelBuilder<BookingViewModel>.reactive(
        viewModelBuilder: () => BookingViewModel(context),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return BasePage(
            fab: FloatingActionButton.extended(
              backgroundColor: AppColor.primaryColor,
              onPressed: vm.newBooking,
              label: "New Property".tr().text.white.make(),
              icon: Icon(FlutterIcons.plus_fea, color: Colors.white),
            ),
            body: VStack([
              "Properties".tr().text.xl2.semiBold.make().p20(),
              //search bar
              CustomTextFormField(
                hintText: "Search".tr(),
                onFieldSubmitted: vm.serviceSearch,
              ).px20(),
              15.heightBox,
              //
              CustomListView(
                refreshController: vm.refreshController,
                canRefresh: true,
                canPullUp: true,
                onRefresh: vm.fetchMyProperties,
                onLoading: () => vm.fetchMyProperties(initialLoading: false),
                isLoading: vm.isBusy,
                dataSet: vm.properties,
                padding: EdgeInsets.only(bottom: context.percentHeight * 10),
                itemBuilder: (context, index) {
                  return PropertyListItem(
                    property: vm.properties[index],
                    onPressed: vm.openPropertyDetails,
                  ).px20();
                },
              ).expand(),
            ]),
          );
        },
      ),
    );
  }
}
