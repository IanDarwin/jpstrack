import "package:location/location.dart";

class Track {
	int id;
	DateTime time;
	List<LocationData> steps =[];
	Track(int this.id, DateTime this.time);

  void add(LocationData loc) {
		steps.add(loc);
	}

	@override
  String toString() {
		return "Track($time, ${steps.length} waypoints)";
	}
}
