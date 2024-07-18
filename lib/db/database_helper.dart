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
    print("Creating tracks table");
    await db.execute('''
      -- Table for track set
      CREATE TABLE tracks(
        id INTEGER PRIMARY KEY,
        start TEXT
      );
     ''');
    print("Creating locations table");
    await db.execute('''
      --- Table for data points
      CREATE TABLE locations(
        id INTEGER PRIMARY KEY,
        trackset_id INTEGER REFERENCES tracks(id),
        latitude REAL,
        longitude REAL,
        altitude REAL,
        timestamp TEXT
      );
    ''');
  }

  Future<int> insertTrack(Track track) async {
    Database dbClient = await db;
    return await dbClient.insert('tracks', {
      'start': DateTime.now().toString()
    });
  }

  Future<List<Track>> getTracks() async {
    Database dbClient = await db;
    List<Map<String, dynamic>> raw = await dbClient.query('tracks');
    List<Track> ret = [];
    for (var x in raw) {
      Track t = Track(x['id'], DateTime.parse(x['start']));
      // XXX Get the readings!!!
      ret.add(t);
    }
    return ret;
  }

  Future<int> insertLocation(LocationData location, int tracksetId) async {
    Database dbClient = await db;
    return await dbClient.insert('locations', {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'altitude' : location.altitude,
      'timestamp': location.time.toString(),
      'trackset_id': tracksetId,
    });
  }

  Future<List<Map<String, dynamic>>> getLocations() async {
    Database dbClient = await db;
    return await dbClient.query('locations');
  }

  Future<void> deleteLocations() async {
    Database dbClient = await db;
    await dbClient.delete('locations');
  }
}

