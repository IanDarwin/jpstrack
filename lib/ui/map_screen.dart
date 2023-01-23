import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:jpstrack/generated/l10n.dart';

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

  double zoom = 11;
  MapController controller = MapController();
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  Stream<LocationData> _str;
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
          center: _locationDataToLatLng(_locationData),
          zoom: zoom,
        ),
        mapController: controller,
        nonRotatedChildren: [
          Center(child: Icon(Icons.add, size:64)),
          Column(children: [
            Row(children: [
              ElevatedButton(
                  child: Text(S.of(context).start),
                  onPressed: () {
                    debugPrint("Starting to listen for updates");
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
                child: Text(S.of(context).stop),
                onPressed: () {
                  debugPrint("Stopping...");
                  // _str.close(); // ??
                },
              ),
            ]),
            Row(children:[
              Text(S.of(context).latitude, style: infoStyle),
              Text(' '),
              Text("X.XXXXX"/*lat.toString()*/, style: infoStyle),
            ]),
            Row(children:[
              Text(S.of(context).longitude, style: infoStyle),
              Text(' '),
              Text("X.XXXXX"/*lon.toString()*/, style: infoStyle),
            ]),
          ]),
          AttributionWidget.defaultWidget(
            source: 'OpenStreetMap contributors',
            onSourceTapped: () {},
          ),
        ],
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.darwinsys.jpstrack.devel',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { },
        tooltip: 'Annotate',
        child: Icon(Icons.add),
      ),
    );
  }

  LatLng _locationDataToLatLng(LocationData loc) {
    if (loc == null) {
      return LatLng(0.0, 0.0);
    }
    var lat = loc.latitude??0;
    var lon = loc.longitude??0;
    return LatLng(lat, lon);
  }
}
