import "package:location/location.dart";
import "dart.io";

class Track {
	int id;
	DateTime start;
	List<Location> steps =[];
	Track(int this.id, DateTime this.start);
}
