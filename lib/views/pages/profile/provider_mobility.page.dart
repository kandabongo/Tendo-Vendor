import 'package:flutter/material.dart';
import 'package:fuodz/view_models/provider_mobility.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

/// Assist → Provider Mobility settings screen.
class ProviderMobilityPage extends StatelessWidget {
  const ProviderMobilityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showLeadingAction: true,
      showAppBar: true,
      title: "Provider Mobility".tr(),
      body: ViewModelBuilder<ProviderMobilityViewModel>.reactive(
        viewModelBuilder: () => ProviderMobilityViewModel(context),
        onViewModelReady: (model) => model.initialise(),
        builder: (context, model, child) {
          if (model.isBusy) {
            return const Center(child: CircularProgressIndicator());
          }
          return VStack(
            [
              "How you attend Assist jobs".tr().text.lg.semiBold.make(),
              8.heightBox,
              "Choose your transport preference and set your own-vehicle travel rate. Rates are limited by Tendo and finalised on the server."
                  .tr()
                  .text
                  .gray600
                  .sm
                  .make(),
              20.heightBox,

              // Transport preference
              "Transport preference".tr().text.semiBold.make(),
              DropdownButton<String>(
                isExpanded: true,
                value: model.transportMode,
                items: model.transportModes.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: model.modeLabel(e).text.make(),
                  );
                }).toList(),
                onChanged: model.setTransportMode,
              ),
              20.heightBox,

              // Own-vehicle travel rate
              "Travel rate per km".tr().text.semiBold.make(),
              8.heightBox,
              TextField(
                controller: model.rateTEC,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: "e.g. 10".tr(),
                  border: const OutlineInputBorder(),
                  prefixText: "${model.currencySymbol} ",
                ),
              ),
              6.heightBox,
              "Allowed range: %min - %max per km"
                  .tr()
                  .replaceAll("%min", model.rateMin.toString())
                  .replaceAll("%max", model.rateMax.toString())
                  .text
                  .gray500
                  .xs
                  .make(),
              if (model.effectiveRate != null) ...[
                4.heightBox,
                "Current effective rate: %r per km"
                    .tr()
                    .replaceAll("%r", model.effectiveRate!.toString())
                    .text
                    .gray600
                    .xs
                    .make(),
              ],

              24.heightBox,
              CustomButton(
                title: "Save".tr(),
                loading: model.isBusy,
                onPressed: model.save,
              ).wFull(context),
            ],
          ).p20().scrollVertical();
        },
      ),
    );
  }
}
