import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:text_me/scoped_models/app_model.dart';
import 'package:text_me/screens/startup_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: AppModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StartUpScreen(),
      ),
    );
  }
}
