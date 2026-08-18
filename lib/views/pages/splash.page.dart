import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:fuodz/view_models/splash.vm.dart';
import 'package:fuodz/widgets/alternative.view.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: ViewModelBuilder<SplashViewModel>.reactive(
        viewModelBuilder: () => SplashViewModel(context),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, model, child) {
          final double imgSize = context.percentWidth * 45;
          return AlternativeView(
            ismain: !model.hasError,
            main: Center(
              child: VStack(
                [
                  //
                  Image.asset(
                    AppImages.appLogo,
                    width: imgSize,
                    height: imgSize,
                  ).box.clip(Clip.antiAlias).roundedSM.make(),
                  LinearProgressIndicator().w(imgSize),
                ],
                crossAlignment: CrossAxisAlignment.center,
                alignment: MainAxisAlignment.center,
                spacing: 20,
              ),
            ),
            alt: _buildReloadView(context, model),
          );
        },
      ),
    );
  }

  //
  Widget _buildReloadView(BuildContext context, SplashViewModel vm) {
    return VStack([
      Icon(FlutterIcons.alert_triangle_fea, color: Colors.red, size: 60).py12(),
      "Something went wrong".tr().text.xl.semiBold.makeCentered(),
      "${vm.modelError ?? 'Please check your internet connection and try again'}"
          .text
          .center
          .gray500
          .makeCentered()
          .py8(),
      CustomButton(
        title: "Reload".tr(),
        icon: FlutterIcons.refresh_cw_fea,
        onPressed: () => vm.initialise(),
      ).w32(context).py12(),
    ], crossAlignment: CrossAxisAlignment.center).centered().p20();
  }
}
