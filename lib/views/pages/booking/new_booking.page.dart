import 'package:flutter/material.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';

class NewBookingPage extends StatelessWidget {
  const NewBookingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "New Property".tr(),
      showAppBar: true,
      showLeadingAction: true,
      body:
          VStack(
            [
              // Icon
              Icon(
                Icons.add_home_work_outlined,
                size: 80,
                color: AppColor.primaryColor,
              ).centered(),
              UiSpacer.vSpace(20),

              // Title
              "Create Property via Web Dashboard"
                  .tr()
                  .text
                  .xl2
                  .bold
                  .center
                  .make(),
              UiSpacer.vSpace(10),

              // Description
              "To ensure all details are captured correctly, creating a new property is handled through our secure web dashboard. This allows for detailed input of amenities, improved photo uploads, and location settings."
                  .tr()
                  .text
                  .center
                  .gray500
                  .make(),
              UiSpacer.vSpace(30),

              // Button
              CustomButton(
                title: "Open Web Dashboard".tr(),
                color: AppColor.primaryColor,
                onPressed: () async {
                  String url = await Api.redirectAuth(route: "properties");
                  if (await canLaunchUrlString(url)) {
                    await launchUrlString(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    context.showToast(
                      msg: "Could not launch web dashboard".tr(),
                      bgColor: Colors.red,
                    );
                  }
                },
              ).wFull(context),
            ],
            crossAlignment: CrossAxisAlignment.center,
          ).p(Sizes.paddingSizeDefault).scrollVertical(),
    );
  }
}
