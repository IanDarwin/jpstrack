import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:intl/intl.dart';
import 'package:jpstrack/ui/nav_drawer.dart';

import 'db/database_helper.dart';
import 'ui/map_screen.dart';

void main() async {
  await Settings.init();
  await DatabaseHelper();
  runApp(MapApp());
}

DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

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

