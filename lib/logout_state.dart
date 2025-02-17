import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'SignInPages/signIn.dart';

class LogoutState {
  final BuildContext context;
  final String? userEmail;

  LogoutState({required this.context, required this.userEmail});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Logout"),
        content: Text("Choose an option:"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              logoutUser();
            },
            child: Text("Just Logout"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              confirmDeleteUser();
            },
            child: Text("Logout and Delete Data"),
          ),
        ],
      ),
    );
  }

  void logoutUser() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
    );
  }

  void confirmDeleteUser() {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Deletion"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Enter your password to confirm deletion."),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteUserData(passwordController.text);
            },
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Future<void> deleteUserData(String password) async {
    if (userEmail == null) return;

    User? user = _auth.currentUser;

    AuthCredential credential =
        EmailAuthProvider.credential(email: userEmail!, password: password);

    try {
      // Re-authenticate user
      await user!.reauthenticateWithCredential(credential);

      // Remove user data from Firebase Realtime Database
      await _database.ref(userEmail!.replaceAll('.', '_')).remove();

      // Delete user account
      // await user.delete();

      // Sign out the user
      await _auth.signOut();

      // Navigate to the SignIn screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignIn()),
      );
    } catch (e) {
      print("Error deleting user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }
}
