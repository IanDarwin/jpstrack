import "package:location/location.dart";

class Track {
	int id;
	DateTime start;
	List<LocationData> steps =[];
	Track(int this.id, DateTime this.start);

  void add(LocationData loc) {
		steps.add(loc);
	}
}
