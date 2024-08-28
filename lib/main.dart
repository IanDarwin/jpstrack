import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:intl/intl.dart';
import 'package:jpstrack/ui/nav_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'db/database_helper.dart';
import 'ui/map_screen.dart';

late SharedPreferences prefs;
late PackageInfo packageInfo;
late bool seenWelcome;
DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  seenWelcome = await prefs.getBool("key_seen_welcome")??false;
  packageInfo = await PackageInfo.fromPlatform();
  await Settings.init();
  await DatabaseHelper();
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

void showWelcome() async {
  final Uri url = Uri.parse(Constants.URL_ABOUT);
  if (!await launchUrl(url)) {
    throw Exception("Failed to launch browser");
  };
}