import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sliding_drawer_flutter/drawer_controller.dart';

class DrawerSliding extends StatefulWidget {
  DrawerSliding(
      {Key key,
      @required this.slider,
      @required this.body,
      @required this.sliderWidth,
      this.drawerAlignment = DrawerAlignment.end})
      : super(key: key);

  final Widget slider;

  final Widget body;

  final double sliderWidth;

  final DrawerAlignment drawerAlignment;

  @override
  _DrawerSlidingState createState() => _DrawerSlidingState();
}

class _DrawerSlidingState extends State<DrawerSliding>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  ColorTween _color;
  double _value = 0.0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: Duration(milliseconds: 246), vsync: this);
    _color = ColorTween(begin: Colors.transparent, end: Colors.black38);
  }

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;

    return Material(
      child: Stack(
        children: <Widget>[
          BlockSemantics(
            child: GestureDetector(
              // On Android, the back button is used to dismiss a modal.
              excludeFromSemantics:
                  defaultTargetPlatform == TargetPlatform.android,
              // onTap: close,
              child: Semantics(
                label:
                    MaterialLocalizations.of(context)?.modalBarrierDismissLabel,
                child: Container(
                  color: _color.evaluate(_controller),
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              widthFactor: 1.0 - _value,
              child: Container(child: widget.body),
            ),
          ),
          DrawerControllerCustom(
            screenWidth: sizeScreen.width,
            width: widget.sliderWidth,
            controllerCallback: (value) {
              setState(() {
                _controller.value = value;
                _value = value;
              });
            },
            alignment: widget.drawerAlignment,
            child: widget.slider,
          ),
        ],
      ),
    );
  }
}
