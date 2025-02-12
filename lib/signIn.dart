import 'package:dis_manag/auth.dart';
import 'package:dis_manag/mapScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String email = "";
  String pass = "";
  bool _obscureText = true;
  final _auth = AuthService();
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xffbe77fb),
      resizeToAvoidBottomInset:
          true, // This automatically resizes when keyboard appears
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.pinkAccent], // Violet shades
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50, left: 20),
                    child: Text(
                      "Hi there ...",
                      style: TextStyle(
                        fontSize: 70,
                        color: Colors.white70,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 500,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 214, 172, 207),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25))),
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 20),
                      child: Text("Sign in",
                          style: TextStyle(
                            color: Colors.brown,
                            fontSize: 28,
                            fontFamily: "Poppins",
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, left: 20),
                      child: Align(
                        // or wrap in a container
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "E-mail",
                          style: TextStyle(
                            color: Colors.brown,
                            fontSize: 28,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.normal,
                          ),
                          //textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20, left: 20),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                            fillColor: Colors.black,
                            hoverColor: Colors.brown,
                            focusColor: Colors.brown,
                            label: Text("Enter e-mail id"),
                            hintText: "Email",
                            //helperText: "xyz@gmail.com",
                            contentPadding:
                                EdgeInsets.only(top: 20, bottom: 20, left: 20),
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            )),
                        validator: (textEditingController) {
                          if (textEditingController != null &&
                              textEditingController.isEmpty) {
                            return "Enter your email id please!";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, left: 20),
                      child: Align(
                        // or wrap in a container
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Password",
                          style: TextStyle(
                            color: Colors.brown,
                            fontSize: 28,
                            fontFamily: "Poppins",
                          ),
                          //textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 20, left: 20, bottom: 20),
                      child: TextFormField(
                          controller: _passController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            fillColor: Colors.black,
                            hoverColor: const Color.fromARGB(255, 233, 62, 0),
                            focusColor: Colors.brown,
                            label: Text("Enter password"),
                            hintText: "Password",

                            //helperText: "xyz@gmail.com",
                            contentPadding:
                                EdgeInsets.only(top: 20, bottom: 20, left: 20),
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText =
                                        !_obscureText; // Toggle password visibility
                                  });
                                }),
                          ),
                          validator: (textEditingController) {
                            if (textEditingController != null &&
                                textEditingController.isEmpty) {
                              return "Enter your password please!";
                            } else {
                              return null;
                            }
                          }),
                    ),
                    MaterialButton(
                      padding: EdgeInsets.only(
                          top: 25, bottom: 25, left: 150, right: 150),
                      onPressed: () {
                        if (!_formkey.currentState!.validate()) {
                          return;
                        }
                        email = _emailController.text.trim();
                        pass = _passController.text.trim();
                        print("$email+$pass");
                        // Future<User?> username =
                        //     _auth.signInUserWithEmailAndPassword(email, pass);
                        // print(username);
                        signInUser(context, email, pass);
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => MapScreen(email)));
                      },
                      color: const Color.fromARGB(255, 92, 13, 81),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: "Poppins",
                          fontSize: 20,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signInUser(
      BuildContext context, String email, String pass) async {
    try {
      User? user = await _auth.signInUserWithEmailAndPassword(email, pass);

      if (user != null) {
        // Successful login
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(email),
          ),
        );
      }
      print(user);
      print(user);
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed. Please try again.";
      print(e.code);
      print(e.code);
      if (e.code == 'user-not-found') {
        errorMessage = "User does not exist. Please sign up.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password. Try again.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement initState
    super.dispose();
    _emailController.dispose();
    _passController.dispose();
  }
}
