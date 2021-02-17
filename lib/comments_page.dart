import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:flutter_socialmedia_app/models/post_model.dart';
import 'package:flutter_socialmedia_app/models/user_model.dart';

import 'models/comment_model.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
FirebaseStorage storage = FirebaseStorage.instance;
List<UserModel> users;
List<CommentModel> comments;

class CommentsPage extends StatefulWidget {
  PostModel post;
  CommentsPage(this.post);

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  String comment = "";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Color textIconColor = Colors.white;
  var textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        //app bar divider
        bottom: appBarDivider(),
        title: Text("Comments"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: commentForm(),
          )),
          Expanded(
            flex: 3,
            child: firebaseCommentStreams(),
          ),
        ],
      ),
    );
  }

  StreamBuilder<QuerySnapshot> firebaseCommentStreams() {
    return StreamBuilder<QuerySnapshot>(
        stream: firestore.collection("users").snapshots(),
        builder: (context, snapshotUsers) {
          return StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection("comments")
                .where("postID", isEqualTo: widget.post.postID)
                .orderBy("createdAt", descending: true)
                .snapshots(),
            builder: (context, snapShotComments) {
              if (!snapshotUsers.hasData || !snapShotComments.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                comments = List();
                users = List();
                snapshotUsers.data.docs.forEach((element) {
                  users.add(UserModel.fromDoc(element));
                });
                snapShotComments.data.docs.forEach((element) {
                  comments.add(CommentModel.fromDoc(element));
                });

                for (int i = 0; i < users.length; i++) {
                  for (int j = 0; j < comments.length; j++) {
                    if (users[i].email == comments[j].userEmail) {
                      comments[j].ownerPictureURL = users[i].photoURL;
                      comments[j].ownerName = users[i].name;
                    }
                  }
                }

                return ListView.builder(
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: commentCard(index),
                    );
                  },
                  itemCount: comments.length,
                );
              }
            },
          );
        });
  }

  Card commentCard(int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      color: Colors.grey.shade900,
      elevation: 8,
      child: ListTile(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(comments[index].ownerPictureURL),
            ),
            SizedBox(
              width: 8,
            ),
            Text(comments[index].ownerName,
                style: TextStyle(color: textIconColor)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            comments[index].content,
            style: TextStyle(color: textIconColor, fontSize: 18),
          ),
        ),
      ),
    );
  }

  PreferredSize appBarDivider() {
    return PreferredSize(
      child: Divider(
        color: Colors.grey,
      ),
    );
  }

  Form commentForm() {
    return Form(
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: TextFormField(
                controller: textController,
                maxLines: 4,
                cursorColor: Colors.orange,
                style: TextStyle(color: textIconColor, fontSize: 16),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Comment',
                  hintStyle: TextStyle(color: textIconColor),
                ),
                onChanged: (value) {
                  comment = value;
                },
              ),
            ),
          ),
          Expanded(
              flex: 1,
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: textIconColor,
                ),
                onPressed: addComment,
              )),
        ],
      ),
    );
  }

  OutlineInputBorder textFormFieldBorder(Color textIconColor) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: textIconColor,
      ),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    );
  }

  addComment() {
    if (comment.trim().length != 0) {
      var data = {
        "content": comment,
        "postID": widget.post.postID,
        "createdAt": FieldValue.serverTimestamp(),
        "userEmail": auth.currentUser.email,
      };
      firestore.collection("comments").doc().set(data).whenComplete(() =>
          _scaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text("Your comment has been sent."))));
      textController.clear();
      comment = "";
    } else {
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text("Comment cannot be empty")));
    }
  }
}
