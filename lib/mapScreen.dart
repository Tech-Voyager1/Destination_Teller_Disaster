import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(MapScreen());
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _tappedLocation;
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
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
                print(_tappedLocation);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Center(
                        child: Text(_tappedLocation.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Sans",
                              fontSize: 18,
                            ))),
                    duration: Duration(milliseconds: 1500),
                    padding: EdgeInsets.symmetric(vertical: 25),
                    backgroundColor: Colors.purpleAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                  ),
                );
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
                  builder: (ctx) => Icon(Icons.location_pin, color: Colors.red),
                ),
              ],
            ),
        ],
      ),
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
