import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:jpstrack/db/database_helper.dart';
import 'package:jpstrack/io/gpx.dart';
import 'package:jpstrack/model/track.dart';
import 'package:jpstrack/service/location_service.dart';
import 'package:jpstrack/ui/settings_page.dart';
import 'package:jpstrack/ui/take_picture.dart';
import 'package:jpstrack/ui/text_note.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';

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
  final altitudeFormat = NumberFormat("#####.0#", "en_US");
  MapController controller = MapController();
  Track? currentTrack = null;
  Location location = Location();
  late bool _serviceEnabled;
  double zoom = 20;
  late PermissionStatus _permissionGranted;
  LocationData _locationData = LocationData.fromMap(
      {
        "latitude":51.6,
        "longitude":0.0,
        'altitude': 0.0,
        "time": 0.0
      }
  );
  var labelStyle = TextStyle(fontSize: 28, color: Colors.black54);
  var infoStyle = TextStyle(fontSize: 28);

  @override
  void initState() {
    _initLocation();
    super.initState();
  }

  void _initLocation() async {
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

    // Yes, please keep mapping running in background.
    try {
      await location.enableBackgroundMode(enable: true);
    } on PlatformException catch (_) {
      await Navigator.push(context,
          MaterialPageRoute(builder: (context) => AlertDialog(
              title: const Text("Permission problem"),
              content: const Text(
              "Can't enable background saving.\n" +
              'Please enable "Always Allow" location permission ' +
              'in "Settings->Apps->jpstrack"'),
              actions: [
                TextButton(
                  child: Text("Settings"),
                  onPressed: () async {
                    AppSettings.openAppSettings(type: AppSettingsType.location);
                  }
                ),
                TextButton(
                    child: Text("Close"),
                    onPressed: () async {
                      Navigator.of(context).pop(); // alert
                    }
                )
              ]
          )));
    }

    //_locationData = await location.getLocation();
    location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 10000,
        distanceFilter: 5.0);
    controller.mapEventStream.listen((event) {  debugPrint("Event: $event"); });
  }

  Widget build(BuildContext context) {
    debugPrint("In jpsTrack::MapState::build");
    controller.mapEventStream.listen((event) { debugPrint(event.toString()); });
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.menu),
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
                    onPressed: currentTrack != null ? null :  () {
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
                    onPressed: currentTrack == null ? null :  () {
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
                  ElevatedButton(onPressed: currentTrack == null ? null :  () {
                    debugPrint("Text Note");
                    _createTextNote(context);
                  },
                      child: const Text("Text Note")
                  ),
                  ElevatedButton(onPressed: currentTrack == null ? null :  () {
                    _recordAudioNote();
                    debugPrint("Voice Note");
                  },
                      child: const Text("Voice Note")
                  ),
                  ElevatedButton(onPressed: currentTrack == null ? null :  () {
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
              Text(altitudeFormat.format(_locationData.altitude), style: infoStyle),
            ]),
          ]),

          SimpleAttributionWidget(
            source: Text('OpenStreetMap contributors'),
            onTap: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          debugPrint("Getting location to re-center");
          _locationData = await(location.getLocation());
          debugPrint("Re-center map on GPS loc to $_locationData");
          controller.move(_locationDataToLatLng(_locationData), 20);
          setState(() {
            // empty
          });
        },
        tooltip: 'Re-Center',
        child: Icon(Icons.gps_fixed_sharp),
      ),
    );
  }

  void _startTracking() async {
    currentTrack = Track(0, DateTime.now());
    final int id = await DatabaseHelper().insertTrack(currentTrack!);
    currentTrack!.id = id;
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
    if (SettingsState.isAutoUpload()) {
      String gpxString = Gpx.buildGPXString(currentTrack!);
      // await _saveGPXToFile(gpxString);
    }
    setState(() {
      currentTrack = null;
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
