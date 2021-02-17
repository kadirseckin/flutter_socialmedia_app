import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_socialmedia_app/sign_up_page.dart';

import 'main_page.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String email = "";
  String password = "";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoggedIn=false;
  @override
  void initState() {
    super.initState();
    if(auth.currentUser!=null){
      isLoggedIn=true;
    }
    else{
      isLoggedIn=false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Color textColor = Colors.white;
    var textFontSize = 18.0;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      body: isLoggedIn? MainPage():Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex:1),
            Expanded(child: emailFormField(textColor, textFontSize)),
            Expanded(child:passwordFormField(textColor, textFontSize),),
            Expanded(child:signInButton(size, textFontSize, textColor),),
            Expanded(child:navigateNewAccount(textColor, textFontSize),),
            Spacer(flex:2),
          ],
        ),
      ),
    );
  }

  Padding navigateNewAccount(Color textColor, double textFontSize) {
    return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: GestureDetector(
                onTap: goSignUpPage,
                child: Text(
                  "Create a new account",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: textColor,
                    fontSize: textFontSize,
                  ),
                ),
              ),
            ),
          );
  }

  Padding signInButton(Size size, double textFontSize, Color textColor) {
    return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: FlatButton(
                onPressed: signIn,
                child: Text(
                  "SIGN IN",
                  style: TextStyle(fontSize: textFontSize, color: textColor),
                ),
              ),
            ),
          );
  }

  Padding passwordFormField(Color textColor, double textFontSize) {
    return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: TextFormField(
                obscureText: true, //for unvisible password field
                cursorColor: Colors.orange,
                style: TextStyle(color: textColor, fontSize: textFontSize),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Password',
                  hintStyle: TextStyle(color: textColor),
                  prefixIcon: Icon(Icons.lock),
                ),
                onChanged: (value) {
                  password = value;
                },
              ),
            ),
          );
  }

  Padding emailFormField(Color textColor, double textFontSize) {
    return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: TextFormField(
                cursorColor: Colors.orange,
                style: TextStyle(color: textColor, fontSize: textFontSize),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Email',
                  hintStyle: TextStyle(color: textColor),
                  prefixIcon: Icon(Icons.email),
                ),
                onChanged: (value) {
                  email = value;
                },
              ),
            ),
          );
  }

  void showSnackBar(String error) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(error)));
  }

  Future<void> signIn() async {
    if (email.trim().length == 0 || password.trim().length == 0) {
      String error = "Email and password can't be empty";
      showSnackBar(error);
    } else {
      try {
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        //go main page
        goMainPage();
      } on FirebaseAuthException catch (e) {
        catchSignInExceptions(e);
      } catch (e) {
        print(e);
      }
    }
  }

  void catchSignInExceptions(FirebaseAuthException e) {
     if (e.code == 'user-not-found') {
      print('No user found for that email.');
      String error = "No user found for that email.";
      showSnackBar(error);
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided for that user.');
      String error = "Wrong password provided for that user.";
      showSnackBar(error);
    } else if(e.code=='invalid-email') {
      print("invalid mail");
      String error = "Invalid email.";
      showSnackBar(error);
    }
  }

  void goSignUpPage() {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
        SignUpPage()), (Route<dynamic> route) => false);
  }
  void goMainPage() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainPage()),
            (Route<dynamic> route) => false);

  }
}
