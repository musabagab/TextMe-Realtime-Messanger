//* all the logic for socket and all the data will be stored.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

import 'package:text_me/models/message.dart';
import 'dart:convert';

import 'package:text_me/models/user.dart';
import 'package:text_me/screens/all_chats_screen.dart';

class ChatModel extends Model {
  List<User> users = List<User>();
  User currentUser = User();
  List<User> friendList = List<User>();
  List<Message> messages = List<Message>();
  SocketIO socketIO;
  FirebaseAuth a;

  bool isLoading = true;

  final controller = ScrollController();

  void init() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();

    currentUser.chatID = user.uid;
    users = await getAllUsers();
    isLoading = false;
    notifyListeners();

    friendList =
        users.where((user) => user.chatID != currentUser.chatID).toList();

    print(friendList.toString());
    // todo put your server url here
    socketIO = SocketIOManager().createSocketIO(
        'https://chat-server-sockets.herokuapp.com/', '/',
        query: 'chatID=${currentUser.chatID}');
    socketIO.init();

    socketIO.subscribe('receive_message', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      messages.add(Message(
          data['content'], data['senderChatID'], data['receiverChatID']));
      notifyListeners(); // update UI
      // Animate the lis to the lastest message
      final animateToPostion = controller.position.maxScrollExtent + 100;

      controller.animateTo(animateToPostion,
          curve: Curves.linear, duration: Duration(milliseconds: 500));
    });

    socketIO.connect();
  }

  void sendMessage(String text, String receiverChatID) {
    messages.add(Message(text, currentUser.chatID, receiverChatID));
    socketIO.sendMessage(
      'send_message',
      json.encode({
        'receiverChatID': receiverChatID,
        'senderChatID': currentUser.chatID,
        'content': text,
      }),
    );
    notifyListeners();

    // Animate the lis to the lastest message
    final animateToPostion = controller.position.maxScrollExtent + 100;

    controller.animateTo(animateToPostion,
        curve: Curves.linear, duration: Duration(milliseconds: 500));
  }

  List<Message> getMessagesForChatID(String chatID) {
    return messages
        .where((msg) => msg.senderID == chatID || msg.receiverID == chatID)
        .toList();
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  final _codeController = TextEditingController();

  Future registerUser(String mobile, BuildContext context, String name) async {
    _auth.verifyPhoneNumber(
        phoneNumber: mobile,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential authCredential) {
          _auth.signInWithCredential(authCredential).then((AuthResult result) {
            final FirebaseUser user = result.user;
            storeUserInfoInFirestore(name, mobile, user.uid);

            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => AllChatsPage()));
          }).catchError((e) {
            print(e);
          });
        },
        verificationFailed: (AuthException authException) {
          print(authException.message);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          //show dialog to take input from the user
          print("Code sent.");

          AuthCredential _credential;
          String smsCode;

          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                    title: Text("Enter SMS Code"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          controller: _codeController,
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Done"),
                        textColor: Colors.white,
                        color: Colors.redAccent,
                        onPressed: () {
                          FirebaseAuth auth = FirebaseAuth.instance;

                          smsCode = _codeController.text.trim();

                          _credential = PhoneAuthProvider.getCredential(
                              verificationId: verificationId, smsCode: smsCode);

                          auth
                              .signInWithCredential(_credential)
                              .then((AuthResult result) {
                            // store user in firestore
                            storeUserInfoInFirestore(
                                name, mobile, result.user.uid);

                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AllChatsPage()));
                          }).catchError((e) {
                            print(e);
                          });
                        },
                      )
                    ],
                  ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
          print(verificationId);
          print("Timout");
        });
  }

  storeUserInfoInFirestore(name, phone, userId) {
    final firestoreInstance = Firestore.instance;

    currentUser = User(name: name, chatID: userId, phoneNumber: phone);

    firestoreInstance.collection("users").add({
      "name": name,
      "phone": phone,
      "userid": userId,
    }).then((value) {
      print(value.documentID);
    });
  }

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

        print(result.data);
      });
    });

    return allUsers;
  }
}
