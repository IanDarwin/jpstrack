import 'package:flutter/material.dart';

import 'package:flutter_settings_screens/flutter_settings_screens.dart';

/// Activity for Settings.
///
class SettingsPage extends StatefulWidget {

  @override
  SettingsState createState() => new SettingsState();

}

class SettingsState extends State<SettingsPage> {

  Widget build(var context) {

    return SettingsScreen(title: "jpsTrack Settings",
      children: <Widget>[
        SettingsGroup(title: "OSM Info",
            children: [
              TextInputSettingsTile(
                title: "Login name",
                settingKey: "login",
                keyboardType: TextInputType.name,
                validator: (loginName) {
                  if (loginName != null && loginName.isNotEmpty)
                    return null;
                  return "User name is required";
                },
                errorColor: Colors.redAccent,
              ),
            ]
        ),
      ],
    );
  }
}
