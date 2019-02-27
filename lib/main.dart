import 'package:flutter/material.dart';
import 'package:sliding_drawer_flutter/drawer_sliding.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:
          // SlidingTransition(),
          DrawerSliding(
        sliderWidth: 250,
        body: Scaffold(
          body: Container(
            color: Colors.red,
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Text('body'),
            ),
          ),
        ),
        slider: Container(
          color: Colors.amber,
          width: 250,
          height: double.infinity,
        ),
      ),
    );
  }
}

class SlidingTransition extends StatefulWidget {
  @override
  _SlidingTransitionState createState() => _SlidingTransitionState();
}

class _SlidingTransitionState extends State<SlidingTransition>
    with TickerProviderStateMixin {
  Animation<Offset> slide;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    slide = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(0.7, 0.0))
        .animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlideTransition(
          position: slide,
          child: Container(
            color: Colors.red,
            width: 300,
            height: double.infinity,
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          switch (_controller.status) {
            case AnimationStatus.completed:
              _controller.reverse();
              break;
            case AnimationStatus.dismissed:
              _controller.forward();
              break;
            default:
          }
        },
      ),
    );
  }
}
