import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:properties/properties.dart';
import 'package:flutter/services.dart';

import 'package:jpstrack/ui/nav_drawer.dart';
import 'package:jpstrack/constants.dart';
import 'package:jpstrack/db/database_helper.dart';
import 'package:jpstrack/service/osm_auth_service.dart';
import 'package:jpstrack/ui/map_screen.dart';

late SharedPreferences prefs;
// late PackageInfo packageInfo;
late Properties oauthConfig;
DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

// A trivial "main" to configure some packages
// and then scaffold the MapScreen,
// which is the real main part of the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  // packageInfo = await PackageInfo.fromPlatform();
  
  final propString = await rootBundle.loadString('assets/oauth2.properties');
  oauthConfig = Properties.fromString(propString);
  OsmAuthService.instance.configure(oauthConfig, prodMode: true); // Defaulting to false as per legacy code
  await OsmAuthService.instance.init();

  await Settings.init();
  DatabaseHelper();
  runApp(const MapApp());
}

class MapApp extends StatelessWidget {
  const MapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
		    debugShowCheckedModeBanner: false,
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
  }
  prefs.setBool("key_seen_welcome", true);
}
