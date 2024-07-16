import 'package:flutter/material.dart';

/// Activity for Export
///
class ExportPage extends StatefulWidget {

  @override
  ExportState createState() => ExportState();

}

class ExportState extends State<ExportPage> {

  @override
  Widget build(var context) {
    return Scaffold(
        body:Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                const Text('Export not written yet'),
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

