import 'package:dis_manag/data_screen.dart';
import 'package:dis_manag/disaster_data.dart';
import 'package:dis_manag/drawer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  final String? user_name;
  const MapScreen(this.user_name);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? username;
  LatLng? _tappedLocation;

  bool _isSheetVisible = false;
  late DatabaseReference _reference;
  bool visibility_state = false;
  String disaster = "";
  bool _disaster = false;
  LatLng? _tempMarker; // Temporary marker position
  Set<Marker> _permanentMarkers = {}; //list of marked disasters
  LatLng _currentLocation = LatLng(0, 0);

  final MapController _mapController = MapController();
  DraggableScrollableController _draggableController =
      DraggableScrollableController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseService _FirebaseService = FirebaseService();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    username = widget.user_name!.replaceAll('.', '_').replaceAll('\$', '_');
    _reference = FirebaseDatabase.instance.ref(username!);
    Future.microtask(() async {
      await _FirebaseService.fetchDisasterData(username!);
      setState(() {
        setPermanentMarkers();
      }); // Rebuild UI after fetching
    });
    _draggableController = DraggableScrollableController();
    _fetchAndSetLocation();
  }

  // Future<void> _fetchData() async {
  //   await _FirebaseService
  //       .fetchDisasterData(); // ✅ This now runs asynchronously
  //   setState(() {
  //     setPermanentMarkers();
  //   }); // ✅ Update UI after data loads
  // }

  void setPermanentMarkers() {
    _permanentMarkers = _FirebaseService.permanentMarkers;
    print("Inside setpermanent Markers");
    for (var marker in _FirebaseService.permanentMarkers) {
      print(
          "Latitude: ${marker.point.latitude}, Longitude: ${marker.point.longitude}");
    }
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

  @override
  Widget build(BuildContext context) {
    // showSheet(); //temp
    // _FirebaseService.fetchDisasterData();
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
        child: Drawer_(
          username: username,
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

                  // maxBounds: LatLngBounds(corner1, corner2),
                  maxZoom: 18,
                  minZoom: 4,
                  maxBounds: LatLngBounds(
                    LatLng(
                        6.4627, 68.1097), // Southwest corner (Lower boundary)
                    LatLng(
                        35.5133, 97.3956), // Northeast corner (Upper boundary)
                  ),
                  onTap: (tapPosition, point) {
                    setState(
                      () {
                        print("object");
                        _tappedLocation = point;
                        _mapController.moveAndRotate(_tappedLocation!, 13, 0);

                        print(_tappedLocation);

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
                    maxZoom: 19,
                  ),
                  // if (_tappedLocation != null)
                  MarkerLayer(
                    markers: [
                      ..._permanentMarkers, // Show saved disaster markers
                      if (_tappedLocation != null)
                        Marker(
                          point: _tappedLocation!,
                          builder: (ctx) => Icon(Icons.location_pin,
                              color: const Color.fromARGB(255, 244, 54, 54)),
                        )
                      else if (_currentLocation != LatLng(0, 0))
                        Marker(
                          point: _currentLocation!,
                          builder: (ctx) => Tooltip(
                            message: "Current Location",
                            child: Icon(Icons.location_pin,
                                color: const Color.fromARGB(255, 54, 216, 244)),
                          ),
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

    String _locationName = ""; // Temporary variable to store location name
    String _riskLevel = ""; // Temporary variable to store risk level

    return DraggableScrollableSheet(
      controller: _draggableController,
      initialChildSize: 0.1, // Initial height (10% of screen)
      minChildSize: 0.1, // Minimum height when dragged down
      maxChildSize: 0.8, // Maximum height when dragged up
      builder: (context, scrollController) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                          child: Align(
                            alignment: Alignment.topCenter,
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
                        ),
                        Positioned(
                          right: 10,
                          top: 0,
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.black54),
                            onPressed: () {
                              hideSheet();
                              _disaster = false;
                              disaster = "";
                              _locationController.clear();
                            },
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

                  SizedBox(height: 20),
                  Text(
                    "Disaster Details",
                    style: TextStyle(fontSize: 25, fontFamily: "Poppins"),
                  ),

                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _disaster ? disasterTag(disaster) : Text("Add.."),
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
                  SizedBox(height: 20),

                  // Location Name Input Field
                  Text(
                    "Location Name",
                    style: TextStyle(fontSize: 25, fontFamily: "Poppins"),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: TextField(
                      controller: _locationController,
                      onChanged: (value) {
                        setState(() {
                          _locationName = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Enter the location name",
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Disaster Risk Level Selection
                  Text(
                    "Risk Level",
                    style: TextStyle(fontSize: 22, fontFamily: "Poppins"),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ChoiceChip(
                        label: Text("High"),
                        selected: _riskLevel == "High",
                        selectedColor: Colors.red,
                        backgroundColor: Colors.red.shade100,
                        onSelected: (selected) {
                          setState(() {
                            _riskLevel = selected ? "High" : "";
                          });
                        },
                      ),
                      ChoiceChip(
                        label: Text("Moderate"),
                        selected: _riskLevel == "Moderate",
                        selectedColor: Colors.orange,
                        backgroundColor: Colors.orange.shade100,
                        onSelected: (selected) {
                          setState(() {
                            _riskLevel = selected ? "Moderate" : "";
                          });
                        },
                      ),
                      ChoiceChip(
                        label: Text("Low"),
                        selected: _riskLevel == "Low",
                        selectedColor: Colors.yellow,
                        backgroundColor: Colors.yellow.shade100,
                        onSelected: (selected) {
                          setState(() {
                            _riskLevel = selected ? "Low" : "";
                          });
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Confirm Button (Handles Both Disaster and Location Name)
                  ElevatedButton(
                    onPressed: (_locationName.isEmpty ||
                            disaster.isEmpty ||
                            _riskLevel.isEmpty)
                        ? null
                        : () {
                            print("Location Name: $_locationName");
                            print("Disaster: $disaster");
                            print("Risk Level: $_riskLevel");
                            permanent_disaster_marker(
                                disaster, _locationName, _riskLevel);
                          },
                    child: Text("Confirm"),
                  ),

                  SizedBox(height: 100),
                ],
              ),
            );
          },
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

  void permanent_disaster_marker(
      String disaster, String locationName, String riskLevel) {
    if (_disaster) {
      if (_tappedLocation != null) {
        setState(() {
          _permanentMarkers.add(
            Marker(
              point: _tappedLocation!,
              //builder: (ctx) => Image.asset("asset/images/$disaster.png"),
              builder: (ctx) => Tooltip(
                message: disaster,
                child: Image.asset("asset/images/$disaster.png"),
              ),
              // New icon
            ),
          );
          // _tempMarker = null; // Clear temp marker
          hideSheet();
          saveLocation(_tappedLocation, disaster, locationName, riskLevel);
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

  Future<void> saveLocation(LatLng? tappedLocation, String disaster,
      String locationName, String riskLevel) async {
    if (tappedLocation == null) return;
    String lat = tappedLocation.latitude.toString();
    String lng = tappedLocation.longitude.toString();

    try {
      DatabaseEvent event = await _reference.once();
      //   int count =
      //       event.snapshot.children.length + 1; // Get existing nodes count
      String locationKey = locationName; // Generate dynamic key

      await _reference.child(locationKey).update({
        // "Name": locationName,
        "Latitude": lat,
        "Longitude": lng,
        "Disaster": disaster,
        "Risklevel": riskLevel,
        "Timestamp": ServerValue.timestamp // stores server time
      });

      print("Location saved as $locationKey at ${ServerValue.timestamp}");
    } catch (e) {
      print("Error saving location: $e");
    }
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
}
