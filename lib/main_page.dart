import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_socialmedia_app/add_image_page.dart';
import 'package:flutter_socialmedia_app/comments_page.dart';
import 'package:flutter_socialmedia_app/models/like_model.dart';
import 'package:flutter_socialmedia_app/models/user_model.dart';
import 'package:flutter_socialmedia_app/profile_page.dart';
import 'package:flutter_socialmedia_app/sign_in_page.dart';
import 'package:flutter_socialmedia_app/sign_up_page.dart';

import 'models/post_model.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
FirebaseStorage storage = FirebaseStorage.instance;

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Size size;
  int _selectedItemIndex = 0;
  Color textIconColor = Colors.white;
  List<LikeModel> likes;
  List<UserModel> users;
  List<PostModel> posts;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        //app bar divider
        bottom: appBarDivider(),
        title: Text("Social Media App"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              icon: Icon(
                Icons.logout,
                color: textIconColor,
              ),
              onPressed: logout)
        ],
      ),
      body: selectedPage(),
      bottomNavigationBar: bottomNavBar(),
    );
  }

  PreferredSize appBarDivider() {
    return PreferredSize(
      child: Divider(
        color: Colors.grey,
      ),
    );
  }

  BottomNavigationBar bottomNavBar() {
    return BottomNavigationBar(
      iconSize: 30,
      selectedFontSize: 15,
      unselectedFontSize: 15,
      unselectedItemColor: textIconColor,
      selectedItemColor: Colors.cyan,
      currentIndex: _selectedItemIndex,
      backgroundColor: Colors.black87.withOpacity(0.7),
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            color: textIconColor,
          ),
          label: "Posts",
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.add_a_photo, color: textIconColor),
            label: "Add image"),
        BottomNavigationBarItem(
            icon: Icon(Icons.assignment_ind, color: textIconColor),
            label: "Profile"),
      ],
      onTap: (value) {
        setState(() {
          _selectedItemIndex = value;
          debugPrint(_selectedItemIndex.toString());
        });
      },
      type: BottomNavigationBarType.fixed,
    );
  }

  Widget postList() {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.all(4),
      child: firebaseStreams(),
    );
  }

  StreamBuilder<QuerySnapshot> firebaseStreams() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection("posts")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snapshotPost) {
        {
          return StreamBuilder<QuerySnapshot>(
            //stream builder for users
            stream: firestore.collection("users").snapshots(),
            builder: (context, snapshotUsers) {
              //stream builder for likes
              return StreamBuilder<QuerySnapshot>(
                stream: firestore.collection("likes").snapshots(),
                builder: (context, snapshotLikes) {
                  if (!snapshotUsers.hasData ||
                      !snapshotPost.hasData ||
                      !snapshotLikes.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    users = List();
                    snapshotUsers.data.docs.forEach((user) {
                      users.add(UserModel.fromDoc(user));
                    });

                    posts = List();
                    snapshotPost.data.docs.forEach((post) {
                      posts.add(PostModel.fromDoc(post));

                      //add userphotourl and user name postList
                      for (int i = 0; i < users.length; i++) {
                        for (int j = 0; j < posts.length; j++) {
                          if (users[i].email == posts[j].userEmail) {
                            posts[j].ownerProfilePictureURL = users[i].photoURL;
                            posts[j].ownerName = users[i].name;
                          }
                        }
                      }
                    });

                    likes = List();
                    snapshotLikes.data.docs.forEach((like) {
                      likes.add(LikeModel.fromDoc(like));
                    });

                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return postCard(index);
                      },
                    );
                  }
                },
              );
            },
          );
        }
      },
    );
  }

  Card postCard(int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      color: Colors.grey.shade900,
      elevation: 8,
      shadowColor: Colors.grey.shade700,
      child: ListTile(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  NetworkImage(posts[index].ownerProfilePictureURL),
            ),
            SizedBox(
              width: 8,
            ),
            Text(posts[index].ownerName,
                style: TextStyle(color: textIconColor)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.all(7.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: size.height * 0.35,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  image: DecorationImage(
                      image: NetworkImage(posts[index].postPhotoURL),
                      scale: 2,
                      fit: BoxFit.cover),
                ),
              ),
              Row(
                children: [
                  IconButton(
                      icon: setIcon(index),
                      onPressed: () {
                        addLike(index);
                      }),
                  Text(
                    "${likesCount(index)}",
                    style: TextStyle(color: textIconColor),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  IconButton(
                      icon: Icon(Icons.insert_comment, color: textIconColor),
                      onPressed: () {
                        return goCommentsPage(posts[index]);
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addLike(int index) {
    if (isLikeExists(index)) {
      for (int i = 0; i < likes.length; i++) {
        if ((likes[i].userEmail == auth.currentUser.email) &&
            (likes[i].postID == posts[index].postID)) {
          //delete like  if already exists

          firestore.collection("likes").doc(likes[i].likeID).delete();
        }
      }
    } else {
      //add like document to firestore
      String likeID = firestore.collection("likes").doc().id;
      var data = {
        'userEmail': auth.currentUser.email,
        'postID': posts[index].postID,
        'likeID': likeID,
      };
      firestore.collection("likes").doc(likeID).set(data);
    }
    //check likes
  }

  Widget selectedPage() {
    if (_selectedItemIndex == 0) {
      return postList();
    } else if (_selectedItemIndex == 1) {
      return AddImagePage();
    } else if (_selectedItemIndex == 2) {
      return ProfilePage();
    }
  }

  Icon setIcon(int index) {
    Icon icon = Icon(
      Icons.favorite_border,
      color: textIconColor,
    );
    for (int i = 0; i < likes.length; i++) {
      if (isLikeExists(index)) {
        icon = Icon(
          Icons.favorite,
          color: Colors.red,
        );
        return icon;
      }
    }
    return icon;
  }

  bool isLikeExists(int index) {
    for (int i = 0; i < likes.length; i++) {
      if ((likes[i].postID == posts[index].postID) &&
          (likes[i].userEmail == auth.currentUser.email)) {
        return true;
      }
    }
    return false;
  }

  likesCount(int index) {
    int count = 0;
    for (int i = 0; i < likes.length; i++) {
      if (likes[i].postID == posts[index].postID) {
        count++;
      }
    }
    return count;
  }

  goCommentsPage(PostModel post) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return CommentsPage(post);
      },
    ));
  }

  logout() {
    auth.signOut().whenComplete(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SignInPage()),
          (Route<dynamic> route) => false);
    });
  }
}
