import 'package:dis_manag/data_screen.dart';
import 'package:dis_manag/logout_state.dart';
import 'package:flutter/material.dart';

class Drawer_ extends StatelessWidget {
  final String? username;

  const Drawer_({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red, Colors.orangeAccent], // Gradient colors
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(username ?? "User"),
                  accountEmail: Text(username ?? "user@example.com"),
                  decoration: BoxDecoration(
                    color: Color(0),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blue),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.white),
                  title:
                      Text("Settings", style: TextStyle(color: Colors.white)),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.insert_drive_file_outlined,
                      color: Colors.white),
                  title: Text("Data", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DataScreen(username),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Divider(color: Colors.white70), // Optional divider
          ListTile(
            leading:
                Icon(Icons.power_settings_new_outlined, color: Colors.white),
            title: Text("Logout", style: TextStyle(color: Colors.white)),
            onTap: () {
              LogoutState(
                context: context,
                userEmail: username,
              ).showLogoutDialog();
            },
          ),
          SizedBox(height: 20), // Add some spacing at the bottom
        ],
      ),
    );
  }
}
