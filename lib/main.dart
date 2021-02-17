import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_socialmedia_app/sign_in_page.dart';
import 'package:flutter_socialmedia_app/sign_up_page.dart';
import 'main_page.dart';


 main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
   runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      home: firebaseBody(),
    );
  }

  FutureBuilder firebaseBody() {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Scaffold(body: Text("error"),);
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return SignInPage();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Scaffold(body: Center(child: CircularProgressIndicator(),),);
      },
    );
  }
}


