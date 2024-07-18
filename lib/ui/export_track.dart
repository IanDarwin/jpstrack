import 'package:flutter/material.dart';
import 'package:jpstrack/db/database_helper.dart';

import '../model/track.dart';
import 'nav_drawer.dart';

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
                  title: Text("Track ${track.start.toIso8601String()}"),
                  subtitle: Text("Track with ${track.steps.length} items"),
					trailing: Wrap(children: [
                        IconButton(
                            constraints: BoxConstraints(maxWidth: 40),
                            icon: Icon(Icons.save),
                            onPressed: () {
                              print("Save");
                            }),
                        IconButton(
                            constraints: BoxConstraints(maxWidth: 40),
                            icon: Icon(Icons.upload),
                            onPressed: () {
                              print("Upload");
                            }),
                        IconButton(
                            constraints: BoxConstraints(maxWidth: 40),
                            icon: Icon(Icons.delete_forever),
                            onPressed: () {
                              print("Delete");
                            }),
                  ]),
                );
              }
          );
        }
    )
    );
  }
}
