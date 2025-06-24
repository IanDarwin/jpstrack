import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:jpstrack/db/database_helper.dart';
import 'package:jpstrack/model/track.dart';
import 'package:jpstrack/main.dart' show dateFormat;
import 'package:jpstrack/io/gpx.dart';
import 'package:jpstrack/ui/nav_drawer.dart';
import 'package:path_provider/path_provider.dart';

import '../constants.dart';
import '../io/upload_gpx.dart';

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
            title: const Center(child: Text("Export Tracks"))
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
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("No tracks yet; add one using 'Track'"),
                );
              };
              debugPrint("ListPage: n=${snapshot.data!.length}");
              debugPrint("In export builder with ${snapshot.data!.length} tracks");
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var track = snapshot.data![index];
                    return ListTile(
                      title: Text("${dateFormat.format(track.time)}"),
                      subtitle: Text("Track with ${track.steps.length} waypoints"),
                      trailing: Wrap(children: [
                        IconButton(
                            constraints: const BoxConstraints(maxWidth: 40),
                            icon: const Icon(Icons.upload),
                            onPressed:  () async {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => UploadGpxScreen(track)));
                            }),
                        IconButton(
                            constraints: const BoxConstraints(maxWidth: 40),
                            icon: const Icon(Icons.save),
                            onPressed: () {
                              print("Save Track # ${track.id}");
                              exportTrackToFile(track);
                            }),
                        IconButton(
                            constraints: const BoxConstraints(maxWidth: 40),
                            icon: const Icon(Icons.delete_forever),
                            onPressed: () async {
                              await delete_track(track);
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
      // String username = SettingsScreen.getLoginName();
      // String passwd = 'abc.123';
      String oauthToken = "fiddlesticks"; // XXX
      Map<String,String> headerMap = {
        "Authorization": "Bearer $oauthToken",
		"Content-Type": "application/gpx+xml",
		"User-Agent": "JPSTrack https://darwinsys.com/jpstrack",
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

  void exportTrackToFile(Track track) async {
    String trackAsGpx = Gpx.buildGPXString(track);
    Directory androidNiceDir = Directory("/sdcard/Download/jpstrack");
    Directory appDir = Platform.isIOS ?
      await getApplicationDocumentsDirectory():
      (
			await Directory("/sdcard/Download").exists()?
				androidNiceDir:
				await getExternalStorageDirectory() as Directory
	  );
    await appDir.create(recursive: true);
    var file = File("${appDir.path}/jpstrack-${track.id}.gpx");
    await file.writeAsString(trackAsGpx);
    await Clipboard.setData(ClipboardData(text: file.path));
    if (!mounted) {
      return;
    }
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder:  (context) => AlertDialog(
                title: const Text("Export Complete"),
                content: Text(
                    "Exported ${track.steps.length} points to file $file. Path copied to clipboard."),
                actions: <Widget> [
                  TextButton(
                      child: Text("OK"),
                      onPressed: () async {
                        Navigator.of(context).pop(); // Alert
                      }
                  )
                ]
            )
        )
    );
  }

  Future<void> delete_track(Track track) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder:  (context) => AlertDialog(
                title: const Text("Really Delete?"),
                content: Text(
                    "Deleting track with ${track.steps.length} points cannot be undone!"),
                actions: <Widget> [
                  TextButton(
                      child: Text("Really Delete"),
                      onPressed: () async {
                        Navigator.of(context).pop(); // Alert
                        await DatabaseHelper().deleteTrack(track);
                        setState(() {
                          // empty
                        });
                      }
                  ),
                  TextButton(
                      child: Text("Cancel"),
                      onPressed: () async {
                        Navigator.of(context).pop(); // Alert
                      }
                  )
                ]
            )
        )
    );
  }
}
