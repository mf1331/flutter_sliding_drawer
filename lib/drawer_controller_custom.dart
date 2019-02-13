import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const double _kWidth = 304.0;
const double _kEdgeDragWidth = 20.0;
const double _kMinFlingVelocity = 365.0;
const Duration _kBaseSettleDuration = Duration(milliseconds: 246);
bool _isFistDragging = false;

/// Signature for the callback that's called when a [DrawerControllerCustom] is
/// opened or closed.
typedef DrawerCallback = void Function(bool isOpened);
typedef ControllerCallback = void Function(double value);

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
  /// Rarely used directly.
  ///
  /// The [child] argument must not be null and is typically a [Drawer].
  const DrawerControllerCustom({
    GlobalKey key,
    @required this.child,
    @required this.alignment,
    this.controllerCallback,
    this.drawerCallback,
  })  : assert(child != null),
        assert(alignment != null),
        super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Drawer].
  final Widget child;

  /// The alignment of the [Drawer].
  ///
  /// This controls the direction in which the user should swipe to open and
  /// close the drawer.
  final DrawerAlignment alignment;

  /// Optional callback that is called when a [Drawer] is opened or closed.
  final DrawerCallback drawerCallback;

  final ControllerCallback controllerCallback;

  @override
  DrawerControllerCustomState createState() => DrawerControllerCustomState();
}

/// State for a [DrawerControllerCustom].
///
/// Typically used by a [Scaffold] to [open] and [close] the drawer.
class DrawerControllerCustomState extends State<DrawerControllerCustom>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: _kBaseSettleDuration, vsync: this)
          ..addListener(_animationChanged)
          ..addStatusListener(_animationStatusChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  AnimationController _controller;
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
    close();
  }

  void _handleDragDown(DragDownDetails details) {
    _controller.stop();
    _ensureHistoryEntry();
  }

  void _handleDragCancel() {
    if (_controller.isDismissed || _controller.isAnimating) return;
    if (_controller.value < 0.5) {
      close();
    } else {
      // open();
    }
  }

  final GlobalKey _drawerKey = GlobalKey();
  final GlobalKey _parentKey = GlobalKey();

  double get _width {
    final RenderBox box = _drawerKey.currentContext?.findRenderObject();
    if (box != null) return box.size.width;
    return _kWidth; // drawer not being shown currently
  }

  bool _previouslyOpened = false;

  void _move(DragUpdateDetails details) {
    // if (_getOffsetParent >= _width + 1) {
    //   return;
    // }
    if(!_isFistDragging){
      _isFistDragging = true;
      var max = _maxWidthFactor;
    }
    // print(_getOffsetParent);
    print('_move');
    double delta = details.primaryDelta / _width;
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

    if (widget.controllerCallback != null) {
      widget.controllerCallback(_controller.value);
    }

    final bool opened = _controller.value > 0.5 ? true : false;
    if (opened != _previouslyOpened && widget.drawerCallback != null)
      widget.drawerCallback(opened);
    _previouslyOpened = opened;
  }

  void _settle(DragEndDetails details) {
    if (_controller.isDismissed) return;

    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity) {
      // if (_getOffsetParent >= _width + 1) {
      //   return;
      // }
      print('_settle');
      double visualVelocity = details.velocity.pixelsPerSecond.dx / _width;
      switch (widget.alignment) {
        case DrawerAlignment.start:
          break;
        case DrawerAlignment.end:
          visualVelocity = -visualVelocity;
          break;
      }
      switch (Directionality.of(context)) {
        case TextDirection.rtl:
          _controller.fling(velocity: -visualVelocity);
          break;
        case TextDirection.ltr:
          _controller.fling(velocity: visualVelocity);
          break;
      }
    } else if (_controller.value < 0.5) {
      close();
    } else {
      // open();
    }
  }

  /// Starts an animation to open the drawer.
  ///
  /// Typically called by [ScaffoldState.openDrawer].
  void open() {
    _controller.fling(velocity: 1.0);
    if (widget.drawerCallback != null) widget.drawerCallback(true);
  }

  /// Starts an animation to close the drawer.
  void close() {
    _controller.fling(velocity: -1.0);
    if (widget.controllerCallback != null) widget.controllerCallback(0.0);
    if (widget.drawerCallback != null) widget.drawerCallback(false);
  }

  final ColorTween _color =
      ColorTween(begin: Colors.transparent, end: Colors.black54);
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
          child: Container(width: dragAreaWidth),
        ),
      );
    } else {
      // Container(
      //     child: GestureDetector(
      //     // On Android, the back button is used to dismiss a modal.
      //     excludeFromSemantics:
      //         defaultTargetPlatform == TargetPlatform.android,
      //     onTap: close,
      //     child: Semantics(
      //       label: MaterialLocalizations.of(context)
      //           ?.modalBarrierDismissLabel,
      //       child: Container(
      //         width: 0,
      //         height: 0,
      //         color: _color.evaluate(_controller),
      //       ),
      //     ),
      //   ),
      // ),
      return GestureDetector(
        key: _gestureDetectorKey,
        onHorizontalDragDown: _handleDragDown,
        onHorizontalDragUpdate: _move,
        onHorizontalDragEnd: _settle,
        onHorizontalDragCancel: _handleDragCancel,
        excludeFromSemantics: true,
        child: RepaintBoundary(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Align(
              key: _parentKey,
              widthFactor: _controller.value,
              alignment: AlignmentDirectional.centerStart,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
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
// Rect.fromLTRB(2.3, 2.3, 23.3, 637.7)
// -2.3333333333333144
  Rect get _getOffsetParent {
    final RenderBox box = _parentKey.currentContext?.findRenderObject();
    if (box != null) {
      var dis = box.paintBounds;

      print('disparent = > ' + dis.toString());
      return dis;
    }
    return Rect.fromLTRB(0, 0, 0, 0);
  }

  double get _maxWidthFactor {
    if(_getOffsetParent.width == 0.0){
      _isFistDragging = false;
      return 0;
    }
    for (double x = 0.0, i = 0.0; i <= 1.0; i += 0.1, x++) {
      i = -i;
      var rect = Rect.fromLTRB(_getOffsetParent.left - i, _getOffsetParent.top - i, x + i, _getOffsetParent.bottom + i);
      if (rect.right.roundToDouble() == 250.0) {
        return i;
      }
    }
    return 0;
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
