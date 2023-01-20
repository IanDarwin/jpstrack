import 'dart:io';
import '../model/point.dart';

final header =
"""<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
    <gpx version="1.1"
	creator="jpsTrack flutter client"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns='http://www.topografix.com/GPX/1/1'
	xsi:schemaLocation='http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd'>
      <metadata>
	<name>jpstrack GPS track log</name>
	<time>${DateTime.now()}</time>
	<url>httpd://darwinsys.com/jpstrack
      </metadata>

    <!-- track start -->
    <trk>
    <src>Logged using jpstrack</src>
    <link href="http://darwinsys.com/jpstrack"><text>RejmiNet Group Inc.</text></link>
    """;

class GPSFileSaver {
    String startingDir;
    String fileName;
    IOSink out;

    GPSFileSaver(this.startingDir, this.fileName);

    void startFile() {
        if(startingDir == null || fileName == null)
            throw NullThrownError();//"Neither startDir nor fileName may be null");
        File f = File(startingDir + "/" + fileName);
        try {
            out = f.openWrite();
            out.writeln(header);
            out.writeln("<trkseg>");
        } catch (e) {
            throw Exception("Can't create file $f: $e");
        }
    }

    addPoint(Point r) {
        addPointData(r.time, r.latitude, r.longitude, r.altitude);
    }

    addPointData(int time, double latitude, double longitude, double elven) {
        out.writeln("<trkpt lat='$latitude' lon='$longitude'>");
        out.writeln("    <ele>$elven</ele>");
        out.writeln("    <time>${DateTime(time)}</time>"); //df.format(date));
        out.writeln("    <fix>3d</fix>");
        out.writeln("</trkpt>");
        out.flush();
    }

    /** Close the file, after outputting the trailing end tags  */
    endFile() {
        out.writeln("</trkseg>");
        out.writeln("</trk>");
        out.writeln("</gpx>");
        out.flush();
        out.close();
    }
}
