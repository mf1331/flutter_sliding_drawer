import 'package:flutter/material.dart';

class AlignmentAnimation extends StatefulWidget {
  @override
  _AlignmentAnimationState createState() => _AlignmentAnimationState();
}

class _AlignmentAnimationState extends State<AlignmentAnimation>
    with TickerProviderStateMixin {
  Animation<RelativeRect> _animation;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = Tween<RelativeRect>(
            begin: RelativeRect.fromLTRB(0, 0, 0, 0),
            end: RelativeRect.fromLTRB(20, 0, 0, 0))
        .animate(_controller);
    _animation.addListener(() {
      setState(() {});
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: <Widget>[
          PositionedTransition(
            rect: _animation,
            child: Container(
              child: Text('data'),
            ),
          )
        ],
      ),
    );
  }
}
