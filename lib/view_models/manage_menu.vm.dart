import 'package:fuodz/services/alert.service.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/models/menu.dart';
import 'package:fuodz/requests/menu.request.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/extensions/context.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ManageMenuViewModel extends MyBaseViewModel {
  //
  ManageMenuViewModel(BuildContext context, this.menu) {
    this.viewContext = context;
  }

  //
  MenuRequest menuRequest = MenuRequest();
  Menu? menu;

  bool get isEditing => menu != null;

  //name fields for mass new entry (only applicable when creating)
  List<TextEditingController> nameControllers = [TextEditingController()];

  //
  addNameField() {
    nameControllers.add(TextEditingController());
    notifyListeners();
  }

  removeNameField(int index) {
    if (nameControllers.length <= 1) return;
    nameControllers.removeAt(index).dispose();
    notifyListeners();
  }

  //
  processSave() async {
    if (isEditing) {
      await processEdit();
    } else {
      await processNewEntries();
    }
  }

  processEdit() async {
    if (!formBuilderKey.currentState!.saveAndValidate()) return;
    setBusy(true);

    try {
      final apiResponse = await menuRequest.updateMenu(
        menu!,
        formBuilderKey.currentState!.value,
      );
      AlertService.dynamic(
        type: apiResponse.allGood ? AlertType.success : AlertType.error,
        title: "Successful".tr(),
        text: apiResponse.message,
        onConfirm: () {
          if (apiResponse.allGood) {
            viewContext.pop(true);
          }
        },
      );
      clearErrors();
    } catch (error) {
      print("Save Menu Error ==> $error");
      setError(error);
    }

    setBusy(false);
  }

  processNewEntries() async {
    final names =
        nameControllers
            .map((controller) => controller.text.trim())
            .where((name) => name.isNotEmpty)
            .toList();

    if (names.isEmpty) {
      AlertService.dynamic(
        type: AlertType.error,
        title: "Menu".tr(),
        text: "Please enter at least one menu name".tr(),
      );
      return;
    }

    setBusy(true);

    try {
      final apiResponse = await menuRequest.newMenu(names: names);
      //
      AlertService.dynamic(
        type: apiResponse.allGood ? AlertType.success : AlertType.error,
        title: "Successful".tr(),
        text: apiResponse.message,
        onConfirm: () {
          if (apiResponse.allGood) {
            viewContext.pop(true);
          }
        },
      );
      clearErrors();
    } catch (error) {
      print("Save Menu Error ==> $error");
      setError(error);
    }

    setBusy(false);
  }
}
