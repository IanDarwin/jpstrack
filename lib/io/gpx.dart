
import 'package:xml/xml.dart' as xml;

// GPX Writer, written by ChatGPT
class Gpx {
  String _buildGPXString(List<Map<String, dynamic>> locations) {
    xml.XmlBuilder builder = xml.XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('gpx', namespaces: {
      'gpxtpx': 'http://www.garmin.com/xmlschemas/TrackPointExtension/v1',
    }, attributes: {
      'version': '1.1',
      'creator': 'jpstrack',
    }, nest: () {
      builder.element('trk', nest: () {
        builder.element('name', nest: 'Track');
        builder.element('trkseg', nest: () {
          for (var location in locations) {
            builder.element('trkpt', attributes: {
              'lat': location['latitude'].toString(),
              'lon': location['longitude'].toString(),
              'alt': location['altitude'].toString(),
            }, nest: () {
              builder.element('time', nest: location['timestamp']);
            });
          }
        });
      });
    });
    return builder.buildDocument().toXmlString(pretty: true, indent: '  ');
  }
}
