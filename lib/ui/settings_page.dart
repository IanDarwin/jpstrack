import 'package:flutter/material.dart';

import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:jpstrack/constants.dart';
import 'package:jpstrack/main.dart' show prefs;

/// Activity for Settings.
///
class SettingsPage extends StatefulWidget {

  @override
  SettingsState createState() => SettingsState();

}

class SettingsState extends State<SettingsPage> {
  int? provider;

  static bool isAutoUpload() {
    return prefs.getBool(Constants.KEY_AUTO_UPLOAD)??true;
  }

  @override
  Widget build(var context) {
    var list = UploadDest.values;
    print(list);

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
            RadioSettingsTile<int>(
              settingKey: 'map_provider',
              title: 'Map Provider',
              selected: 0,
              values: <int,String> {
               0 : list[0].name,
               1 : list[1].name,
               2 : list[2].name,
               3 : list[3].name,
              },
              onChange: (value) {
                provider = value;
                debugPrint("Value $value");
              }
            ),
            TextInputSettingsTile(
              settingKey: Constants.KEY_CUSTOM_URL,
              title: 'Custom REST URL',
              enabled:
                  provider == 2 ||
                  provider == 3,
              keyboardType: TextInputType.url,
              validator: (url) {
                // XXX Try uri.parse?
                if (url != null && url.isNotEmpty)
                  return null;
                return "URL cannot be empty";
              },
              errorColor: Colors.redAccent,
            ),
          ],
        ),
      ],
    );
  }
}
