import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel{
  String content;
  String postID;
  String userEmail;
  Timestamp createdAt;
  String ownerName;
  String ownerPictureURL;

  CommentModel(this.content, this.postID, this.userEmail, this.createdAt);

 factory CommentModel.fromDoc(DocumentSnapshot doc){
     return CommentModel(doc["content"], doc["postID"], doc["userEmail"], doc["createdAt"]);
  }
}