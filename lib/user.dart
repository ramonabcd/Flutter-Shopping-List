import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String name;
  String email;
  String id;

  UserModel({this.name, this.email, this.id});

  factory UserModel.fromJson(Map<String, dynamic> parsedJson) {
    return new UserModel(
      name: parsedJson['name'] ?? '',
      email: parsedJson['email'] ?? '',
      id: parsedJson['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'email': this.email,
      'id': this.id,
    };
  }

  static Future<UserModel> getCurrentUser(String uid) async {
    DocumentSnapshot userDocument =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (userDocument != null && userDocument.exists) {
      return UserModel.fromJson(userDocument.data());
    } else {
      return null;
    }
  }

  static Future<UserModel> updateCurrentUser(UserModel user) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(user.id)
        .set(user.toJson())
        .then((value) {
      return user;
    });
  }
}
