import 'dart:async';
import 'package:location/location.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    await db.execute('''
      CREATE TABLE locations(
        id INTEGER PRIMARY KEY,
        trackset_id INTEGER,
        latitude REAL,
        longitude REAL,
        altitude REAL,
        timestamp TEXT
      )
    ''');
  }

  Future<int> insertLocation(LocationData location) async {
    Database dbClient = await db;
    return await dbClient.insert('locations', {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'altitude' : location.altitude,
      'timestamp': DateTime.now().toString()
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

