import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dis_manag/disaster_data.dart';

class DataScreen extends StatefulWidget {
  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  // const ListScreen({super.key});
  FirebaseService _FirebaseService = FirebaseService();
  List<Map<String, dynamic>> _disasterList = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _FirebaseService.fetchDisasterData();
      setState(() {
        setDisasterList();
        _isLoading = false;
      }); // Rebuild UI after fetching
    });
  }

  // Future<void> _fetchData() async {
  //   _FirebaseService.fetchDisasterData();

  //   setState(() {
  //     setDisasterList();
  //     _isLoading = true;
  //   });
  // }

  void setDisasterList() {
    _disasterList = _FirebaseService.permanentDataList;
    print(_disasterList);
  }

  @override
  Widget build(BuildContext context) {
    print(_isLoading);
    return Scaffold(
      appBar: AppBar(title: Text("Disaster List")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _disasterList.isEmpty
              ? Center(child: Text("No data available"))
              : ListView.builder(
                  itemCount: _disasterList.length,
                  itemBuilder: (context, index) {
                    final item = _disasterList[index];
                    return GestureDetector(
                      onTap: () => _showOptionsDialog(context, item),
                      child: Card(
                        child: ListTile(
                          title: Text("${item['location']}"),
                          subtitle: Text(
                            "Lat: ${item['lat'].toStringAsFixed(6)}, "
                            "Lng: ${item['lng'].toStringAsFixed(6)}, "
                            "Tag: ${item['disastertag']}\n"
                            "Time: ${item['time']}",
                          ),
                          leading: Icon(Icons.warning, color: Colors.red),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showOptionsDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Modification for ${item['location']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Implement update logic here
                },
                child: Text("Update"),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _confirmDelete(context, item);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text("Delete"),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to map screen with this location
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: Text("In Map"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Location: ${item['location']}"),
              Text("Lat: ${item['lat'].toStringAsFixed(6)}"),
              Text("Lng: ${item['lng'].toStringAsFixed(6)}"),
              Text("Disaster Tag: ${item['disastertag']}"),
              SizedBox(height: 10),
              Text(
                "⚠️ Are you sure you want to delete this location?\nThis action cannot be undone!",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                print(item['location']);
                _FirebaseService.deleteLocation(item['location']);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
