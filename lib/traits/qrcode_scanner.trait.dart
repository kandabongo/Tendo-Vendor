import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/extensions/context.dart';

mixin QrcodeScannerTrait {
  //scanning
  QRViewController? controller;

  //
  Future<String?> openScanner(BuildContext viewContext) async {
    final result = await showDialog(
      barrierDismissible: false,
      context: viewContext,
      builder: (context) {
        return _QrScannerDialog(
          onControllerCreated: (qrController) => controller = qrController,
        );
      },
    );

    //
    print("Results ==> $result");
    controller?.stopCamera();
    //
    FocusScope.of(viewContext).requestFocus(FocusNode());
    return result;
  }
}

class _QrScannerDialog extends StatefulWidget {
  const _QrScannerDialog({required this.onControllerCreated});

  final ValueChanged<QRViewController> onControllerCreated;

  @override
  State<_QrScannerDialog> createState() => _QrScannerDialogState();
}

class _QrScannerDialogState extends State<_QrScannerDialog> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool flashEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: VStack([
        //qr code preview
        QRView(
          key: qrKey,
          onQRViewCreated: (QRViewController controller) {
            this.controller = controller;
            widget.onControllerCreated(controller);
            controller.scannedDataStream.listen((scanData) {
              //close dialog
              context.pop(scanData.code);
            });
          },
        ).h48(context),
        //
        HStack([
          "Toggle Flash".tr().text.make().expand(),
          Switch(
            value: flashEnabled,
            onChanged: (value) {
              setState(() => flashEnabled = value);
              controller?.toggleFlash();
            },
          ),
        ]).px20(),
        //
        TextButton(
          onPressed: () => context.pop(null),
          child: "Cancel".tr().text.make(),
        ).centered().py12(),
      ]),
    );
  }
}
