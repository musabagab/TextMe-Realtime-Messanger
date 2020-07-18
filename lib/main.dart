import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:text_me/scoped_models/ChatModel.dart';
import 'package:text_me/screens/all_chats_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: ChatModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AllChatsPage(),
      ),
    );
  }
}
