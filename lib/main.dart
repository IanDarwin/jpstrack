import 'package:flutter/material.dart';
import 'package:jpstrack/ui/nav_drawer.dart';

import 'ui/map_screen.dart';

void main() {
  runApp(MapApp());
}

// A trivial "main" to scaffold the MapScreen,
// which is the real main part of the app.
class MapApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'jpstrack',
        theme: ThemeData(
          primarySwatch: Colors.brown,
        ),
        home: Scaffold(
          body: MapScreen(title: 'JpsTrack'),
          drawer: NavDrawer(),
        )
    );
  }
}

