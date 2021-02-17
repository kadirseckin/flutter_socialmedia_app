import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_socialmedia_app/sign_in_page.dart';

import 'main_page.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String name = "";
  String email = "";
  String password = "";
  String photoURL="https://firebasestorage.googleapis.com/v0/b/socialmediaapp-73e84.appspot.com/o/noneProfilePhoto.png?alt=media&token=9d72e23a-b481-45c1-aa69-3bacc4457965";
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Color textColor = Colors.white;
    var textFontSize = 18.0;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      body: Form(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex:1),
              Expanded(flex:1,child: nameFormField(textColor, textFontSize)),
              Expanded(flex:1,child:emailFormField(textColor, textFontSize),),
              Expanded(flex:1,child:passwordFormField(textColor, textFontSize),),
              Expanded(flex:1,child:signUpButton(size, textFontSize, textColor),),
              Expanded(flex:1,child:navigateSignIn(textColor, textFontSize),) ,
              Spacer(flex:2),
            ],
          ),
        ),
      ),
    );
  }

  Padding navigateSignIn(Color textColor, double textFontSize) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: GestureDetector(
          onTap: goSignInPage,
          child: Text(
            "Already have an account? Sign in",
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

  Padding signUpButton(Size size, double textFontSize, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: size.width * 0.8,
        decoration: BoxDecoration(
          color: Colors.green.shade700,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: FlatButton(
          onPressed: signUp,
          child: Text(
            "SIGN UP",
            style: TextStyle(fontSize: textFontSize, color: textColor),
          ),
        ),
      ),
    );
  }

  Padding passwordFormField(Color textColor, double textFontSize) {
    return Padding(
      padding: const EdgeInsets.all(8),
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
      padding: const EdgeInsets.all(8),
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

  Padding nameFormField(Color textColor, double textFontSize) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
            hintText: 'Name',
            hintStyle: TextStyle(color: textColor),
            prefixIcon: Icon(Icons.assignment_ind_sharp),
          ),
          onChanged: (value) {
            name = value;
          },
        ),
      ),
    );
  }

  Future<void> signUp() async {
    if (email.trim().length == 0 ||
        name.trim().length == 0 ||
        password.trim().length == 0) {
      String error = "Name,email and password cannot be empty";
      showSnackBar(error);
    } else {
      try {
        UserCredential userCredential =
            await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        //add user
        DocumentReference ref = firestore.collection("users").doc(email);
        Map<String, dynamic> map = Map();
        map['email'] = email;
        map['name'] = name;
        map['photoURL'] = photoURL;
        ref.set(map).then((value) => debugPrint("user added : "));

        //and go main page
        goMainPage();
      } on FirebaseAuthException catch (e) {
        catchSignUpExceptions(e);
      } catch (e) {
        print(e);
      }
    }
  }

  void catchSignUpExceptions(FirebaseAuthException e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
      String error = "Password must be at least 6  characters.";
      showSnackBar(error);
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
      String error = "The account already exists for that email.";
      showSnackBar(error);
    } else if (e.code == 'invalid-email') {
      print("invalid mail");
      String error = "Invalid email.";
      showSnackBar(error);
    }
  }

  void showSnackBar(String error) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(error)));
  }

  void goSignInPage() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SignInPage()),
        (Route<dynamic> route) => false);
  }

  void goMainPage() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainPage()),
            (Route<dynamic> route) => false);

  }
}


