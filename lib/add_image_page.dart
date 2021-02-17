import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_socialmedia_app/profile_page.dart';
import 'package:image_picker/image_picker.dart';

import 'main_page.dart';

class AddImagePage extends StatelessWidget {
  @override
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () => showAlert(context));
    return Container(
      color: Colors.black,
    );
  }

  void showAlert(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: shareImageFromGallery,
                    child: addImageFromGalleryRow(),
                  ),
                  Divider(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: shareImageFromCamera,
                    child: addImageFormCameraForm(),
                  ),
                  Divider(
                    height: 30,
                  ),
                  RaisedButton(
                    onPressed: () {
                      goHomePage(context);
                    },
                    child: Text("BACK"),
                    color: Colors.red,
                  )
                ],
              ),
            ));
  }

  Row addImageFormCameraForm() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Icon(
          Icons.camera_alt_sharp,
          size: 30,
        ),
        Text(
          "Take a picture",
          style: TextStyle(fontSize: 25),
        ),
      ],
    );
  }

  Row addImageFromGalleryRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Icon(
          Icons.file_upload,
          size: 30,
        ),
        Text(
          "From gallery  ",
          style: TextStyle(fontSize: 25),
        ),
      ],
    );
  }

  void goHomePage(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainPage()),
        (Route<dynamic> route) => false);
  }

  shareImageFromGallery() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);

    //we can use the dateTime.now  as Unique key.
    UploadTask task = storage
        .ref("posts")
        .child(DateTime.now().toString())
        .putFile(File(image.path));
    String url;
    await task.whenComplete(() async {
      url = await task.snapshot.ref.getDownloadURL();
      addPost(url);
    });
  }

  shareImageFromCamera() async {
    var image = await ImagePicker().getImage(source: ImageSource.camera);

    //we can use the dateTime.now  as Unique key.
    UploadTask task = storage
        .ref("posts")
        .child(DateTime.now().toString())
        .putFile(File(image.path));
    String url;
    await task.whenComplete(() async {
      url = await task.snapshot.ref.getDownloadURL();
      addPost(url);
    });
  }

  addPost(String url) {
    String postID = firestore.collection("posts").doc().id;
    var data = {
      'userEmail': auth.currentUser.email,
      'createdAt': FieldValue.serverTimestamp(),
      'postPhotoURL': url,
      'postID': postID
    };
    firestore.collection("posts").doc(postID).set(data);
  }
}
