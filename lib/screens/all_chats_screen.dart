import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:text_me/models/user.dart';
import 'package:text_me/scoped_models/app_model.dart';
import 'package:text_me/screens/chat_page.dart';

class AllChatsPage extends StatefulWidget {
  @override
  _AllChatsPageState createState() => _AllChatsPageState();
}

class _AllChatsPageState extends State<AllChatsPage> {
  @override
  void initState() {
    super.initState();
    ScopedModel.of<AppModel>(context, rebuildOnChange: false).init();
  }

  void friendClicked(User friend) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return ChatPage(friend);
        },
      ),
    );
  }

  Widget buildAllChatList() {
    return ScopedModelDescendant<AppModel>(
      builder: (context, child, model) {
        return model.isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: model.friendList.length,
                itemBuilder: (BuildContext context, int index) {
                  User friend = model.friendList[index];
                  print(friend.name);
                  return ListTile(
                    title: Text(friend.name),
                    onTap: () => friendClicked(friend),
                  );
                },
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Chats'),
        automaticallyImplyLeading: false,
      ),
      body: buildAllChatList(),
    );
  }
}
