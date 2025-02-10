import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final String user_name;
  const MapScreen(this.user_name);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _tappedLocation;
  final MapController _mapController = MapController();
  late DatabaseReference _reference;
  bool state = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _reference = FirebaseDatabase.instance
        .ref(widget.user_name.replaceAll('.', '_').replaceAll('\$', '_'));
  }

  Future<void> saveLocation(LatLng? tappedLocation) async {
    if (tappedLocation == null) return;
    String lat = tappedLocation.latitude.toString();
    String lng = tappedLocation.longitude.toString();
    try {
      DatabaseEvent event = await _reference.once();
      int count =
          event.snapshot.children.length + 1; // Get existing nodes count
      String locationKey = "location$count"; // Generate dynamic key

      await _reference.child(locationKey).set({
        "Latitude": lat,
        "Longitude": lng,
      });

      print("Location saved as $locationKey");
    } catch (e) {
      print("Error saving location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.user_name);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Icon(Icons.settings_accessibility),
      ),
      body: Stack(children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: LatLng(11.509364, 78.128928),
            zoom: 13,
            onTap: (tapPosition, point) {
              setState(
                () {
                  print("object");
                  _tappedLocation = point;
                  _mapController.moveAndRotate(_tappedLocation!, 13, 0);
                  saveLocation(_tappedLocation);
                  print(_tappedLocation);
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(
                  //     content: Center(
                  //         child: Text(_tappedLocation.toString(),
                  //             style: TextStyle(
                  //               color: Colors.white,
                  //               // fontFamily: "",
                  //               fontSize: 18,
                  //             ))),
                  //     duration: Duration(milliseconds: 1500),
                  //     padding: EdgeInsets.symmetric(vertical: 25),
                  //     backgroundColor: Colors.purpleAccent,
                  //     shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.only(
                  //             topLeft: Radius.circular(20),
                  //             topRight: Radius.circular(20))),
                  //   ),
                  // );
                  state = true;
                },
              );
              // Print the latitude and longitude
              print(
                  'Tapped Location: Latitude = ${point.latitude}, Longitude = ${point.longitude}');
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app', // Required for OSM
            ),
            if (_tappedLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _tappedLocation!,
                    builder: (ctx) =>
                        Icon(Icons.location_pin, color: Colors.red),
                  ),
                ],
              ),
          ],
        ),
        // if (state == true)
        //   Column(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: [
        //       Container(
        //         width: double.infinity,
        //         height: 350,
        //         decoration: BoxDecoration(
        //             color: Color(0xffdcbdf6),
        //             borderRadius: BorderRadius.only(
        //                 topLeft: Radius.circular(30),
        //                 topRight: Radius.circular(30))),
        //       ),
        //     ],
        //   ),
        DraggableScrollableSheet(
          initialChildSize: 0.1, // Initial height (10% of screen)
          minChildSize: 0.1, // Minimum height when dragged down
          maxChildSize: 0.5, // Maximum height when dragged up
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Color(0xffdcbdf6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ListView(
                controller: scrollController, // Enables scrollable content
                padding: EdgeInsets.all(16),
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text(
                    "Location Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  if (_tappedLocation != null)
                    Text(
                      "Latitude: ${_tappedLocation!.latitude.toStringAsFixed(4)}\n"
                      "Longitude: ${_tappedLocation!.longitude.toStringAsFixed(4)}",
                      style: TextStyle(fontSize: 16),
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Add your action here
                    },
                    child: Text("Confirm Location"),
                  ),
                ],
              ),
            );
          },
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // // Action to perform when the FAB is pressed
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('FAB Pressed!')),
          // );
          setState(() {
            _mapController.moveAndRotate(_tappedLocation!, 10, 0);
          });
        },
        // Icon for the FAB
        tooltip: 'Current Location', // Tooltip text
        backgroundColor: Colors.purpleAccent, // Background color of the FAB
        elevation: 6.0,
        child: Icon(Icons.location_searching,
            color: Colors.white70), // Shadow elevation
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // FAB position
    );
  }
}
