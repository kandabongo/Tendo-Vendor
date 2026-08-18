import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/widgets/dynamic_status_bar.dart';

import 'package:velocity_x/velocity_x.dart';

class BasePage extends StatefulWidget {
  final bool showAppBar;
  final bool showLeadingAction;
  final IconData? leadingIconData;
  final Widget? leading;
  final bool showCart;
  final bool extendBodyBehindAppBar;
  final Function? onBackPressed;
  final String title;
  final Widget? body;
  final Widget? child;
  final Widget? bottomSheet;
  final Widget? bottomNavigationBar;
  final Widget? fab;
  final bool isLoading;
  final List<Widget>? actions;

  final Color? appBarItemColor;
  final Color? appBarColor;
  final Color? backgroundColor;
  final double? elevation;

  BasePage({
    this.showAppBar = false,
    this.showLeadingAction = false,
    this.leadingIconData,
    this.leading,
    this.extendBodyBehindAppBar = false,
    this.showCart = false,
    this.onBackPressed,
    this.title = "",
    this.body,
    this.child,
    this.bottomSheet,
    this.bottomNavigationBar,
    this.fab,
    this.isLoading = false,
    this.actions,
    this.elevation,
    this.appBarItemColor,
    this.appBarColor,
    this.backgroundColor,
    Key? key,
  }) : super(key: key);

  @override
  _BasePageState createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  @override
  Widget build(BuildContext context) {
    return DynamicStatusBar(
      baseColor: widget.backgroundColor ?? context.backgroundColor,
      child: Directionality(
        textDirection: Utils.textDirection,
        child: Scaffold(
          extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
          resizeToAvoidBottomInset: false,
          backgroundColor: widget.backgroundColor ?? context.backgroundColor,
          appBar:
              widget.showAppBar
                  ? AppBar(
                    backgroundColor: widget.appBarColor,
                    foregroundColor: widget.appBarItemColor,
                    automaticallyImplyLeading: widget.showLeadingAction,
                    elevation: widget.elevation,
                    leading:
                        widget.showLeadingAction
                            ? widget.leading == null
                                ? IconButton(
                                  icon: Icon(
                                    widget.leadingIconData ??
                                        FlutterIcons.arrow_left_fea,
                                  ),
                                  onPressed:
                                      widget.onBackPressed != null
                                          ? () => widget.onBackPressed!()
                                          : () => Navigator.pop(context),
                                )
                                : widget.leading
                            : null,
                    title: Text(widget.title),
                    actions: widget.actions ?? [],
                  )
                  : null,
          body:
              VStack([
                //
                widget.isLoading
                    ? LinearProgressIndicator()
                    : UiSpacer.emptySpace(),

                //body
                (widget.child ?? widget.body ?? 0.heightBox).expand(),
              ]).safeArea(),
          bottomSheet: widget.bottomSheet,
          bottomNavigationBar: widget.bottomNavigationBar,
          floatingActionButton: widget.fab,
        ),
      ),
    );
  }
}
