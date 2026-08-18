import 'package:flutter/material.dart';
import 'package:fuodz/models/menu.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/requests/vendor.request.dart';
import 'package:fuodz/view_models/base.view_model.dart';

class MenuFilterViewModel extends MyBaseViewModel {
  //
  MenuFilterViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  VendorRequest vendorRequest = VendorRequest();
  List<Menu> menus = [];
  Menu? selectedMenu;

  @override
  void initialise() {
    fetchMenus();
  }

  fetchMenus() async {
    setBusy(true);
    try {
      final response = await vendorRequest.getVendorDetails();
      final vendor = Vendor.fromJson(response["vendor"]);
      menus = vendor.menus;
      clearErrors();
    } catch (error) {
      print("menus Error ==> $error");
      setError(error);
    }
    setBusy(false);
  }

  //
  selectMenu(Menu? menu, {required ValueChanged<Menu?> onSelected}) {
    selectedMenu = menu;
    notifyListeners();
    onSelected(menu);
  }
}
