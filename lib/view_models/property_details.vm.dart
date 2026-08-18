import 'package:fuodz/models/property.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/extensions/context.dart';
import 'package:fuodz/views/pages/booking/edit_property.page.dart';

class PropertyDetailsViewModel extends MyBaseViewModel {
  //
  PropertyDetailsViewModel(BuildContext context, this.property) {
    this.viewContext = context;
  }
  Property property;

  goBack() {
    viewContext.pop(property);
  }

  manageProperty() async {
    //
    final result = await viewContext.push(
      (context) => EditPropertyPage(property),
    );
    if (result != null && result is Property) {
      property = result;
      notifyListeners();
    }
  }
}
