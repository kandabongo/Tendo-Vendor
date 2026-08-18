import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/extensions/context.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/buttons/custom_leading.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class AccountVerificationEntry extends StatefulWidget {
  const AccountVerificationEntry({
    required this.onSubmit,
    required this.vm,
    this.instruction,
    Key? key,
  }) : super(key: key);

  final Function(String) onSubmit;
  final MyBaseViewModel vm;
  final String? instruction;

  @override
  _AccountVerificationEntryState createState() =>
      _AccountVerificationEntryState();
}

class _AccountVerificationEntryState extends State<AccountVerificationEntry> {
  String smsCode = "";
  @override
  Widget build(BuildContext context) {
    //
    final pinWidth = context.percentWidth * 70;
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      appBarItemColor: AppColor.primaryColor,
      title: "Verification Code".tr(),
      elevation: 0,
      leading: CustomLeading().onInkTap(() {
        context.pop();
      }),
      child: VStack(
        [
          //
          "Verify your phone number".tr().text.bold.xl2.makeCentered(),
          (widget.instruction ??
                  "Enter otp sent to your provided phone number".tr())
              .text
              .makeCentered(),
          //pin code
          MaterialPinField(
            length: 6,
            obscureText: false,
            keyboardType: TextInputType.number,
            theme: MaterialPinTheme(
              shape: MaterialPinShape.underlined,
              cellSize: Size(pinWidth / 7, 50),
              textStyle: context.textTheme.bodyLarge!.copyWith(fontSize: 16),
              borderColor: AppColor.accentColor,
              focusedBorderColor: AppColor.primaryColor,
              filledBorderColor: AppColor.primaryColor,
            ),
            onCompleted: (pin) {
              print("Completed");
              print("Pin ==> $pin");
              smsCode = pin;
            },
            onChanged: (value) {
              smsCode = value;
            },
          ).w(pinWidth).centered().p12(),

          //submit
          CustomButton(
            title: "Verify".tr(),
            loading: widget.vm.busy(widget.vm.firebaseVerificationId),
            onPressed: () => widget.onSubmit(smsCode),
          ),
        ],
      ).p20(),
    );
  }
}
