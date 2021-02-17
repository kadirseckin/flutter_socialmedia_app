import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  String name;
  String photoURL;
  String email;

  UserModel(this.name, this.photoURL, this.email);

  factory UserModel.fromDoc(DocumentSnapshot doc){
    return UserModel(doc['name'],doc['photoURL'],doc['email']);
  }
}