import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/models/package_type_pricing.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class PackageTypePricingListItem extends StatelessWidget {
  //
  const PackageTypePricingListItem(
    this.packageTypePricing, {
    this.isLoading = false,
    required this.onEditPressed,
    required this.onToggleStatusPressed,
    required this.onDeletePressed,
    Key? key,
  }) : super(key: key);

  //
  final PackageTypePricing packageTypePricing;
  final bool isLoading;
  final Function(PackageTypePricing) onEditPressed;
  final Function(PackageTypePricing) onToggleStatusPressed;
  final Function(PackageTypePricing) onDeletePressed;
  @override
  Widget build(BuildContext context) {
    //
    final currencySymbol = AppStrings.currencySymbol;

    //
    return VStack([
          //header: name/description + actions
          HStack(
            [
              //Details
              VStack([
                //name
                packageTypePricing.packageType.name.text.lg.semiBold.make(),
                //description
                "${packageTypePricing.packageType.description}".text.sm.light
                    .maxLines(2)
                    .overflow(TextOverflow.ellipsis)
                    .make(),
              ], spacing: 2).expand(),

              //actions
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                padding: EdgeInsets.zero,
                color: context.primaryColor,
                onPressed:
                    isLoading
                        ? null
                        : () => onEditPressed(packageTypePricing),
                icon: Icon(FlutterIcons.edit_2_fea),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                padding: EdgeInsets.zero,
                color:
                    packageTypePricing.isActive != 1
                        ? Colors.green
                        : Colors.red[400],
                onPressed:
                    isLoading
                        ? null
                        : () => onToggleStatusPressed(packageTypePricing),
                icon: Icon(
                  packageTypePricing.isActive != 1
                      ? FlutterIcons.check_ant
                      : FlutterIcons.close_ant,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                padding: EdgeInsets.zero,
                color: Colors.red,
                onPressed:
                    isLoading
                        ? null
                        : () => onDeletePressed(packageTypePricing),
                icon: Icon(FlutterIcons.trash_fea),
              ),
            ],
            crossAlignment: CrossAxisAlignment.start,
          ),

          UiSpacer.divider().py8(),

          //Package & distance price
          HStack(
            [
              //
              VStack([
                //base price
                "Base Price".tr().text.xs.medium.make(),
                //description
                "$currencySymbol ${packageTypePricing.basePrice}"
                    .currencyFormat()
                    .text
                    .sm
                    .semiBold
                    .make(),
              ]).expand(),

              //
              VStack([
                //Package price
                "Package Price".tr().text.xs.medium.make(),
                //description
                "$currencySymbol ${packageTypePricing.sizePrice}"
                    .currencyFormat()
                    .text
                    .sm
                    .semiBold
                    .make(),
              ]).expand(),
              //
              VStack([
                //Distance price
                "Distance Price".tr().text.xs.medium.make(),
                //description
                "$currencySymbol ${packageTypePricing.distancePrice}"
                    .currencyFormat()
                    .text
                    .sm
                    .semiBold
                    .make(),
              ]).expand(),
            ],
            crossAlignment: CrossAxisAlignment.start,
          ),

          //Auto ready, extra fields & max booking days
          HStack(
            [
              VStack([
                //Auto ready
                "Auto Ready".tr().text.xs.medium.make(),
                //description
                "${packageTypePricing.autoReady}".text
                    .color(
                      packageTypePricing.autoReady
                          ? Colors.green
                          : Colors.red,
                    )
                    .sm
                    .semiBold
                    .make(),
              ]).expand(),
              //
              VStack([
                //Extra fields
                "Extra fields".tr().text.xs.medium.make(),
                "${packageTypePricing.extraFields}".text
                    .color(
                      packageTypePricing.extraFields
                          ? Colors.green
                          : Colors.red,
                    )
                    .sm
                    .semiBold
                    .make(),
              ]).expand(),

              ////Max booking days
              VStack([
                //
                "Max booking days".tr().text.xs.medium.make(),
                //description
                "${packageTypePricing.maxBookingDays}".text.sm.semiBold
                    .make(),
              ]).expand(),
            ],
            crossAlignment: CrossAxisAlignment.start,
          ).pOnly(top: Vx.dp8),
        ], spacing: 0)
        .p12()
        .box
        .border(color: Vx.zinc200)
        .withRounded(value: Sizes.radiusDefault)
        .make();
  }
}
