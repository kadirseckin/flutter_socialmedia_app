import 'package:cloud_firestore/cloud_firestore.dart';

class LikeModel{
  String userEmail;
  String postID;
  String likeID;

  LikeModel(this.userEmail, this.postID, this.likeID);

  factory LikeModel.fromDoc(DocumentSnapshot doc){
    return LikeModel(doc["userEmail"],doc["postID"],doc["likeID"]);
  }
}