import 'dart:io';
import '../model/point.dart';


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
            out.writeln("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>");
            out.writeln("<gpx version=\"1.1\"");
            out.writeln("    creator=\"jpsTrack flutter client\"");
            out.writeln("    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"");
            out.writeln("    xmlns='http://www.topografix.com/GPX/1/1'");
            out.writeln("    xsi:schemaLocation='http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd'>");
            out.writeln("  <metadata>");
            out.writeln("    <name>jpstrack GPS track log</name>");
            out.writeln("    <time>${DateTime.now()}</time>");
            out.writeln("    <url>httpd://darwinsys.com/jpstrack");
            out.writeln("  </metadata>");
            out.writeln("");
            out.writeln("<!-- track start -->");
            out.writeln("<trk>");
            out.writeln("<src>Logged using jpstrack</src>");
            out.writeln("<link href=\"http://darwinsys.com/jpstrack\"><text>RejmiNet Group Inc.</text></link>");
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
