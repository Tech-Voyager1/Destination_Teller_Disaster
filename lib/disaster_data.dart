import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class FirebaseService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  Set<Marker> permanentMarkers = {};
  List<Map<String, dynamic>> permanentDataList = [];

  Future<void> fetchDisasterData(String username) async {
    // if (!toBeFetched) return; // 🔥 Prevent duplicate fetches
    print("Inside fetchData...");

    try {
      print("Fetching data from Firebase...");
      DatabaseReference __databaseRef = _databaseRef
          .child(username.replaceAll('.', '_').replaceAll('\$', '_'));
      DatabaseEvent event =
          await __databaseRef.once(); // Fetch latest data once

      if (!event.snapshot.exists) {
        print("No data found.");

        return;
      }

      final Map data = event.snapshot.value as Map;
      List<Map<String, dynamic>> tempDataList = [];
      Set<Marker> tempMarkers = {};

      data.forEach((key, value) {
        print("Processing key: $key, value: $value");

        int timestamp = value["Timestamp"] ?? 0;
        String formattedTime = timestamp != 0
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(
                DateTime.fromMillisecondsSinceEpoch(timestamp)) // No *1000
            : "Unknown";

        double lat = double.tryParse(value["Latitude"].toString()) ?? 0.0;
        double lng = double.tryParse(value["Longitude"].toString()) ?? 0.0;
        String disaster = value["Disaster"] ?? "Unknown";
        String riskLevel = value["Risklevel"] ?? "Unknown";

        tempDataList.add({
          "location": key,
          "disastertag": disaster,
          "lat": lat,
          "lng": lng,
          "risklevel": riskLevel,
          "time": formattedTime,
        });

        tempMarkers.add(
          Marker(
            point: LatLng(lat, lng),
            //builder: (ctx) => Image.asset("asset/images/$disaster.png"),
            builder: (ctx) => Tooltip(
              message: disaster,
              child: Image.asset("asset/images/$disaster.png"),
            ),
            // New icon
          ),
        );
      });

      // _disasterList = tempList;

      permanentMarkers = tempMarkers;
      permanentDataList = tempDataList;
      //print(permanentDataList);

      print("Markers updated successfully, notifying listeners...");
      // notifyListeners(); // 🔄 Notify UI of data change
    } catch (error) {
      print("Error fetching data: $error");
      // _isLoading = false;
      //  notifyListeners();
    }
  }

  Future<void> deleteLocation(String locationKey, String username) async {
    try {
      DatabaseReference __databaseRef = _databaseRef.child(username);
      await __databaseRef.child(locationKey).remove(); // Remove from Firebase
      print("$locationKey deleted successfully.");

      // **Reorder locations after deletion**
      // await _deleteAndReorder();

      // fetchData(true); // Refresh data after deletion
    } catch (e) {
      print("Error deleting location: $e");
    }
  }
}
