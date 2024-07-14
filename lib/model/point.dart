

class Point {
	int time;
	double latitude;
	double longitude;
	double altitude;

	Point({
				required this.latitude,
				required this.longitude,
				this.altitude = 0,
				this.time = 0
			});

	@override
	String toString() {
		DateTime dt = DateTime(time);
		return "Point[$dt, LAT $latitude, LON $longitude]";
	}
}
