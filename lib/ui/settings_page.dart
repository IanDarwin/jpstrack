import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {

  Widget build(var context) {
    return Scaffold(
        body:Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                const Text('Settings not written yet'),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                )
              ]
            )
        )
    );
  }
}

