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
    Color text = Color.fromARGB(255, 0, 0, 0);
    Color submit = Color(0xffe46b10);
    Color textField = Color.fromARGB(255, 213, 212, 219);
    LinearGradient radial = LinearGradient(
      colors: [Color(0xfffbb448), Color.fromARGB(255, 228, 16, 147)],
      stops: [0.0, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Scaffold(
      //backgroundColor: Color(0xffbe77fb),
      resizeToAvoidBottomInset:
          true, // This automatically resizes when keyboard appears
      body: Container(
        decoration: BoxDecoration(
          gradient: radial,
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
                      "TRAVEL ",
                      style: TextStyle(
                        fontSize: 80,
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
                  color: textField,
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
                            color: text,
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
                            color: text,
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
                          //  filled: true,
                          fillColor: Color.fromARGB(255, 223, 213, 213),
                          //hoverColor: Colors.white,
                          focusColor: Colors.brown,
                          label: Text(
                            "Enter e-mail id",
                            style: TextStyle(
                              color: Color(0xFF8B4513),
                            ),
                          ),
                          hintText: "Email",
                          //helperText: "xyz@gmail.com",
                          contentPadding:
                              EdgeInsets.only(top: 20, bottom: 20, left: 20),
                          hintStyle: TextStyle(color: Colors.black54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                                color: Color(0xFF8B4513), // Teal
                                width: 2.0), // Focused border color
                          ),
                        ),
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
                      padding:
                          const EdgeInsets.only(bottom: 20, left: 20, top: 10),
                      child: Align(
                        // or wrap in a container
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Password",
                          style: TextStyle(
                            color: text,
                            fontSize: 28,
                            fontFamily: "Poppins",
                          ),
                          //textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 20, left: 20, bottom: 30),
                      child: TextFormField(
                          controller: _passController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            // focusedBorder: InputBorder.none,
                            fillColor: Colors.black,
                            hoverColor: const Color.fromARGB(255, 233, 62, 0),
                            focusColor: Colors.brown,
                            label: Text(
                              "Enter e-mail id",
                              style: TextStyle(
                                color: Color(0xFF8B4513),
                              ),
                            ),
                            hintText: "Password",

                            //helperText: "xyz@gmail.com",
                            contentPadding:
                                EdgeInsets.only(top: 20, bottom: 20, left: 20),
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                  color: Color(0xFF8B4513), // Teal
                                  width: 2.0), // Focused border color
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
                          top: 20, bottom: 20, left: 130, right: 130),
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
                      color: submit,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          color: text,
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
