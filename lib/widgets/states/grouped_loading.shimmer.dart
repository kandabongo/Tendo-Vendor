import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class GroupedLoadingShimmer extends StatelessWidget {
  const GroupedLoadingShimmer({
    this.columns = 1,
    this.heightPercentage,
    this.duration,
    this.spacing = 10.00,
    this.padding = 8.00,
    Key? key,
  }) : super(key: key);
  final double? heightPercentage;
  final double? spacing;
  final double padding;
  final int? duration;
  final int columns;
  @override
  Widget build(BuildContext context) {
    return VStack([
      ...List.generate(columns, (e) {
        return _shimmerView(
          context,
          heightPercentage: this.heightPercentage,
          duration: this.duration,
        );
      }),
    ], spacing: spacing).p(this.padding);
  }

  Widget _shimmerView(
    BuildContext context, {
    double? heightPercentage,
    int? duration,
  }) {
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
