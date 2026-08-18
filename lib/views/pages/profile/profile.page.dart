import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/view_models/profile.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/cards/profile.card.dart';
import 'package:fuodz/widgets/menu_item.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: ViewModelBuilder<ProfileViewModel>.reactive(
        viewModelBuilder: () => ProfileViewModel(context),
        onViewModelReady: (model) => model.initialise(),
        builder: (context, model, child) {
          return BasePage(
            body:
                VStack([
                  //
                  "Settings".tr().text.xl2.semiBold.make(),
                  "Profile & App Settings".tr().text.lg.light.make(),

                  //profile card
                  ProfileCard(model).py12(),
                  // 10.heightBox,
                  VxBox(
                        child: VStack([
                          //printer settings
                          MenuItem(
                            title: "Printing Settings".tr(),
                            onPressed: model.openPrinterSettings,
                            prefix: Icon(FlutterIcons.printer_ant),
                          ),
                          //
                          MenuItem(
                            title: "Language".tr(),
                            prefix: Icon(FlutterIcons.language_ent),
                            onPressed: model.changeLanguage,
                          ),
                          MenuItem(
                            title: "Theme".tr(),
                            suffix: Text(
                              AdaptiveTheme.of(
                                context,
                              ).mode.name.tr().capitalized,
                            ),
                            prefix: HugeIcon(
                              icon:
                                  HugeIcons.strokeRoundedArrowReloadHorizontal,
                            ),
                            onPressed: () {
                              AdaptiveTheme.of(context).toggleThemeMode();
                            },
                            divider: false,
                          ),
                        ], spacing: 10),
                      )
                      .border(color: Vx.zinc200)
                      .withRounded(value: Sizes.radiusSmall)
                      .make(),
                  20.heightBox,

                  //menu
                  VxBox(
                        child: VStack([
                          //
                          MenuItem(
                            title: "Notifications".tr(),
                            prefix: HugeIcon(
                              icon: HugeIcons.strokeRoundedBellDot,
                            ),
                            onPressed: model.openNotification,
                          ),

                          //
                          MenuItem(
                            title: "Rate & Review".tr(),
                            prefix: HugeIcon(icon: HugeIcons.strokeRoundedStar),
                            onPressed: model.openReviewApp,
                          ),
                          MenuItem(
                            title: "Faqs".tr(),
                            prefix: HugeIcon(
                              icon: HugeIcons.strokeRoundedQuestion,
                            ),
                            onPressed: model.openFaqs,
                          ),

                          //
                          MenuItem(
                            title: "Privacy Policy".tr(),
                            prefix: HugeIcon(
                              icon: HugeIcons.strokeRoundedShield01,
                            ),
                            onPressed: model.openPrivacyPolicy,
                          ),
                          //
                          MenuItem(
                            title: "Contact Us".tr(),
                            prefix: HugeIcon(
                              icon: HugeIcons.strokeRoundedMail01,
                            ),
                            onPressed: model.openContactUs,
                          ),
                          MenuItem(
                            title: "Live support".tr(),
                            divider: false,
                            prefix: HugeIcon(
                              icon: HugeIcons.strokeRoundedMessage01,
                            ),
                            onPressed: model.openLivesupport,
                          ),
                        ]),
                      )
                      .border(color: Vx.zinc200)
                      .withRounded(value: Sizes.radiusSmall)
                      .make(),
                  20.heightBox,
                  VxBox(
                        child: VStack([
                          //
                          MenuItem(
                            child: "Logout".tr().text.bold.lg.make(),
                            onPressed: model.logoutPressed,
                            suffix: Icon(FlutterIcons.logout_ant, size: 16),
                          ),
                          MenuItem(
                            child: "Delete Account".tr().text.red500.lg.make(),
                            onPressed: model.deleteAccount,
                            divider: false,
                            suffix: Icon(
                              FlutterIcons.x_circle_fea,
                              size: 16,
                              color: Vx.red600,
                            ),
                          ),
                        ]),
                      )
                      .border(color: Vx.zinc200)
                      .withRounded(value: Sizes.radiusSmall)
                      .make(),

                  //version
                  model.appVersionInfo.text.sm.gray400.makeCentered().py20(),
                ], spacing: 10).p20().scrollVertical(),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
