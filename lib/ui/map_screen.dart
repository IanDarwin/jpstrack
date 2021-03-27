import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';

///
/// The main page of the application. Shows current lat/long, and underneath all,
/// a map view showing what's already in OSM, to avoid wasted effort.
///
class MapScreen extends StatefulWidget {
  final String title;

  MapScreen({Key key, this.title}) : super(key: key);

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<MapScreen> {

  double lat = 51.48;
  double lng = 0.0;
  double zoom = 13;

  Widget build(BuildContext context) {
    MapController controller = MapController();
    controller.mapEventStream.listen((event) {
      //
    });
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
            actions: <Widget>[
              new IconButton(icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer()),
            ],
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {  },
                        child: Text("Start")),
                    ElevatedButton(onPressed: () {  },
                        child: Text("Stop")),
                    Text("Lat"),
                    Text(lat.toString()),
                    Text("Lon"),
                    Text(lng.toString()),
                  ]
              ),
              //
              // The Map!
              //
              Expanded(child: FlutterMap(
                options: MapOptions(
                  center: LatLng(lat, lng),
                  zoom: zoom,
                ),
                mapController: controller,
                layers: [
                  new TileLayerOptions(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                      tileProvider: const CachedTileProvider(),
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

class CachedTileProvider extends TileProvider {
  const CachedTileProvider();
  @override
  ImageProvider getImage(Coords<num> coords, TileLayerOptions options) {
    return CachedNetworkImageProvider(
      getTileUrl(coords, options),
      //Now you can set options that determine how the image gets cached via whichever plugin you use.
    );
  }
}