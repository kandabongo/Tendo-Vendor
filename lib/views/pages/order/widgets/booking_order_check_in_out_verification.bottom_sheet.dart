import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/context.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/requests/booking.request.dart';
import 'package:fuodz/services/custom_form_builder_validator.service.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class BookingOrderCheckInOutVerificationBottomSheet extends StatefulWidget {
  const BookingOrderCheckInOutVerificationBottomSheet({
    required this.order,
    required this.nextStatus,
    super.key,
  });

  final Order order;
  final String nextStatus;

  @override
  State<BookingOrderCheckInOutVerificationBottomSheet> createState() =>
      _BookingOrderCheckInOutVerificationBottomSheetState();
}

class _BookingOrderCheckInOutVerificationBottomSheetState
    extends State<BookingOrderCheckInOutVerificationBottomSheet> {
  bool isLoading = false;
  final _bookingRequest = BookingRequest();
  final _verificationCodeController = TextEditingController();

  //mics.
  _showLoading() {
    setState(() {
      isLoading = true;
    });
  }

  _hideLoading() {
    setState(() {
      isLoading = false;
    });
  }

  _verifyUserCode(String nextStatus) async {
    if (_verificationCodeController.text.isEmpty) {
      context.showToast(
        msg: "Please enter verification code".tr(),
        bgColor: Colors.red,
      );
      return;
    }

    _showLoading();
    try {
      await _bookingRequest.updateBookingStatus(
        widget.order.id,
        nextStatus,
        code: _verificationCodeController.text,
      );
      context.pop(true);
      return;
    } catch (error) {
      context.showToast(msg: "$error", bgColor: Colors.red);
    }
    _hideLoading();
  }

  @override
  Widget build(BuildContext context) {
    bool isCheckIn = widget.nextStatus == 'checkin';
    String title =
        isCheckIn ? "Check-in Verification" : "Check-out Verification";
    String description =
        isCheckIn
            ? "Ask the guest for the check-in verification code to confirm their arrival."
            : "Ask the guest for the check-out verification code to complete their stay.";

    return Container(
      padding: EdgeInsets.only(
        left: Sizes.paddingSizeDefault,
        right: Sizes.paddingSizeDefault,
        top: Sizes.paddingSizeDefault,
        bottom: Sizes.paddingSizeDefault,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        minHeight: context.percentHeight * 40,
        maxHeight: context.percentHeight * 70,
      ),
      child: SafeArea(
        top: false,
        child: VStack(
          [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            0.heightBox,

            VStack([
              // Title
              title.tr().text.xl2.bold.center.makeCentered(),
              5.heightBox,
              // Description
              description.tr().text.gray500.center.makeCentered(),
            ]),

            // Input Field
            TextFormField(
              controller: _verificationCodeController,
              // keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                hintText: "Enter Code".tr(),
                filled: true,
                fillColor: context.theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Sizes.radiusDefault),
                  borderSide: BorderSide(color: Vx.gray300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Sizes.radiusDefault),
                  borderSide: BorderSide(color: Vx.gray300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Sizes.radiusDefault),
                  borderSide: BorderSide(color: AppColor.primaryColor),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
              validator: CustomFormBuilderValidator.required,
            ).box.make(),

            // Verify Button
            CustomButton(
              loading: isLoading,
              title: "Verify & Complete".tr(),
              color: AppColor.primaryColor,
              shapeRadius: 12,
              onPressed: () {
                _verifyUserCode(widget.nextStatus);
              },
            ).h(50).wFull(context),
          ],
          crossAlignment: CrossAxisAlignment.center,
          spacing: Sizes.paddingSizeDefault,
        ).scrollVertical(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
        ),
      ),
    );
  }
}
