import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:location/location.dart';

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

  double zoom = 13;
  MapController controller = MapController();
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  Stream<LocationData> _str;

  @override
  void initState() {

    _initLocation();

    super.initState();
  }

  void _initLocation() async {
    Map<String, dynamic> map = {"latitude":0, "longitude":0};
    _locationData = LocationData.fromMap(map);
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    //_locationData = await location.getLocation();
    location.changeSettings(
        accuracy: LocationAccuracy.high,
      interval: 10000,
      distanceFilter: 5.0);
  }

  Widget build(BuildContext context) {

    controller.mapEventStream.listen((event) {});
    return Scaffold(
        appBar: AppBar(
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
                        child: Text("Start"),
                        onPressed: () {
                          print("Starting to listen for updates");
                          location.enableBackgroundMode(enable: true);
                          _str = location.onLocationChanged;
                          _str.listen((LocationData loc) {
                            print("Location $loc");
                            // controller.move(locationDataToLatLng(loc), zoom);
                            setState(() => _locationData = loc);
                          },
                          );}
                          ),
                    ElevatedButton(
                      child: Text("Stop"),
                      onPressed: () {
                        print("Stopping...");
                        // _str.close(); // ??
                      },
                    ),
                    // Text("Lat"),
                    // Text(lat.toString()),
                    // Text("Lon"),
                    // Text(lng.toString()),
                  ]
              ),
              //
              // The Map!
              //
              Expanded(child: FlutterMap(
                options: MapOptions(
                  center: _locationDataToLatLng(_locationData),
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
                        point: _locationDataToLatLng(_locationData),
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

  LatLng _locationDataToLatLng(LocationData loc) {
    var lat = loc.latitude;
    var lon = loc.longitude;
    return LatLng(lat, lon);
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