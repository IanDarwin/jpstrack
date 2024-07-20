import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jpstrack/db/database_helper.dart';
import 'package:jpstrack/model/track.dart';
import 'package:jpstrack/main.dart' show dateFormat;
import 'package:jpstrack/io/gpx.dart';
import 'package:jpstrack/ui/nav_drawer.dart';
import 'package:jpstrack/ui/settings_page.dart';

import '../constants.dart';

/// Activity for Export
///
class ExportPage extends StatefulWidget {

  @override
  ExportListState createState() => ExportListState();

}

class ExportListState extends State<ExportPage> {
  late Future<List<Track>> tracks;

  getTracks() async {
    tracks = DatabaseHelper().getTracks();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("In ExportListState::build");
    return Scaffold(
        appBar: AppBar(
            title: Center(child: Text("Export Tracks"))
        ),
        drawer: NavDrawer(),
        body: FutureBuilder(
            future: DatabaseHelper().getTracks(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return Center(
                    child: Text(
                        "Data error: ${snapshot.error}!")
                );
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.length == 0) {
                return Center(
                  child: Text("No tracks yet; add one using 'Track'"),
                );
              };
              print("ListPage: n=${snapshot.data!.length}");
              debugPrint("In export builder with ${snapshot.data!.length}");
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    debugPrint("In ItemBuilder for $index");
                    var track = snapshot.data![index];
                    return ListTile(
                      title: Text("${dateFormat.format(track.time)}"),
                      subtitle: Text("Track with ${track.steps.length} items"),
                      trailing: Wrap(children: [
                        IconButton(
                          disabledColor: Colors.grey,
                            constraints: BoxConstraints(maxWidth: 40),
                            icon: Icon(Icons.map),
                            onPressed: null
                        ),
                        IconButton(
                            constraints: BoxConstraints(maxWidth: 40),
                            icon: Icon(Icons.upload),
                            onPressed: () async {
                              print("Upload");
                              uploadToOSM(track);
                            }),
                        IconButton(
                            constraints: BoxConstraints(maxWidth: 40),
                            icon: Icon(Icons.save),
                            onPressed: () {
                              print("Save");
                            }),
                        IconButton(
                            constraints: BoxConstraints(maxWidth: 40),
                            icon: Icon(Icons.delete_forever),
                            onPressed: () async {
                              print("Delete");
                              await DatabaseHelper().deleteTrack(track);
                              setState(() {
                                // empty
                              });
                            }),
                      ]),
                    );
                  }
              );
            }
        )
    );
  }

  Future<void> uploadToOSM(Track track) async {
    try {
      var url = Uri.parse(Constants.URL_UPLOAD);
      String trackAsGpx = Gpx.buildGPXString(track);
      String username = SettingsState.getLoginName();
      String passwd = 'abc.123';
      Map<String,String> headerMap = {
        "Authorization":"Basic ${base64.encode(utf8.encode('$username:$passwd'''))}"
      };
      var response = await http.post(url,
          body: trackAsGpx,
          headers: headerMap);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check the response status
      if (response.statusCode == 200) {
        print('Uploaded successfully');
      } else {
        print('Upload failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading data: $e');
    }
  }
}
