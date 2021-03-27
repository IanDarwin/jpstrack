import 'package:flutter/material.dart';
import 'package:jpstrack/ui/nav_drawer.dart';

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
      home: Scaffold(
      body: MapScreen(title: 'JPSTrack Home Page'),
      drawer: NavDrawer(),
    )
    );
  }
}
