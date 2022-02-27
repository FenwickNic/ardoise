import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/model/firebase/fund_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'admin_user_details_arguments.dart';

class AdminUserDetails extends StatefulWidget {
  final AdminUserDetailsArguments arguments;

  const AdminUserDetails({Key? key, required this.arguments}) : super(key: key);

  @override
  createState() => AdminUserDetailsState();

}
class AdminUserDetailsState extends State<AdminUserDetails> {
  final FirebaseAdapter accountAdapter = FirebaseAdapter();

  //Create the Controllers:
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstnameTextController = TextEditingController();
  final TextEditingController _lastnameTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  FundUser? _user;
  String title = "";


  @override
  void initState() {
    _user = widget.arguments.user;
    if(_user != null){
      _firstnameTextController.text = _user!.firstname;
      _lastnameTextController.text = _user!.lastname;
      _emailTextController.text = _user!.email;
      title = "Nouvel utilisateur";
    }else{
      title = "Editer un utilisateur";
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Form(
            key: _formKey,
            child: Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, top: 40),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
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
                              return 'Please enter your first name';
                            }
                            return null;
                          }),
                      Divider(),
                      TextFormField(
                          controller: _lastnameTextController,
                          decoration: const InputDecoration (
                              hintText: '',
                              labelText: 'Nom de famille'
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your last name';
                            }
                            return null;
                          }),
                      Divider(),
                      TextFormField(
                          controller: _emailTextController,
                          decoration: const InputDecoration (
                              hintText: '',
                              labelText: 'email'
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Entrez un email';
                            }
                            return null;
                          }),
Divider(),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                          ),

                          child: const Text('Enregistrer',
                            style: TextStyle(
                                fontSize: 20
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              FundUser newUser = FundUser(
                                firstname: _firstnameTextController.text,
                                lastname: _lastnameTextController.text,
                                email: _emailTextController.text,
                              );
                              if(_user == null){
                                newUser.administrator = false;
                                accountAdapter.createUser(newUser).then(
                                    (value) => Navigator.pushNamed(context, '/admin/users')
                                );
                              }else{
                                newUser.documentId = _user!.documentId;
                                accountAdapter.updateUser(newUser).then(
                                      (value) => Navigator.pushNamed(context, '/admin/users')
                                );
                              }
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
