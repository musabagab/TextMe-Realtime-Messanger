//* all the logic for socket and all the data will be stored.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

import 'package:text_me/models/message.dart';
import 'dart:convert';

import 'package:text_me/models/user.dart';
import 'package:text_me/scoped_models/authentication_model.dart';
import 'package:text_me/scoped_models/firestore_model.dart';

class AppModel extends Model with AuthenticationModel, FirestoreModel {
  List<User> users = List<User>();
  List<User> friendList = List<User>();
  List<Message> messages = List<Message>();
  SocketIO socketIO;
  final serverUrl =
      'YOUR_SERVER_URL_HERE/'; // TODO use your server link here (download and clone my other repo)
  bool isLoading = true;

  final listController = ScrollController();

  void init() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();

    currentUser.chatID = user.uid;
    users = await getAllUsers();
    isLoading = false;
    notifyListeners();

    friendList =
        users.where((user) => user.chatID != currentUser.chatID).toList();

    prepareSocket();
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
    final animateToPostion = listController.position.maxScrollExtent + 100;

    listController.animateTo(animateToPostion,
        curve: Curves.linear, duration: Duration(milliseconds: 500));
  }

  List<Message> getMessagesForChatID(String chatID) {
    return messages
        .where((msg) => msg.senderID == chatID || msg.receiverID == chatID)
        .toList();
  }

  void prepareSocket() {
    socketIO = SocketIOManager()
        .createSocketIO(serverUrl, '/', query: 'chatID=${currentUser.chatID}');
    socketIO.init();

    socketIO.subscribe('receive_message', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      messages.add(Message(
          data['content'], data['senderChatID'], data['receiverChatID']));
      notifyListeners(); // update UI
      // Animate the lis to the lastest message
      final animateToPostion = listController.position.maxScrollExtent + 100;

      listController.animateTo(animateToPostion,
          curve: Curves.linear, duration: Duration(milliseconds: 500));
    });

    socketIO.connect();
  }
}
