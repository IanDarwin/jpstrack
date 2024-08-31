
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:xml/xml.dart' as xml;

import 'package:jpstrack/model/track.dart';

// GPX Writer, written by ChatGPT
class Gpx {
  // We stick the Z on arbitrarily because Dart's date format
  // class apparently isn't capable of printing the actual tz
  static DateFormat iso8166df = DateFormat("yyyy-MM-d'T'HH:mm:ss'Z'");

  static String buildGPXString(Track track) {
    xml.XmlBuilder builder = xml.XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('gpx',
        attributes: {
          'xmlns':'http://www.garmin.com/xmlschemas/TrackPointExtension/v1',
          'version': '1.1',
          'creator': 'https://darwinsys.com/jpstrack',
        }, nest: () {
          builder.element('trk', nest: () {
            builder.element('name', nest: 'Track ${track.id}');
            builder.element('trkseg', nest: () {
              for (var location in track.steps) {
                builder.element('trkpt', attributes: {
                  'lat': location.latitude.toString(),
                  'lon': location.longitude.toString(),
                  'alt': location.altitude.toString(),
                }, nest: () {
                  builder.element('time',
                      nest: iso8166df.format(
                        // location_platform_interface gives timestamp as a double
                        // holding the # of mSec since the epoch.
                        DateTime.fromMillisecondsSinceEpoch(location.time!.toInt())));
                });
              }
            });
          });
        });
    return builder.buildDocument().toXmlString(pretty: true, indent: '  ');
  }
}

void main()  {
  var dataMap = { 'latitude':20.0, 'longitude': 0, 'altitude': 50 };
  LocationData data = LocationData.fromMap(dataMap);
  Track t = Track(5, DateTime(2044, 6, 10, 23, 59));
  t.add(data);
  print(Gpx.buildGPXString(t));
}