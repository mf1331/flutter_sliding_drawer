import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const double _kEdgeDragWidth = 20.0;
const double _kMinFlingVelocity = 365.0;
const Duration _kBaseSettleDuration = Duration(milliseconds: 246);
const Duration _kBaseDelayDuration = Duration(milliseconds: 30);

/// Signature for the callback that's called when a [DrawerControllerCustom] is
/// opened or closed.
typedef DrawerCallback = void Function(bool isOpened);
typedef ControllerCallback = void Function(double value);
typedef FlingCallback = void Function(double velocity);

/// Provides interactive behavior for [Drawer] widgets.
///
/// Rarely used directly. Drawer controllers are typically created automatically
/// by [Scaffold] widgets.
///
/// The draw _controller provides the ability to open and close a drawer, either
/// via an animation or via user interaction. When closed, the drawer collapses
/// to a translucent gesture detector that can be used to listen for edge
/// swipes.
///
/// See also:
///
///  * [Drawer], a container with the default width of a drawer.
///  * [Scaffold.drawer], the [Scaffold] slot for showing a drawer.
class DrawerControllerCustom extends StatefulWidget {
  /// Creates a _controller for a [Drawer].
  ///
  /// Rarely used directly.ae.mgnlasdnthlmszdfmhn.,sfmgjnsxfh/nj,xd/f,hmjnd,.xfh/mj,x/fgh,/x,.hnZdhnsrn u sdru jrtyitdi kdty itijkws46uve56ub5iun5euinr67ir6i67ir
  ///
  /// The [child] argument must not be null and is typically a [Drawer].
  const DrawerControllerCustom(
      {GlobalKey key,
      @required this.child,
      @required this.alignment,
      this.controllerCallback,
      this.drawerCallback,
      this.flingCallback,
      this.screenWidth,
      @required this.width})
      : assert(child != null),
        assert(alignment != null),
        super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Drawer].
  final Widget child;
  final double width;
  final double screenWidth;

  /// The alignment of the [Drawer].
  ///
  /// This controls the direction in which the user should swipe to open and
  /// close the drawer.
  final DrawerAlignment alignment;

  /// Optional callback that is called when a [Drawer] is opened or closed.
  final DrawerCallback drawerCallback;

  final ControllerCallback controllerCallback;

  final FlingCallback flingCallback;

  @override
  DrawerControllerCustomState createState() => DrawerControllerCustomState();
}

