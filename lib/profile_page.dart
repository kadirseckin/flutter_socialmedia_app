import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_socialmedia_app/models/post_model.dart';
import 'package:image_picker/image_picker.dart';
import 'comments_page.dart';
import 'models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
FirebaseStorage storage = FirebaseStorage.instance;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.black,
      child: Column(
        children: [
          profileDetails(),
          Divider(
            color: Colors.grey,
          ),

          //curren user profile images
          Expanded(
            child: profileImagesGrid(),
          ),
        ],
      ),
    );
  }

  profileDetails() {
    return StreamBuilder(
        stream: firestore
            .collection("users")
            .doc(auth.currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          } else {
            user = UserModel.fromDoc(snapshot.data);
            return Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user.photoURL),
                      radius: 50,
                      backgroundColor: Colors.black,
                    ),
                    Positioned(
                      right: -12,
                      bottom: -10,
                      child: IconButton(
                          icon: Icon(
                            Icons.add_photo_alternate_outlined,
                            color: Colors.grey,
                            size: 30,
                          ),
                          onPressed: updateProfilePicture),
                    ),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  user.name,
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ],
            );
          }
        });
  }

  profileImagesGrid() {
    return StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection("posts")
            .orderBy('createdAt', descending: true) //desc true ekle
            .where('userEmail', isEqualTo: auth.currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            List<PostModel> postList = List();
            snapshot.data.docs.forEach((e) {
              postList.add(PostModel.fromDoc(e));
            });

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) {
                return Card(
                  child: GestureDetector(
                    child: Image.network(
                      postList[index].postPhotoURL,
                      fit: BoxFit.fill,
                    ),
                    onTap: () {
                      postList[index].ownerName = user.name;
                      postList[index].ownerProfilePictureURL = user.photoURL;
                      return goCommentsPage(postList[index]);
                    },
                  ),
                );
              },
              itemCount: postList.length,
              scrollDirection: Axis.vertical,
            );
          }
        });
  }

  updateProfilePicture() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);

    //we can use the dateTime.now  as Unique key.
    UploadTask task = storage
        .ref("profilePictures")
        .child(DateTime.now().toString())
        .putFile(File(image.path));
    String url;
    await task.whenComplete(() async {
      url = await task.snapshot.ref.getDownloadURL();
      //update current user photo url
      firestore
          .collection("users")
          .doc(auth.currentUser.email)
          .set({'photoURL': url}, SetOptions(merge: true));
    });
  }

  goCommentsPage(PostModel post) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return CommentsPage(post);
      },
    ));
  }
}
