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
      home: DrawerSliding(
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
