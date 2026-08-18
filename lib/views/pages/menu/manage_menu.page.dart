import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/models/menu.dart';
import 'package:fuodz/services/custom_form_builder_validator.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/manage_menu.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ManageMenuPage extends StatelessWidget {
  const ManageMenuPage([this.menu, Key? key]) : super(key: key);

  final Menu? menu;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ManageMenuViewModel>.reactive(
      viewModelBuilder: () => ManageMenuViewModel(context, menu),
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          appBarColor: context.primaryColor,
          appBarItemColor: Utils.textColorByPrimaryColor(),
          title: vm.isEditing ? "Edit Menu".tr() : "New Menu".tr(),
          body: SafeArea(
            top: true,
            bottom: false,
            child:
                FormBuilder(
                  key: vm.formBuilderKey,
                  child: VStack([
                    //description
                    (vm.isEditing
                            ? "Update this menu's name."
                            : "Menus help you group products together — e.g. Rice, Drinks, Combos. Add a name below, or add multiple menus at once.")
                        .tr()
                        .text
                        .sm
                        .color(Vx.zinc500)
                        .make(),
                    UiSpacer.verticalSpace(),
                    //
                    if (vm.isEditing) ...[
                      //name
                      FormBuilderTextField(
                        name: 'name',
                        initialValue: vm.menu?.name,
                        decoration: InputDecoration(labelText: 'Name'.tr()),
                        validator: CustomFormBuilderValidator.required,
                      ),
                    ] else ...[
                      //repeatable name fields
                      ...vm.nameControllers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final controller = entry.value;
                        return HStack([
                          TextFormField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: "Menu name".tr(),
                            ),
                          ).expand(),
                          if (vm.nameControllers.length > 1)
                            IconButton(
                              onPressed: () => vm.removeNameField(index),
                              icon: Icon(FlutterIcons.trash_fea),
                              color: Colors.red,
                            ),
                        ]).py4();
                      }),
                      //add another
                      TextButton.icon(
                        onPressed: vm.addNameField,
                        icon: Icon(FlutterIcons.plus_fea),
                        label: "Add another menu".tr().text.make(),
                      ),
                    ],
                    UiSpacer.verticalSpace(),
                    //
                    CustomButton(
                      title: "Save".tr(),
                      loading: vm.isBusy,
                      onPressed: vm.processSave,
                    ).centered().py12(),
                  ]),
                ).p20().scrollVertical(),
          ),
        );
      },
    );
  }
}
