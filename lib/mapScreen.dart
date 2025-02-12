import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  final String user_name;
  const MapScreen(this.user_name);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _tappedLocation;

  bool _isSheetVisible = false;
  late DatabaseReference _reference;
  bool visibility_state = false;
  String disaster = "";
  bool _disaster = false;
  LatLng? _tempMarker; // Temporary marker position
  List<Marker> _permanentMarkers = []; //list of marked disasters
  LatLng _currentLocation = LatLng(0, 0);

  final MapController _mapController = MapController();
  DraggableScrollableController _draggableController =
      DraggableScrollableController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _reference = FirebaseDatabase.instance
        .ref(widget.user_name.replaceAll('.', '_').replaceAll('\$', '_'));
    _draggableController = DraggableScrollableController();
    _fetchAndSetLocation();
  }

  void showSheet() {
    setState(() {
      _isSheetVisible = true; // Make it visible
    });

    Future.delayed(Duration(milliseconds: 100), () {
      _draggableController.animateTo(
        0.7, // Moves to 50% of screen height
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOutQuad,
      );
    });
  }

  void hideSheet() {
    _draggableController
        .animateTo(
      0.1, // Moves back down
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    )
        .then((_) {
      setState(() {
        _isSheetVisible = false; // Hide after animation
      });
    });
  }

  Future<LatLng?> getCurrentLocation() async {
    print("Inside get current location");
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return null;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      return null;
    }

    // Get the current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);
  }

  Future<void> _fetchAndSetLocation() async {
    LatLng? location = await getCurrentLocation();
    if (location != null) {
      setState(() {
        _currentLocation = location; // Assign only inside setState
        print("current-location:  $_currentLocation");
      });
    }
  }

  Future<void> saveLocation(LatLng? tappedLocation, String disaster) async {
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
        "Disaster": disaster,
      });

      print("Location saved as $locationKey");
    } catch (e) {
      print("Error saving location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // showSheet(); //temp
    print(widget.user_name);
    print("Curentlocation is :::::::::::::::::::: $_currentLocation");
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        leading: GestureDetector(
          child: Icon(Icons.density_small_sharp),
          onTap: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.orangeAccent], // Gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color:
                      Colors.transparent, // Keep transparent to show gradient
                ),
                child: Text("DISASTER\nMANAGEMENT",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: "Poppins")),
              ),
              ListTile(
                leading: Icon(Icons.home, color: Colors.white),
                title: Text("Home", style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.white),
                title: Text("Settings", style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading:
                    Icon(Icons.insert_drive_file_outlined, color: Colors.white),
                title: Text("Data", style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),

      body: Stack(children: <Widget>[
        _currentLocation.latitude == 0
            ? Center(child: CircularProgressIndicator())
            : FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _currentLocation,
                  zoom: 13,
                  onTap: (tapPosition, point) {
                    setState(
                      () {
                        print("object");
                        _tappedLocation = point;
                        _mapController.moveAndRotate(_tappedLocation!, 13, 0);

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
                        visibility_state = true;
                        showSheet();
                      },
                    );
                    // Print the latitude and longitude
                    print(
                        'Tapped Location: Latitude = ${point.latitude}, Longitude = ${point.longitude}');
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app', // Required for OSM
                  ),
                  // if (_tappedLocation != null)
                  MarkerLayer(
                    markers: [
                      ..._permanentMarkers, // Show saved disaster markers
                      if (_tappedLocation != null)
                        Marker(
                          point: _tappedLocation!,
                          builder: (ctx) =>
                              Icon(Icons.location_pin, color: Colors.red),
                        )
                      else if (_currentLocation != LatLng(0, 0))
                        Marker(
                          point: _currentLocation!,
                          builder: (ctx) => Icon(Icons.location_pin,
                              color: const Color.fromARGB(255, 54, 216, 244)),
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
        if (_isSheetVisible) dataContainer(),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // // Action to perform when the FAB is pressed
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('FAB Pressed!')),
          // );
          if (_currentLocation.latitude != 0) {
            setState(() {
              _mapController.moveAndRotate(_currentLocation!, 10, 0);
            });
          }
        },
        // Icon for the FAB
        tooltip: 'Current Location', // Tooltip text
        backgroundColor: Colors.orangeAccent, // Background color of the FAB
        elevation: 6.0,
        child: Icon(Icons.location_searching,
            color: Colors.white70), // Shadow elevation
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // FAB position
    );
  }

  Widget dataContainer() {
    print("Inside dataContainer");
    return DraggableScrollableSheet(
      controller: _draggableController,
      initialChildSize: 0.1, // Initial height (10% of screen)
      minChildSize: 0.1, // Minimum height when dragged down
      maxChildSize: 0.8, // Maximum height when dragged up
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
              SizedBox(
                height: 50,
                child: Stack(
                  children: [
                    Center(
                      // Keeps the grey drag handle centered
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 50,
                          height: 5,
                          margin: EdgeInsets.only(bottom: 10), // Space from top
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10, // Aligns close icon to the right
                      top: 0, // Aligns close icon to the top
                      child: IconButton(
                          icon: Icon(Icons.close,
                              color: Colors.black54), // Close button
                          onPressed: () {
                            hideSheet();
                            _disaster = false;
                            disaster = "";
                          } // Calls hideSheet() when tapped
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                "Location Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                ),
              ),
              SizedBox(height: 10),
              if (_tappedLocation != null)
                Text(
                  "Latitude: ${_tappedLocation!.latitude.toStringAsFixed(7)}\n"
                  "Longitude: ${_tappedLocation!.longitude.toStringAsFixed(7)}",
                  style: TextStyle(fontSize: 16, fontFamily: "Poppins"),
                ),
              // Text(
              //   "Latitude: 1234567\n"
              //   "Longitude: 1234567",
              //   style: TextStyle(fontSize: 16, fontFamily: "Poppins"),
              // ),
              SizedBox(height: 20),
              Text(
                "Disaster Tag",
                style: TextStyle(fontSize: 28, fontFamily: "Poppins"),
              ),

              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _disaster ? disasterTag(disaster) : Text("Add.."),
                    ElevatedButton(
                      onPressed: () {
                        permanent_disaster_marker(disaster);
                      },
                      child: Text("Confirm"),
                    )
                  ],
                ),
              ),
              SizedBox(height: 15),
              Container(
                height: 2,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.black45,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _disaster = true;
                          disaster = "Landslide";
                        });
                      },
                      child: Text("Landslide"),
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _disaster = true;
                          disaster = "Earthquake";
                        });
                      },
                      child: Text("Earthquake"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _disaster = true;
                          disaster = "Flood";
                        });
                      },
                      child: Text("Flood"),
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _disaster = true;
                          disaster = "Cyclone";
                        });
                      },
                      child: Text("Cyclone"),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 100,
              ),

              //   ElevatedButton(
              //     onPressed: () {
              //       // Add your action here
              //     },
              //     child: Text("Confirm Location"),
              //   ),
            ],
          ),
        );
      },
    );
  }

  Widget disasterTag(String disaster) {
    return Column(
      children: [
        Container(
          width: 200,
          padding: EdgeInsets.only(left: 20, right: 20, top: 3, bottom: 3),
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(disaster),
              IconButton(
                  onPressed: () {
                    setState(() {
                      _disaster = false;
                    });
                  },
                  icon: Icon(Icons.close)),
            ],
          ),
        ),
      ],
    );
  }

  void permanent_disaster_marker(String disaster) {
    if (_disaster) {
      if (_tappedLocation != null) {
        setState(() {
          _permanentMarkers.add(
            Marker(
              point: _tappedLocation!,
              builder: (ctx) => Image.asset("asset/images/$disaster.png"),
              // New icon
            ),
          );
          // _tempMarker = null; // Clear temp marker
          hideSheet();
          saveLocation(_tappedLocation, disaster);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Center(
              child: Text(
                  "Disaster info added to database\n$disaster at $_tappedLocation\nby ${widget.user_name}"),
            )
                // duration: Duration(milliseconds: 1500),
                // padding: EdgeInsets.symmetric(vertical: 25),
                // backgroundColor: Colors.purpleAccent,
                // shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.only(
                //         topLeft: Radius.circular(20),
                //         topRight: Radius.circular(20))),
                ),
          );
          _disaster = false;
          //disaster = "";
        });
      }
    }
  }
}
