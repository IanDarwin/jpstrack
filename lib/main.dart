import 'package:flutter/material.dart';

import 'ui/map_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JPSTrack',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: MapScreen(title: 'JPSTrack Home Page'),
    );
  }
}