
import 'package:xml/xml.dart' as xml;

import '../model/track.dart';

// GPX Writer, written by ChatGPT
class Gpx {
  static String buildGPXString(Track track) {
    xml.XmlBuilder builder = xml.XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('gpx', namespaces: {
      'gpxtpx': 'http://www.garmin.com/xmlschemas/TrackPointExtension/v1',
    }, attributes: {
      'version': '1.1',
      'creator': 'jpstrack',
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
              builder.element('time', nest: 
                DateTime.fromMillisecondsSinceEpoch(location.time!.toInt()));
            });
          }
        });
      });
    });
    return builder.buildDocument().toXmlString(pretty: true, indent: '  ');
  }
}
