//* all the logic for socket and all the data will be stored.

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:text_me/models/message.dart';
import 'dart:convert';

import 'package:text_me/models/user.dart';

class ChatModel extends Model {
  List<User> users = [
    User('IronMan', '111'),
    User('Captain America', '222'),
    User('Antman', '333'),
    User('Hulk', '444'),
    User('Thor', '555'),
  ];

  User currentUser;
  List<User> friendList = List<User>();
  List<Message> messages = List<Message>();
  SocketIO socketIO;

  final controller = ScrollController();

  void init() {
    // todo change it to use authentication
    currentUser = users[1];
    friendList =
        users.where((user) => user.chatID != currentUser.chatID).toList();

    socketIO = SocketIOManager().createSocketIO('YOUR_SEVER_URL_HERE', '/',
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
}
