import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:jpstrack/ui/settings_page.dart';
import 'package:jpstrack/main.dart' show packageInfo, seenWelcome, showWelcome;

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var aboutBoxChildren = [
      HtmlWidget("""
<html lang="en">
<h3>About jpsTrack</h3>
JpsTrack is a Map Maker application,
a GPX-tracking GPS App for creating OpenStreetMap or Google Earth data.
This program is <em>not</em> a navigation app for getting from point A to point B.
""")];
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text(
              'JpsTrack Menu',
              textAlign: TextAlign.end,
              style: TextStyle(color: Colors.black, fontSize: 25),
            ),
            decoration: BoxDecoration(
                color: Colors.lightGreen,
                image: DecorationImage(
                    fit: BoxFit.none,
                    image: AssetImage('images/logo.png'))
            ),
          ),
          AboutListTile(
            icon: const Icon(Icons.info),
            applicationIcon: const FlutterLogo(),
            applicationName: 'jpsTrack',
            applicationVersion: 'Version ${packageInfo.version} Build ${int.parse(packageInfo.buildNumber)}, August 2024',
            applicationLegalese:
              '\u{a9} 2007-2024 Rejminet Group Inc.',
            aboutBoxChildren: aboutBoxChildren,
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('JpsTrack Intro'),
            onTap: () {
              showWelcome();
              seenWelcome = true;
            }
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => (SettingsPage())));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Privacy Policy'),
            onTap: () async {
              final Uri url = Uri.parse("https://darwinsys.com/jpstrack/privacy.html");
              if (!await launchUrl(url)) {
                throw Exception("Failed to launch browser");
              }
            },
          ),
        ],
      ),
    );
  }
}
