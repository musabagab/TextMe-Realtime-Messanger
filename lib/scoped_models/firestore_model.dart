import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:text_me/models/user.dart';

mixin FirestoreModel on Model {
  Future<List<User>> getAllUsers() async {
    final firestoreInstance = Firestore.instance;

    List<User> allUsers = List();

    await firestoreInstance
        .collection("users")
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents.forEach((result) {
        allUsers.add(User(
            name: result.data['name'],
            chatID: result.data['userid'],
            phoneNumber: result.data['phone']));
      });
    });

    return allUsers;
  }
}
