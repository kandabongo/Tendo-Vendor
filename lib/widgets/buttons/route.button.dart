import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

class RouteButton extends StatelessWidget {
  const RouteButton(this.vendor, {Key? key}) : super(key: key);

  final Vendor vendor;
  @override
  Widget build(BuildContext context) {
    return Icon(
      FlutterIcons.navigation_fea,
      size: 24,
      color: Colors.white,
    ).p8().box.color(AppColor.primaryColor).roundedSM.make().onInkTap(
      () async {
        //
        final request = MapLauncher.directions(
          LocationCoords(
            double.parse(vendor.latitude ?? "0"),
            double.parse(vendor.longitude ?? "0"),
            title: vendor.name,
          ),
        );
        final supportedMaps = await request.getSupportedMaps();
        if (supportedMaps.any((map) => map.mapType == MapType.google)) {
          await request.show(map: MapType.google);
        }
      },
    );
  }
}
