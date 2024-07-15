import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

///
/// The main page of the application. Shows current lat/long, and underneath all,
/// a map view showing what's already in OSM, to avoid wasted effort.
///
class MapScreen extends StatefulWidget {
  final String title;

  MapScreen({required this.title}) : super();

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<MapScreen> {

  double zoom = 11;
  MapController controller = MapController();
  Location location = new Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  late Stream<LocationData> _str;
  var labelStyle = TextStyle(fontSize: 28, color: Colors.black45);
  var infoStyle = TextStyle(fontSize: 28);

  @override
  void initState() {
    _initLocation();
    super.initState();
  }

  void _initLocation() async {
    _locationData = LocationData.fromMap({"latitude":51.480, "longitude":0.0});
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
    // This doesn't appear to get any data
    controller.mapEventStream.listen((event) {  debugPrint("Event: $event"); });
  }

  Widget build(BuildContext context) {
    debugPrint("In jpsTrack::MapState::build, locale is ${Localizations.localeOf(context)}");
    controller.mapEventStream.listen((event) { debugPrint(event.toString()); });
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          new IconButton(icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer()),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _locationDataToLatLng(_locationData),
          initialZoom: zoom,
        ),
        mapController: controller,
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.darwinsys.jpstrack.devel',
          ),
          Center(child: Icon(Icons.add, size:64)),
          Column(children: [
            Row(children: [
              ElevatedButton(
                  child: Text("Start"),
                  onPressed: () {
                    debugPrint("Starting to listen for updates");
                    location.enableBackgroundMode(enable: true);
                    _str = location.onLocationChanged;
                    _str.listen((LocationData loc) {
                      print("Location $loc");
                      // controller.move(locationDataToLatLng(loc), zoom);
                      setState(() => _locationData = loc);
                    },
                    );
                  }
              ),
              ElevatedButton(
                child: Text("Pause"),
                onPressed: () {
                  debugPrint("Stopping...");
                  // _str.close(); // ??
                },
              ),
              ElevatedButton(
                child: Text("Stop"),
                onPressed: () {
                  debugPrint("Stopping...");
                  // _str.close(); // ??
                },
              )
            ]),
            Row(children:[
              Text("Latitude", style: labelStyle),
              Text(' '),
              Text("X.XXXXX"/*lat.toString()*/, style: infoStyle),
            ]),
            Row(children:[
              Text('Longitude', style: labelStyle),
              Text(' '),
              Text("X.XXXXX"/*lon.toString()*/, style: infoStyle),
            ]),
          ]),
          SimpleAttributionWidget(
            source: Text('OpenStreetMap contributors'),
            onTap: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {debugPrint("Would Re-center map on GPS loc");  },
        tooltip: 'Annotate',
        child: Icon(Icons.gps_fixed_sharp),
      ),
    );
  }

  LatLng _locationDataToLatLng(LocationData loc) {
    var lat = loc.latitude??0;
    var lon = loc.longitude??0;
    return LatLng(lat, lon);
  }
}
