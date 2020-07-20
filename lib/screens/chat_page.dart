import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:text_me/models/message.dart';
import 'package:text_me/models/user.dart';
import 'package:text_me/scoped_models/app_model.dart';

class ChatPage extends StatefulWidget {
  final User friend;
  ChatPage(this.friend);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController textEditingController = TextEditingController();

  Widget buildSingleMessage(Message message) {
    Widget bubble = message.senderID != widget.friend.chatID
        ? ChatBubble(
            clipper: ChatBubbleClipper1(type: BubbleType.sendBubble),
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(top: 20),
            backGroundColor: Colors.blue,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Text(
                message.text,
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        : ChatBubble(
            clipper: ChatBubbleClipper1(type: BubbleType.receiverBubble),
            backGroundColor: Color(0xffE7E7ED),
            margin: EdgeInsets.only(top: 20),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Text(
                message.text,
                style: TextStyle(color: Colors.black),
              ),
            ),
          );

    return bubble;
  }

  Widget buildChatList() {
    return ScopedModelDescendant<AppModel>(
      builder: (context, child, model) {
        List<Message> messages =
            model.getMessagesForChatID(widget.friend.chatID);

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          child: ListView.builder(
            itemCount: messages.length,
            controller: model.listController,
            itemBuilder: (BuildContext context, int index) {
              return buildSingleMessage(messages[index]);
            },
          ),
        );
      },
    );
  }

  Widget buildChatArea() {
    return ScopedModelDescendant<AppModel>(
      builder: (context, child, model) {
        return Container(
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8),
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: textEditingController,
                ),
              ),
              SizedBox(width: 10.0),
              FloatingActionButton(
                onPressed: () {
                  model.sendMessage(
                      textEditingController.text, widget.friend.chatID);
                  textEditingController.text = '';
                },
                elevation: 0,
                child: Icon(Icons.send),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friend.name),
      ),
      body: ListView(
        children: <Widget>[
          buildChatList(),
          buildChatArea(),
        ],
      ),
    );
  }
}
