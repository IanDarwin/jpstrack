import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jpstrack/db/database_helper.dart';
import 'package:jpstrack/service/location_service.dart';
import 'package:jpstrack/ui/take_picture.dart';
import 'package:jpstrack/ui/text_note.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';

import '../model/track.dart';
import 'audio_note.dart';
import 'export_track.dart';

///
/// The real "main" page of the application. Shows current lat/long, and underneath all,
/// a map view showing what's already in OSM, to avoid wasted effort.
///
class MapScreen extends StatefulWidget {
  final String title;

  MapScreen({required this.title}) : super();

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  double zoom = 20;
  MapController controller = MapController();
  Location location = new Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  var labelStyle = TextStyle(fontSize: 28, color: Colors.black54);
  var infoStyle = TextStyle(fontSize: 28);

  @override
  void initState() {
    _initLocation();
    super.initState();
  }

  void _initLocation() async {
    _locationData = LocationData.fromMap({"latitude":51.6, "longitude":0.0});
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
    debugPrint("In jpsTrack::MapState::build");
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

            // First row of buttons: start,pause/resume, stop recording
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              ElevatedButton(
                  child: Text("Track"),
                  onPressed: () {
                    debugPrint("Starting to listen for updates");
                    _startTracking();
                    },
              ),
              ElevatedButton(
                child: Text("Pause"),
                onPressed: () {
                  debugPrint("Pausing...");
                  // _str.close(); // ??
                },
              ),
              ElevatedButton(
                child: Text("Stop"),
                onPressed: () {
                  debugPrint("Stopping...");
                  _stopTracking();
                },
              ),
                  ElevatedButton(onPressed: () {
                    debugPrint("Export requested");
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => ExportPage()));
                  },
                      child: const Text("Export"),
                  )
            ]),

            // Second row of buttons: adding notes
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
              ElevatedButton(onPressed: () {
                debugPrint("Text Note");
                _createTextNote(context);
              },
                  child: const Text("Text Note")
              ),
              ElevatedButton(onPressed: () {
                _recordAudioNote();
                debugPrint("Voice Note");
              },
                  child: const Text("Voice Note")
              ),
              ElevatedButton(onPressed: () {
                debugPrint("Take Picture");
                _takePicture();
              },
                  child: const Text("Take Picture")
              ),
            ]),

            Row(children:[
              Text("Latitude", style: labelStyle),
              Text(' '),
              Text(_locationData.latitude.toString(), style: infoStyle),
            ]),
            Row(children:[
              Text('Longitude', style: labelStyle),
              Text(' '),
              Text(_locationData.longitude.toString(), style: infoStyle),
            ]),
            Row(children:[
              Text('Altitude', style: labelStyle),
              Text(' '),
              Text(_locationData.altitude.toString(), style: infoStyle),
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

  void _startTracking() async {
    Track t = Track(0, DateTime.now());
    final int id = await DatabaseHelper().insertTrack(t);
    t.id = id;
    Stream<LocationData> locationStream = _locationService.getLocationStream();
    locationStream.listen((LocationData locationData) {
      _databaseHelper.insertLocation(locationData, id);
      setState(() {
        _locationData = locationData;
        controller.move(_locationDataToLatLng(_locationData), 20);
      });
    });
  }

  void _stopTracking() async {
    List<Map<String, dynamic>> currentRunLocations = await _databaseHelper.getLocations();
    if (currentRunLocations.isNotEmpty) {
      // String gpxString = _buildGPXString(currentRunLocations);
      // await _saveGPXToFile(gpxString);
      // await _databaseHelper.deleteLocations();
    }
    setState(() {
      // empty
    });
  }

  void _createTextNote(BuildContext context) async {
    String? textNote = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TextNoteScreen()),
    );
    if (textNote != null) {
      // Save textNote to the same location as GPX
      Directory? directory = await getExternalStorageDirectory();
      if (directory != null) {
        File textFile = File('${directory.path}/text_note.txt');
        await textFile.writeAsString(textNote);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Text note saved to ${textFile.path}')),
        );
      }
    }
  }

  void _recordAudioNote() async {
    String? imagePath = await Navigator.push(context,
      MaterialPageRoute(builder: (context) => const AudioNoteScreen()),
    );
    if (imagePath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio saved to $imagePath')),
      );
    }
  }

  void _takePicture() async {
    String? imagePath = await Navigator.push(context,
      MaterialPageRoute(builder: (context) => const TakePictureScreen()),
    );
    if (imagePath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Picture saved to $imagePath')),
      );
    }
  }

  LatLng _locationDataToLatLng(LocationData loc) {
    var lat = loc.latitude??0;
    var lon = loc.longitude??0;
    return LatLng(lat, lon);
  }
}
