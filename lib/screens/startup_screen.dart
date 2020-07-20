import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:text_me/screens/register_screen.dart';

import 'all_chats_screen.dart';

class StartUpScreen extends StatefulWidget {
  const StartUpScreen({Key key}) : super(key: key);

  @override
  _StartUpScreenState createState() => _StartUpScreenState();
}

class _StartUpScreenState extends State<StartUpScreen> {
  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((currentUser) => {
          if (currentUser != null)
            {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => AllChatsPage()))
            }
          else
            {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => RegisterScreen()))
            }
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Text Me',
            style: TextStyle(
                color: Colors.white, fontSize: 40, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 10,
          ),
          Icon(
            Icons.message,
            size: 50,
            color: Colors.white,
          )
        ],
      )),
    );
  }
}
