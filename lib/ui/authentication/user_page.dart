import 'package:ardoise/business/authentication/fire_auth.dart';
import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/model/common/app_error.dart';
import 'package:ardoise/model/firebase/fund_user.dart';
import 'package:ardoise/ui/widget/error_snackbar.dart';
import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  final FundUser user;
  const UserPage({Key? key, required this.user}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final FirebaseAdapter _database = FirebaseAdapter();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstnameTextController = TextEditingController();
  final TextEditingController _lastnameTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firstnameTextController.text = widget.user.firstname;
    _lastnameTextController.text = widget.user.lastname;
    _emailTextController.text = widget.user.email;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Votre utilisateur"),
        ),
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
                          enabled: false,
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
                      InkWell(
                        child: const Text(
                          "Réinitialiser le mot de passe",
                          style: TextStyle(color: Colors.blue),
                          textAlign: TextAlign.center,),
                        onTap: () {
                          try{
                            FireAuth.sendPasswordResetEmail(widget.user.email).then(
                                  (a) =>
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Le message est parti!"))),
                            );
                          }on AppError catch(e){
                            if(e.severity == ESeverityLevel.Error){
                              ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(error: e));
                              return;
                            }else{
                              Navigator.pushNamed(context, '/error', arguments: e);
                            }
                          }catch(e,stack){
                            AppError error = AppError(
                                message: "Erreur",
                                description: e.toString());
                            Navigator.pushNamed(context, '/error', arguments: error);
                          }
                        },
                      ),

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
                              widget.user.email = _emailTextController.text;
                              widget.user.firstname = _firstnameTextController.text;
                              widget.user.lastname = _lastnameTextController.text;
                              try {
                                _database.updateUser(widget.user);
                              }on AppError catch(e){
                                if(e.severity == ESeverityLevel.Error){
                                  ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(error: e));
                                  return;
                                }else{
                                  Navigator.pushNamed(context, '/error', arguments: e);
                                }
                              }catch(e,stack){
                                AppError error = AppError(
                                    message: "Erreur",
                                    description: e.toString());
                                Navigator.pushNamed(context, '/error', arguments: error);
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
