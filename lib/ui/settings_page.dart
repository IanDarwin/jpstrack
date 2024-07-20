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

  static String getLoginName() {
	return prefs.getBool(Constants.KEY_LOGIN_NAME);
  }

  static boolean isAutoUpload() {
    return prefs.getBool(Constants.KEY_AUTO_UPLOAD, true);
  }

  Widget build(var context) {
    return SettingsScreen(title: "jpsTrack Settings",
      children: <Widget>[
        SettingsGroup(title: "OSM Info",
            children: [
              TextInputSettingsTile(
                title: "Login name",
                settingKey: Constants.KEY_LOGIN_NAME,
                keyboardType: TextInputType.name,
                validator: (loginName) {
                  if (loginName != null && loginName.isNotEmpty)
                    return null;
                  return "User name is required";
                },
                errorColor: Colors.redAccent,
              ),
              SwitchSettingsTile(
                leading: Icon(Icons.upload),
                settingKey: Constants.KEY_AUTO_UPLOAD,
                title: 'Upload each new track to OSM?',
                onChange: (value) {
                  debugPrint('$Constants.KEY_AUTO_UPLOAD $value');
                },
              ),
            ]
        ),
      ],
    );
  }
}
