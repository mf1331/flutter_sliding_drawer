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
  double _value = 0.0;

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;

    return Stack(
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            widthFactor: 1.0 - _value,
            child: widget.body,
          ),
        ),
        DrawerControllerCustom(
          screenWidth: sizeScreen.width,
          width: widget.sliderWidth,
          controllerCallback: (value) {
            setState(() {
              _value = value;
            });
          },          
          alignment: widget.drawerAlignment,
          child: widget.slider,
        ),
      ],
    );
  }
}
