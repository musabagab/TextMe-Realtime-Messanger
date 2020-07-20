import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:text_me/scoped_models/app_model.dart';

class RegisterScreen extends StatelessWidget {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  //Place A
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(builder: (context, child, model) {
      return Scaffold(
          body: Container(
        padding: EdgeInsets.all(32),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Register",
                style: TextStyle(
                    color: Colors.lightBlue,
                    fontSize: 36,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[200])),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[300])),
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: "Phone Number"),
                controller: _phoneController,
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[200])),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[300])),
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: "User Name"),
                controller: _nameController,
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                width: double.infinity,
                child: FlatButton(
                  child: Text("Register"),
                  textColor: Colors.white,
                  padding: EdgeInsets.all(16),
                  onPressed: () {
                    final mobile = _phoneController.text.trim();
                    final name = _nameController.text.trim();
                    model.registerUser(mobile, context, name);
                  },
                  color: Colors.blue,
                ),
              )
            ],
          ),
        ),
      ));
    });
  }
}
