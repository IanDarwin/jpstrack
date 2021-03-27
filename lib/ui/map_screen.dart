import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:jpstrack/ui/nav_drawer.dart';

class MapScreen extends StatefulWidget {
  final String title;

  MapScreen({Key key, this.title}) : super(key: key);

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<MapScreen> {

  double lat = 0;
  double lng = 0;
  double zoom = 10;

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        drawer: NavDrawer(),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {  },
                        child: Text("Start")),
                    ElevatedButton(onPressed: () {  },
                        child: Text("Stop"))
                  ]
              ),
              Expanded(child: FlutterMap(
                options: MapOptions(
                  center: LatLng(lat, lng),
                  zoom: zoom,
                ),
                layers: [
                  new TileLayerOptions(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c']
                  ),
                  new MarkerLayerOptions(
                    markers: [
                      new Marker(
                        width: 60.0,
                        height: 60.0,
                        point: new LatLng(lat, lng),
                        builder: (context) =>
                        new Container(
                          child: new FlutterLogo(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ),
            ]
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () { },
          tooltip: 'Annotate',
          child: Icon(Icons.add),
        ),
    );
  }
}
