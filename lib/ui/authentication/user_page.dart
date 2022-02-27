import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/model/firebase/fund_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  final FundUser user;
  const UserPage({Key? key, required this.user}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  FirebaseAdapter _database = FirebaseAdapter();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstnameTextController = TextEditingController();
  final TextEditingController _lastnameTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Form(
            key: _formKey,
            child: Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      TextFormField(
                          controller: _firstnameTextController,
                          decoration: const InputDecoration (
                              hintText: '',
                              labelText: 'Prénom'
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vous devez renseigner un prénom';
                            }
                            return null;
                          }),
                      TextFormField(
                          controller: _lastnameTextController,
                          decoration: const InputDecoration (
                              hintText: '',
                              labelText: 'Nom'
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vous devez renseigner un nom';
                            }
                            return null;
                          }),
                      TextFormField(
                          controller: _emailTextController,
                          decoration: const InputDecoration (
                              hintText: '',
                              labelText: 'email'
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Renseignez votre email';
                            }
                            return null;
                          }),

                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                          ),

                          child: const Text('Sign in',
                            style: TextStyle(
                                fontSize: 20
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                                widget.user.email = _emailTextController.text;
                                widget.user.firstname = _firstnameTextController.text;
                                widget.user.lastname = _lastnameTextController.text;
                                _database.updateUser(widget.user);
                              }
                            }
                      ),
                    ]
                )
            )
        )
    );
  }
}
