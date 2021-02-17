import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel{
  String postID;
  String userEmail;
  String postPhotoURL;
  String ownerName;
  String ownerProfilePictureURL;
  Timestamp  createdAt;

  PostModel(this.postID, this.userEmail, this.postPhotoURL, this.createdAt);
  factory PostModel.fromDoc(DocumentSnapshot doc){
    return PostModel(doc["postID"], doc["userEmail"], doc["postPhotoURL"], doc["createdAt"]);
  }
}