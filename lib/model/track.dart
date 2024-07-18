import "package:location/location.dart";

class Track {
	int id;
	DateTime start;
	List<Location> steps =[];
	Track(int this.id, DateTime this.start);
}
