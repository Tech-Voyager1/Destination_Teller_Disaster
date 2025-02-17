import 'package:dis_manag/SignInPages/signIn.dart';
import 'package:dis_manag/mapScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LoginState extends StatefulWidget {
  final String? user_name;
  const LoginState(this.user_name);

  @override
  State<LoginState> createState() => _LoginStateState();
}

class _LoginStateState extends State<LoginState> {
  String? username;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    username = widget.user_name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error"),
              );
            } else {
              if (snapshot.data == null) {
                return const SignIn();
              } else {
                return MapScreen(username);
              }
            }
          }),
    );
  }
}
