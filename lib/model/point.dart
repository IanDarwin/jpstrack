import 'package:flutter/material.dart';

class Point {
	int time;
	double latitude;
	double longitude;
	double altitude;

	Point({
				@required this.latitude,
				@required this.longitude,
				this.altitude,
				this.time
			});

	@override
	String toString() {
		DateTime dt = DateTime(time);
		return "Point[$dt, LAT $latitude, LON $longitude]";
	}
}
