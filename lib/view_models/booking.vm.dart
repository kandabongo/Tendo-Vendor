import 'package:flutter/material.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/requests/property.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/views/pages/booking/new_booking.page.dart';
import 'package:fuodz/views/pages/booking/property_details.page.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:fuodz/extensions/context.dart';

class BookingViewModel extends MyBaseViewModel {
  //
  BookingViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  final _propertyRequest = PropertyRequest();
  List<Property> properties = [];
  RefreshController refreshController = RefreshController();
  int queryPage = 1;
  String keyword = "";

  void initialise() {
    fetchMyProperties();
  }

  //
  fetchMyProperties({bool initialLoading = true}) async {
    if (initialLoading) {
      properties.clear();
      queryPage = 1;
      setBusy(true);
      refreshController.resetNoData();
      refreshController.refreshCompleted();
    } else {
      queryPage += 1;
    }

    try {
      final mProperties = await _propertyRequest.getProperties(
        queryParams: {
          "vendor_id": await AuthServices.currentVendor?.id,
          "keyword": keyword,
        },
        page: queryPage,
      );

      //
      properties.addAll(mProperties);
      if (mProperties.isEmpty) {
        refreshController.loadNoData();
      }
      clearErrors();
    } catch (error) {
      print("Package Type Pricing Error ==> $error");
      setError(error);
    }

    refreshController.loadComplete();
    setBusy(false);
  }

  //
  serviceSearch(String value) {
    keyword = value;
    fetchMyProperties();
  }

  openPropertyDetails(Property property) async {
    final result = await viewContext.push(
      (context) => PropertyDetailsPage(property),
    );
    if (result != null && result) {
      properties.removeWhere((e) => e.id == property.id);
    } else if (result != null && result is Property) {
      final index = properties.indexWhere((e) => e.id == property.id);
      if (index >= 0) {
        properties[index] = result;
      }
    }
    notifyListeners();
  }

  void newBooking() async {
    final result = await viewContext.push((context) => NewBookingPage());
    if (result != null) {
      fetchMyProperties();
    }
  }
}
