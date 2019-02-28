import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const double _kEdgeDragWidth = 20.0;
const double _kMinFlingVelocity = 365.0;
const Duration _kBaseSettleDuration = Duration(milliseconds: 246);
ColorTween _color;
Tween<double> _tween;
Animation<double> _animationSlide;
AnimationController _controller;
AnimationController _controller2;
LocalHistoryEntry _historyEntry;
final FocusScopeNode _focusScopeNode = FocusScopeNode();
double _mWidth = 0.0;
double _mScreenWidth = 0.0;

bool get drawerOpend {
  if (_controller == null) return false;
  return _controller.value == (_mWidth / _mScreenWidth);
}

void flingClose() {
  if (_controller == null) return;
  _tween.begin = _controller.value;
  _tween.end = 0.0;
  _controller2.forward(from: _controller.value);
}

void flingOpen() {
  if (_controller == null) return;
  _tween.begin = _controller.value;
  _tween.end = (_mWidth / _mScreenWidth);
  _controller2.forward(from: _controller.value);
}

class SlidingDrawer extends StatefulWidget {
  const SlidingDrawer(
      {GlobalKey key,
      @required this.child,
      @required this.alignment,
      @required this.screenWidth,
      @required this.body,
      @required this.width})
      : assert(child != null),
        assert(alignment != null),
        super(key: key);

  final Widget child;
  final double width;
  final double screenWidth;

  final DrawerAlignment alignment;

  final Widget body;

  @override
  SlidingDrawerState createState() => SlidingDrawerState();
}

class SlidingDrawerState extends State<SlidingDrawer>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _mWidth = widget.width;
    _mScreenWidth = widget.screenWidth;
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
      });
    _color = ColorTween(begin: Colors.transparent, end: Colors.black38);
  }

  @override
  void dispose() {
    _historyEntry?.remove();
    _controller.dispose();
    _controller2.dispose();
    super.dispose();
  }

  void _animationChanged() {
    setState(() {
      // The animation _controller's state is our build state, and it changed already.
    });
  }

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

  void _move(DragUpdateDetails details) {
    double delta = details.primaryDelta / widget.width;

    switch (widget.alignment) {
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
    return Stack(
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: 1.0 - _controller.value,
            child: widget.body,
          ),
        ),
        GestureDetector(
          onHorizontalDragDown: _handleDragDown,
          onHorizontalDragUpdate: _move,
          onHorizontalDragEnd: _settle,
          onHorizontalDragCancel: _handleDragCancel,
          // On Android, the back button is used to dismiss a modal.
          excludeFromSemantics: defaultTargetPlatform == TargetPlatform.android,
          onTap: flingClose,
          child: BlockSemantics(
            child: Semantics(
              label:
                  MaterialLocalizations.of(context)?.modalBarrierDismissLabel,
              child: Container(
                width: _controller.value == 0.0 ? 0.0 : null,
                color: _color.evaluate(_controller),
              ),
            ),
          ),
        ),
        _controller.status == AnimationStatus.dismissed
            ? Align(
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
              )
            : GestureDetector(
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
              ),
      ],
    );
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
