import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({this.heightPercentage, this.duration, Key? key})
    : super(key: key);
  final double? heightPercentage;
  final int? duration;
  @override
  Widget build(BuildContext context) {
    return VxBox(child: "".text.make())
        .height(context.percentHeight * (heightPercentage ?? 6))
        .width(context.percentWidth * 100)
        .roundedFull
        .clip(Clip.antiAlias)
        .make()
        .backgroundColor(Colors.grey[900])
        .shimmer(
          primaryColor: context.theme.colorScheme.surface,
          secondaryColor: context.theme.highlightColor,
          duration: Duration(milliseconds: duration ?? 1000),
        )
        .cornerRadius(4);
  }
}
