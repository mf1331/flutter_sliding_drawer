import 'package:flutter/material.dart';
import 'package:sliding_drawer_flutter/sliding_drawer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Test());
  }
}

class Test extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SlidingDrawer(
        screenWidth: MediaQuery.of(context).size.width,
        alignment: DrawerAlignment.end,
        width: 250,
        body: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => drawerOpend ? flingClose() : flingOpen(),
            ),
          ),
          body: Container(
            color: Colors.red,
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Text('body'),
            ),
          ),
        ),
        child: Container(
          color: Colors.amber,
          width: 250,
          height: double.infinity,
        ),
      ),
    );
  }
}

// class SlidingTransition extends StatefulWidget {
//   @override
//   _SlidingTransitionState createState() => _SlidingTransitionState();
// }

// class _SlidingTransitionState extends State<SlidingTransition>
//     with TickerProviderStateMixin {
//   Animation<Offset> slide;
//   AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller =
//         AnimationController(vsync: this, duration: Duration(seconds: 1));
//     slide = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(0.7, 0.0))
//         .animate(_controller);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SlideTransition(
//           position: slide,
//           child: Container(
//             color: Colors.red,
//             width: 300,
//             height: double.infinity,
//           )),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           switch (_controller.status) {
//             case AnimationStatus.completed:
//               _controller.reverse();
//               break;
//             case AnimationStatus.dismissed:
//               _controller.forward();
//               break;
//             default:
//           }
//         },
//       ),
//     );
//   }
// }
