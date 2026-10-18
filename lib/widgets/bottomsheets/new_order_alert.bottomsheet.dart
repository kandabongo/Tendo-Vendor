import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/requests/assist_job.request.dart';
import 'package:fuodz/services/assist_job.service.dart';
import 'package:fuodz/requests/order.request.dart';
import 'package:fuodz/views/pages/order/orders_details.page.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/buttons/custom_text_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class NewOrderAlertBottomsheet extends StatefulWidget {
  const NewOrderAlertBottomsheet({required this.orderId, Key? key})
    : super(key: key);
  final int orderId;

  @override
  State<NewOrderAlertBottomsheet> createState() =>
      _NewOrderAlertBottomsheetState();
}

class _NewOrderAlertBottomsheetState extends State<NewOrderAlertBottomsheet> {
  // Native alert (MediaPlayer in MainActivity) - no Flutter audio plugin needed.
  static const MethodChannel _alertChannel = MethodChannel(
    'notifications.manage',
  );

  //true while an accept / decline request is on the wire (blocks repeated taps)
  bool _assistBusy = false;

  //Accept or decline an Assist offer straight from the ringing alert. The server decides.
  Future<void> _answerAssistOffer(Order order, {required bool accept}) async {
    if (_assistBusy) return;
    setState(() => _assistBusy = true);
    stopNotificationSound();

    final result =
        accept
            ? await AssistJobService.accept(order.id)
            : await AssistJobService.decline(order.id);

    if (!mounted) return;
    setState(() => _assistBusy = false);

    if (result.outcome == AssistJobOutcome.accepted) {
      //the job is ours: carry on in the normal order screen
      final job = result.order ?? order;
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OrderDetailsPage(order: job)),
      );
    } else if (result.isFinal) {
      //declined, expired, taken by someone else, or no funds: the offer is over
      Navigator.of(context).pop();
    }
    //network / server trouble: stay here so the provider can try again
  }

  @override
  void initState() {
    //play after finish loading
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      playNotificationSound();
    });
    super.initState();
  }

  @override
  void dispose() {
    stopNotificationSound();
    super.dispose();
  }

  //
  void playNotificationSound() async {
    try {
      final ok = await _alertChannel.invokeMethod('playAlert');
      print("DEBUG: native alert started: $ok");
    } catch (error) {
      print("DEBUG: native alert error: $error");
    }
  }

  void stopNotificationSound() {
    try {
      _alertChannel.invokeMethod('stopAlert');
    } catch (error) {
      print("Error stopping alert sound: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return VStack([
          Image.asset(
            AppImages.newOrderAlert,
            width: context.percentWidth * 50,
            // height: context.percentWidth * 50,
          ).centered(),
          //title
          "New Order".tr().text.xl2.semiBold.makeCentered(),
          "A new order has been placed".tr().text.makeCentered(),
          10.heightBox,
          //order details
          FutureBuilder<Order>(
            future: OrderRequest().getOrderDetails(id: widget.orderId),
            builder: (context, snapshot) {
              //
              if (snapshot.connectionState == ConnectionState.waiting) {
                return BusyIndicator().centered();
              } else if (snapshot.hasError) {
                return 0.heightBox;
              }
              //
              Order order = snapshot.data!;
              return VStack(
                [
                  HStack([
                    "Order Code".tr().text.semiBold.make().expand(),
                    "#${order.code}".text.make(),
                  ]),
                  HStack([
                    "Total".tr().text.semiBold.make().expand(),
                    "${AppStrings.currencySymbol} ${order.total}"
                        .currencyFormat()
                        .text
                        .make(),
                  ]),
                  HStack([
                    "Payment Method".tr().text.semiBold.make().expand(),
                    "${order.paymentMethod?.name}".text.make(),
                  ]),
                  if (order.deliveryAddress == null)
                    "Pickup Order".tr().text.semiBold.make().centered(),
                  if (order.deliveryAddress != null)
                    VStack([
                      "Delivery Address".tr().text.semiBold.make(),
                      5.heightBox,
                      "${order.deliveryAddress?.address}".text.make(),
                    ]),

                  //Assist offer: answer it right here
                  if (order.isAssistOffer)
                    HStack([
                      CustomButton(
                        color: Colors.red,
                        title: "Reject".tr(),
                        loading: _assistBusy,
                        onPressed:
                            () => _answerAssistOffer(order, accept: false),
                      ).expand(),
                      10.widthBox,
                      CustomButton(
                        color: Colors.green,
                        title: "Accept".tr(),
                        loading: _assistBusy,
                        onPressed:
                            () => _answerAssistOffer(order, accept: true),
                      ).expand(),
                    ]),

                  //
                  CustomButton(
                    title: "Open Order Details".tr(),
                    onPressed: () {
                      stopNotificationSound();
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsPage(order: order),
                        ),
                      );
                    },
                  ).wFull(context),
                ],
                spacing: 10,
              ).p(12).box.border(color: Colors.grey).roundedSM.make();
            },
          ),
          15.heightBox,

          CustomTextButton(
            title: "Ok, Close popup".tr(),
            onPressed: () {
              stopNotificationSound();
              Navigator.of(context).pop();
            },
          ).wFull(context),
          10.heightBox,
        ], spacing: 5)
        .scrollVertical()
        .p20()
        .py12()
        .box
        .white
        .topRounded()
        .make()
        .h(context.percentHeight * 85);
  }
}





