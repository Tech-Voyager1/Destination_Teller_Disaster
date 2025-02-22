import 'package:dis_manag/SignInPages/signIn.dart';
import 'package:dis_manag/mapScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginState extends StatefulWidget {
  final String? user_name;
  const LoginState(this.user_name, {Key? key}) : super(key: key);

  @override
  State<LoginState> createState() => _LoginStateState();
}

class _LoginStateState extends State<LoginState> {
  String? username;

  @override
  void initState() {
    super.initState();
    username =
        widget.user_name ?? "Guest"; // Default value to prevent null issues
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error: Unable to load user data"));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const SignIn();
          }

          // Adding a small delay before navigating
          Future.delayed(Duration(milliseconds: 100), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MapScreen(username)),
            );
          });

          return const Center(
              child:
                  CircularProgressIndicator()); // Show loading until navigation
        },
      ),
    );
  }
}
