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
        body: Container(),
        slider: Container(
          color: Colors.amber,
          width: 250,
          height: double.infinity,
        ),
      ),
    );
  }
}
