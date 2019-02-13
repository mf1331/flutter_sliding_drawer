import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sliding_drawer_flutter/drawer_controller_custom.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

AnimationController _controller;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

var darwerLayout = Align();
Offset darwerOfsset = Offset(0, 0);

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  double _value = 0.0;
  final GlobalKey _childKey = GlobalKey();
  final GlobalKey _parentKey = GlobalKey();

  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final RenderBox renderBox = _childKey.currentContext.findRenderObject();
    //   darwerOfsset = renderBox.localToGlobal(Offset.zero);
    //   print('first offset of drawer => $darwerOfsset');
    //   print(
    //       'first offset of drawer => ${renderBox.size.width}');
    //   // Alignment a = darwerLayout.alignment;
    // });
    super.initState();
    _controller =
        AnimationController(duration: Duration(milliseconds: 246), vsync: this)
          ..addListener(_animationChanged);
  }

  void _animationChanged() {
    setState(() {
      // The animation _controller's state is our build state, and it changed already.
    });
  }

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;

    final bool drawerIsStart = DrawerAlignment.end == DrawerAlignment.start;
    final EdgeInsets padding = MediaQuery.of(context).padding;
    double dragAreaWidth = drawerIsStart ? padding.left : padding.right;

    if (Directionality.of(context) == TextDirection.rtl)
      dragAreaWidth = drawerIsStart ? padding.right : padding.left;

    dragAreaWidth = max(dragAreaWidth, 20.0);

    var scaffold2 = Material(
      child: Stack(
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              widthFactor: 1.0 - _controller.value,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Container(
                  color: Colors.red,
                  child: Center(child: Text('drawer')),
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: _controller.value,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Container(
                  color: Colors.amber,
                  child: Center(child: Text('drawer')),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    darwerLayout = Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Align(
        key: _parentKey,
        alignment: AlignmentDirectional.centerStart,
        widthFactor: _controller.value,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            key: _childKey,
            width: 250,
            height: double.infinity,
            color: Colors.red,
            child: Center(child: Text('drawer')),
          ),
        ),
      ),
    );

    // var scaffold = Material(
    //     child: Stack(children: <Widget>[
    //   Align(
    //     alignment: AlignmentDirectional.centerStart,
    //     child: Align(
    //       alignment: AlignmentDirectional.centerEnd,
    //       widthFactor: 1.0 - _controller.value,
    //       child: SizedBox(
    //         width: double.infinity,
    //         height: double.infinity,
    //         child: Container(
    //           color: Colors.yellow,
    //           child: Center(child: Text('body')),
    //         ),
    //       ),
    //     ),
    //   ),
    //   _controller.status == AnimationStatus.dismissed
    //       ? Align(
    //           alignment: AlignmentDirectional.centerEnd,
    //           child: GestureDetector(
    //             // key: _gestureDetectorKey,
    //             onHorizontalDragUpdate: _move,
    //             // onHorizontalDragEnd: _settle,
    //             behavior: HitTestBehavior.translucent,
    //             excludeFromSemantics: true,
    //             child: Container(width: dragAreaWidth),
    //           ),
    //         )
    //       : GestureDetector(
    //           behavior: HitTestBehavior.translucent,
    //           onHorizontalDragUpdate: _move,
    //           child: darwerLayout,
    //         )
    return Material(
      child: Stack(
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              widthFactor: 1.0 - _value,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Container(
                  color: Colors.yellow,
                  child: Center(child: Text('body')),
                ),
              ),
            ),
          ),
          DrawerControllerCustom(
            // drawerCallback: (isOpend) {
            //   if (!isOpend && _value < 5.0) {
            //     setState(() {
            //       _value = 0.0;
            //     });
            //   } else if (isOpend) {
            //     setState(() {
            //       _value = 1.0;
            //     });
            //   }
            // },
            controllerCallback: (value) {
              setState(() {
                // if(_size == 0.0) return;
                _value = value;
                print('value => $value');
              });
            },
            alignment: DrawerAlignment.end,
            child: OverflowBox(
              maxWidth: 250,
              alignment: FractionalOffset.centerLeft,
              child: Container(
                color: Colors.red,
                width: 250,
                child: Center(
                  child: Text(
                    'sliding drawer !',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _move(DragUpdateDetails details) {
    // final RenderBox renderBox = _childKey.currentContext.findRenderObject();
    // darwerOfsset = renderBox.localToGlobal(Offset.zero);
    // print('first offset of drawer => $darwerOfsset');
    // print('first offset of drawer => ${renderBox.size.width}');
    if (_getOffsetParent >= 249) {
      return;
    }

    double delta = details.primaryDelta / 250;
    switch (DrawerAlignment.end) {
      case DrawerAlignment.start:
        break;
      case DrawerAlignment.end:
        delta = -delta;
        break;
    }
    switch (Directionality.of(context)) {
      case TextDirection.rtl:
        // if(_controller.value - delta >= 0.6) return;
        _controller.value -= delta;
        break;
      case TextDirection.ltr:
        // if(_controller.value + delta >= 0.6) return;
        _controller.value += delta;
        break;
    }

    // if (widget.controllerCallback != null) {
    //   widget.controllerCallback(_controller.value);
    // }

    // final bool opened = _controller.value > 0.5 ? true : false;
    // if (opened != _previouslyOpened && widget.drawerCallback != null)
    //   widget.drawerCallback(opened);
    // _previouslyOpened = opened;
  }

  Offset get _getOffset {
    final RenderBox box = _childKey.currentContext?.findRenderObject();
    if (box != null) {
      var dis = box.localToGlobal(Offset.zero);
      print('dis = > ' + dis.toString());
      return dis;
    }
    return Offset(0, 0);
  }

  double get _getOffsetParent {
    final RenderBox box = _parentKey.currentContext?.findRenderObject();
    if (box != null) {
      var dis = box.paintBounds.right;
      print('disparent = > ' + dis.toString());
      return dis;
    }
    return 0;
  }

  double get _getWidth {
    final RenderBox box = _childKey.currentContext?.findRenderObject();
    if (box != null) return box.size.width;
    return 0;
  }
}
