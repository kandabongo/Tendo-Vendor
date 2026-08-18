import 'package:fuodz/services/alert.service.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/models/menu.dart';
import 'package:fuodz/requests/menu.request.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/views/pages/menu/manage_menu.page.dart';
import 'package:fuodz/extensions/context.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class MenuListViewModel extends MyBaseViewModel {
  //
  MenuListViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  MenuRequest menuRequest = MenuRequest();
  List<Menu> menus = [];

  void initialise() {
    fetchMenus();
  }

  fetchMenus() async {
    setBusy(true);
    try {
      menus = await menuRequest.getMenus();
      clearErrors();
    } catch (error) {
      print("Menus Error ==> $error");
      setError(error);
    }
    setBusy(false);
  }

  //
  newMenu() async {
    final result = await viewContext.push(
      (context) => ManageMenuPage(),
    );
    if (result != null) {
      fetchMenus();
    }
  }

  editMenu(Menu menu) async {
    final result = await viewContext.push(
      (context) => ManageMenuPage(menu),
    );
    if (result != null) {
      fetchMenus();
    }
  }

  deleteMenu(Menu menu) {
    AlertService.confirm(
      title: "Delete Menu".tr(),
      text: "Are you sure you want to delete".tr() + " ${menu.name}?",
      onConfirm: () {
        processDeletion(menu);
      },
    );
  }

  processDeletion(Menu menu) async {
    setBusyForObject(menu.id, true);
    try {
      final apiResponse = await menuRequest.deleteMenu(menu);
      //
      if (apiResponse.allGood) {
        menus.removeWhere((element) => element.id == menu.id);
      }
      //show dialog to present state
      AlertService.dynamic(
        type: apiResponse.allGood ? AlertType.success : AlertType.error,
        title: "Delete Menu".tr(),
        text: apiResponse.message,
      );
      clearErrors();
    } catch (error) {
      print("Delete Menu Error ==> $error");
      setError(error);
    }
    setBusyForObject(menu.id, false);
  }
}
