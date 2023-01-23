import 'package:flutter/material.dart';
import 'package:jpstrack/ui/nav_drawer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';

import 'ui/map_screen.dart';

void main() {
  runApp(MapApp());
}

class MapApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'jpstrack',
        theme: ThemeData(
          primarySwatch: Colors.brown,
        ),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(
          body: MapScreen(title: 'JpsTrack'),
          drawer: NavDrawer(),
        )
    );
  }
}
