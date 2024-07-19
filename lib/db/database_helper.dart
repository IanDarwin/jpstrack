import 'dart:async';
import 'package:location/location.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/track.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'jpstrack.db');
    return await openDatabase(path, onCreate: _onCreate, version: 1);
  }

  void _onCreate(Database db, int version) async {
    print("Creating track table");
    await db.execute('''
      -- Table for track set
      CREATE TABLE track (
        id INTEGER PRIMARY KEY,
        time TEXT
      );
     ''');
    print("Creating locationdata table");
    await db.execute('''
      --- Table for data points
      CREATE TABLE locationdata(
        id INTEGER PRIMARY KEY,
        trackset_id INTEGER REFERENCES tracks(id),
        latitude REAL,
        longitude REAL,
        altitude REAL,
        time REAL
      );
    ''');
  }

  Future<int> insertTrack(Track track) async {
    Database dbClient = await db;
    return await dbClient.insert('track', {
      'time': DateTime.now().millisecondsSinceEpoch.toInt(),
    });
  }

  Future<List<Track>> getTracks() async {
    Database dbClient = await db;
    List<Map<String, dynamic>> raw = await dbClient.query('track');
    List<Track> retVal = [];
    for (var x in raw) {
      Track track = Track(x['id'], DateTime.fromMillisecondsSinceEpoch(int.parse(x['time'])));
      retVal.add(track);
      List<Map<String, dynamic>> ret = await dbClient.rawQuery("SELECT * FROM locationdata l WHERE l.trackset_id = ${track.id}");
      for (Map<String,dynamic> map in ret) {
        LocationData loc = LocationData.fromMap(map);
        track.add(loc);
      }
      print("Reassembled track: $track");
    }
    return retVal;
  }

  Future<bool> deleteTrack(Track track) async {
    var dbClient = await db;
    await dbClient.delete("locationdata", where: "trackset_id = ?", whereArgs: [track.id]);
    int updateCount = await dbClient.delete("track", where: "id = ?", whereArgs: [track.id]);
    return updateCount == 1;
  }

  Future<int> insertLocation(LocationData location, int tracksetId) async {
    Database dbClient = await db;
    return await dbClient.insert('locationdata', {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'altitude' : location.altitude,
      'time': location.time.toString(),
      'trackset_id': tracksetId,
    });
  }
}