/// State for a [DrawerControllerCustom].
///
/// Typically used by a [Scaffold] to [open] and [close] the drawer.
class DrawerControllerCustomState extends State<DrawerControllerCustom>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        lowerBound: 0.0,
        upperBound: (widget.width / widget.screenWidth),
        duration: _kBaseSettleDuration,
        vsync: this)
      ..addListener(_animationChanged)
      ..addStatusListener(_animationStatusChanged);

    _controller2 =
        AnimationController(duration: _kBaseSettleDuration, vsync: this);

    _tween =
        Tween<double>(begin: 0.0, end: (widget.width / widget.screenWidth));
    _animationSlide = _tween.animate(_controller2)
      ..addListener(() {
        // print('_tweenSlide ==> ${_animationSlide.value}');
        setState(() {
          _controller.value = _animationSlide.value;
        });
        if (widget.controllerCallback != null) {
          widget.controllerCallback(_controller.value);
        }
      });
  }

  @override
  void dispose() {
    _historyEntry?.remove();
    _controller.dispose();
    super.dispose();
  }

  void _animationChanged() {
    setState(() {
      // The animation _controller's state is our build state, and it changed already.
    });
  }

  Tween<double> _tween;
  Animation<double> _animationSlide;
  AnimationController _controller;
  AnimationController _controller2;
  LocalHistoryEntry _historyEntry;
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  void _ensureHistoryEntry() {
    if (_historyEntry == null) {
      final ModalRoute<dynamic> route = ModalRoute.of(context);
      if (route != null) {
        _historyEntry = LocalHistoryEntry(onRemove: _handleHistoryEntryRemoved);
        route.addLocalHistoryEntry(_historyEntry);
        FocusScope.of(context).setFirstFocus(_focusScopeNode);
      }
    }
  }

  void _animationStatusChanged(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.forward:
        _ensureHistoryEntry();
        break;
      case AnimationStatus.reverse:
        _historyEntry?.remove();
        _historyEntry = null;
        break;
      case AnimationStatus.dismissed:
        break;
      case AnimationStatus.completed:
        break;
    }
  }

  void _handleHistoryEntryRemoved() {
    _historyEntry = null;
    flingClose();
  }

  void _handleDragDown(DragDownDetails details) {
    _controller.stop();
    _ensureHistoryEntry();
  }

  void _handleDragCancel() {
    if (_controller.isDismissed || _controller.isAnimating) return;
    if (_controller.value < (widget.width / widget.screenWidth) / 2) {
      flingClose();
    } else {
      flingOpen();
    }
  }

  final GlobalKey _drawerKey = GlobalKey();
  final GlobalKey _parentKey = GlobalKey();

  bool _previouslyOpened = false;

  void _move(DragUpdateDetails details) {
    double delta = details.primaryDelta / widget.width;

    switch (DrawerAlignment.end) {
      case DrawerAlignment.start:
        break;
      case DrawerAlignment.end:
        delta = -delta;
        break;
    }

    switch (Directionality.of(context)) {
      case TextDirection.rtl:
        _controller.value -= delta;
        break;
      case TextDirection.ltr:
        _controller.value += delta;
        break;
    }

    // print('move ==> ${_controller.value}');

    if (widget.controllerCallback != null) {
      widget.controllerCallback(_controller.value);
    }

    final bool opened =
        _controller.value > ((widget.width / widget.screenWidth) / 2)
            ? true
            : false;
    if (opened != _previouslyOpened && widget.drawerCallback != null)
      widget.drawerCallback(opened);
    _previouslyOpened = opened;
  }

  void _settle(DragEndDetails details) {
    if (_controller.isDismissed) return;

    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity) {
      double visualVelocity = details.primaryVelocity / widget.width;
      switch (widget.alignment) {
        case DrawerAlignment.start:
          break;
        case DrawerAlignment.end:
          visualVelocity = -visualVelocity;
          break;
      }

      switch (Directionality.of(context)) {
        case TextDirection.rtl:
          // _controller.fling(velocity: -visualVelocity);
          if (details.velocity.pixelsPerSecond.dx < 0) {
            flingOpen();
          } else {
            flingClose();
          }
          break;
        case TextDirection.ltr:
          // _controller.fling(velocity: visualVelocity);
          if (details.velocity.pixelsPerSecond.dx < 0) {
            flingOpen();
          } else {
            flingClose();
          }
          break;
      }
    } else if (_controller.value < ((widget.width / widget.screenWidth) / 2)) {
      flingClose();
    } else {
      flingOpen();
    }
  }

  void flingClose() {
    _tween.begin = 0.0;
    _tween.end = _controller.value;
    _controller2.reverse(from: 0.0);
    print('tween.begin ==> ${_tween.begin}');
    print('tween.end ==> ${_tween.end}');
    // for (double i = (widget.width / widget.screenWidth); i >= 0.0; i -= 0.001) {
    //   Future.delayed(_kBaseDelayDuration, () {
    //     _controller.value = i;
    //     if (widget.controllerCallback != null) {
    //       widget.controllerCallback(_controller.value);
    //     }
    //   });
    // }
    // Future.delayed(_kBaseDelayDuration, () {
    //   _controller.value = 0.0;
    //   if (widget.controllerCallback != null) {
    //     widget.controllerCallback(_controller.value);
    //   }
    // });
  }

  void flingOpen() {
    _tween.begin = _controller.value;
    _tween.end = (widget.width / widget.screenWidth);
    _controller2.forward(from: _controller.value);
    // print('tween.begin ==> ${_tween.begin}');
    // print('tween.end ==> ${_tween.end}');
    // for (double i = _controller.value;
    //     i <= (widget.width / widget.screenWidth);
    //     i += 0.001) {
    //   Future.delayed(_kBaseDelayDuration, () {
    //     _controller.value = i;
    //     if (widget.controllerCallback != null) {
    //       widget.controllerCallback(_controller.value);
    //     }
    //   });
    // }
    // Future.delayed(_kBaseDelayDuration, () {
    //   _controller.value = (widget.width / widget.screenWidth);
    //   if (widget.controllerCallback != null) {
    //     widget.controllerCallback(_controller.value);
    //   }
    // });
  }

  /// Starts an animation to open the drawer.
  ///
  /// Typically called by [ScaffoldState.openDrawer].
  // void open() {
  //   _controller.fling(velocity: 1.0);
  //   // Future.delayed(Duration(milliseconds: 240), () {
  //   //   if (widget.controllerCallback != null)
  //   widget.controllerCallback((widget.width / widget.screenWidth));
  //   // });
  //   if (widget.drawerCallback != null) widget.drawerCallback(true);
  // }

  /// Starts an animation to close the drawer.
  // void close() {
  //   _controller.fling(velocity: -1.0);
  //   if (widget.controllerCallback != null) widget.controllerCallback(0.0);
  //   if (widget.drawerCallback != null) widget.drawerCallback(false);
  // }

  final GlobalKey _gestureDetectorKey = GlobalKey();

  AlignmentDirectional get _drawerOuterAlignment {
    assert(widget.alignment != null);
    switch (widget.alignment) {
      case DrawerAlignment.start:
        return AlignmentDirectional.centerStart;
      case DrawerAlignment.end:
        return AlignmentDirectional.centerEnd;
    }
    return null;
  }

  AlignmentDirectional get _drawerInnerAlignment {
    assert(widget.alignment != null);
    switch (widget.alignment) {
      case DrawerAlignment.start:
        return AlignmentDirectional.centerEnd;
      case DrawerAlignment.end:
        return AlignmentDirectional.centerStart;
    }
    return null;
  }

  Widget _buildDrawer(BuildContext context) {
    final bool drawerIsStart = widget.alignment == DrawerAlignment.start;
    final EdgeInsets padding = MediaQuery.of(context).padding;
    double dragAreaWidth = drawerIsStart ? padding.left : padding.right;

    if (Directionality.of(context) == TextDirection.rtl)
      dragAreaWidth = drawerIsStart ? padding.right : padding.left;

    dragAreaWidth = max(dragAreaWidth, _kEdgeDragWidth);
    if (_controller.status == AnimationStatus.dismissed) {
      return Align(
        alignment: _drawerOuterAlignment,
        child: GestureDetector(
          key: _gestureDetectorKey,
          onHorizontalDragUpdate: _move,
          onHorizontalDragEnd: _settle,
          behavior: HitTestBehavior.translucent,
          excludeFromSemantics: true,
          child: Container(
            width: dragAreaWidth,
          ),
        ),
      );
    } else {
      return GestureDetector(
        key: _gestureDetectorKey,
        onHorizontalDragDown: _handleDragDown,
        onHorizontalDragUpdate: _move,
        onHorizontalDragEnd: _settle,
        onHorizontalDragCancel: _handleDragCancel,
        excludeFromSemantics: true,
        child: RepaintBoundary(
          child: Align(
            alignment: _drawerOuterAlignment,
            child: Align(
              key: _parentKey,
              widthFactor: _controller.value,
              alignment: _drawerInnerAlignment,
              child: Align(
                alignment: _drawerInnerAlignment,
                child: RepaintBoundary(
                  child: FocusScope(
                    key: _drawerKey,
                    node: _focusScopeNode,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return ListTileTheme(
      style: ListTileStyle.drawer,
      child: _buildDrawer(context),
    );
  }
}
