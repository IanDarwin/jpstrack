import 'package:flutter/material.dart';

import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:jpstrack/constants.dart';
import 'package:jpstrack/main.dart' show prefs;

const Map<String, String> mapProviders = {
  'openstreetmap_oauth2' : 'OpenStreetMap',
  'openstreetmap_test_oauth2' : 'OpenStreetMap Test Server',
  'custom_basic_auth' : 'Custom (Basic Auth)',
  'custom_oauth2':'Custom (oauth2)',
};

/// Activity for Settings.
///
class SettingsPage extends StatefulWidget {

  @override
  SettingsState createState() => SettingsState();

}

class SettingsState extends State<SettingsPage> {
  String? provider;

  static bool isAutoUpload() {
    return prefs.getBool(Constants.KEY_AUTO_UPLOAD)??true;
  }

  @override
  Widget build(var context) {

    return SettingsScreen(title: "jpsTrack Settings",
      children: [
        SettingsGroup(title: "Upload Info",
          children: [
            SwitchSettingsTile(
              leading: Icon(Icons.upload),
              settingKey: Constants.KEY_AUTO_UPLOAD,
              title: "Upload each track upon 'Stop'?'",
              onChange: (value) {
                debugPrint('$Constants.KEY_AUTO_UPLOAD $value');
              },
            ),
            RadioSettingsTile<String>(
              settingKey: 'map_provider',
              title: 'Map Provider',
              selected: 'OpenStreetMap',
              values: mapProviders,
              onChange: (value) {
                provider = value;
                debugPrint("Value $value");
              }
            ),
            TextInputSettingsTile(
              settingKey: 'custom_url',
              title: 'Custom REST URL',
              enabled:
                  provider == 'custom_basic_auth' ||
                  provider == 'custom_oauth2',
              keyboardType: TextInputType.url,
              validator: (url) {
                // XXX Try uri.parse?
                if (url != null && url.isNotEmpty)
                  return null;
                return "User name is required";
              },
              errorColor: Colors.redAccent,
            ),
          ],
        ),
      ],
    );
  }
}
