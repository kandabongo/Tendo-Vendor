import 'package:flutter/material.dart';
import 'package:fuodz/extensions/context.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/requests/booking.request.dart';
import 'package:fuodz/requests/order.request.dart';
import 'package:fuodz/view_models/order_details.vm.dart';
import 'package:fuodz/views/pages/booking/property_details.page.dart';
import 'package:fuodz/views/pages/order/widgets/booking_order_check_in_out_verification.bottom_sheet.dart';
import 'package:fuodz/widgets/bottomsheets/order_edit_status.bottomsheet.dart';
import 'package:velocity_x/velocity_x.dart';

class BookingOrderDetailsViewModel extends OrderDetailsViewModel {
  //
  Order order;
  OrderRequest orderRequest = OrderRequest();
  BookingRequest bookingRequest = BookingRequest();
  bool changed = false;

  //
  BookingOrderDetailsViewModel(BuildContext context, this.order)
    : super(context, order) {
    this.viewContext = context;
  }

  void showPropertyDetails(Property property) {
    viewContext.nextPage(PropertyDetailsPage(property));
  }

  //Edit status
  void changeOrderStatus() async {
    showModalBottomSheet(
      context: viewContext,
      builder: (context) {
        return OrderEditStatusBottomSheet(
          bookingOrder: true,
          order.status,
          onConfirm: (value) {
            viewContext.pop();
            processStatusUpdate(value);
          },
        );
      },
    );
  }

  //
  void verifyUserCode(String nextStatus) async {
    final result = await showModalBottomSheet(
      context: viewContext,
      builder: (context) {
        return BookingOrderCheckInOutVerificationBottomSheet(
          nextStatus: nextStatus,
          order: order,
        );
      },
    );

    if (result != null) {
      fetchOrderDetails();
    }
  }

  processBookingStatusUpdate(String status, [String? code]) async {
    setBusyForObject(order, true);
    try {
      order = await bookingRequest.updateBookingStatus(
        order.id,
        status,
        code: code,
      );
      //beaware a change as occurred
      changed = true;
      clearErrors();
    } catch (error) {
      print("Error ==> $error");
      setErrorForObject(order, error);
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    setBusyForObject(order, false);
  }
}
