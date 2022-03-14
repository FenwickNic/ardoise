import 'package:ardoise/business/authentication/fire_auth.dart';
import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/model/common/app_error.dart';
import 'package:ardoise/model/firebase/fund_user.dart';
import 'package:ardoise/ui/widget/error_snackbar.dart';
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

  String title = "";


  @override
  void initState() {
    if(widget.arguments.user != null){
      _firstnameTextController.text = widget.arguments.user!.firstname;
      _lastnameTextController.text = widget.arguments.user!.lastname;
      _emailTextController.text = widget.arguments.user!.email;
      title = "Éditer un utilisateur";
    }else{
      title = "Créer un utilisateur";
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
                          autocorrect: false,
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
                      const Divider(),
                      TextFormField(
                          autocorrect: false,
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
                      const Divider(),
                      TextFormField(
                          autocorrect: false,
                          controller: _emailTextController,
                          enabled: widget.arguments.user == null,
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
                      if(widget.arguments.user != null)
                      const Divider(),
                      if(widget.arguments.user != null)
                      InkWell(
                        child: const Text(
                          "Envoyer une demande de réinitialisation du mot de passe",
                          style: TextStyle(color: Colors.blue),
                          textAlign: TextAlign.center,),
                        onTap: () {
                          try{
                            FireAuth.sendPasswordResetEmail(widget.arguments.user!.email).then(
                                  (_) => ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Le message est parti!"))
                                  )
                            );
                          }on AppError catch(e){
                            if(e.severity == ESeverityLevel.Error){
                              ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(error: e));
                            }else{
                              Navigator.pushNamed(context, '/error', arguments: e);
                            }
                          }catch(e, stack){
                            AppError error = AppError(
                              message: "Erreur",
                              description: e.toString()
                            );
                            Navigator.pushNamed(context, '/error', arguments: error);
                          }
                        },
                      ),
                      const Divider(),
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
                              if(widget.arguments.user == null){
                                newUser.administrator = false;
                                try {
                                  accountAdapter.createUser(newUser).then(
                                          (value) {
                                        ScaffoldMessenger
                                            .of(context)
                                            .showSnackBar(
                                            SnackBar(content: Text(
                                                "Un message a été envoyé à ${newUser
                                                    .firstname}"))
                                        )
                                            .closed
                                            .then(
                                                (reason) =>
                                                Navigator.pushNamed(
                                                    context, '/admin/users')
                                        );
                                      }
                                  );
                                }on AppError catch(e){
                                  if(e.severity == ESeverityLevel.Error){
                                    ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(error: e));
                                  }else{
                                    Navigator.pushNamed(context, '/error', arguments: e);
                                  }
                                }catch(e, s){
                                  AppError error = AppError(
                                      message: "Erreur",
                                      description: e.toString()
                                  );
                                  Navigator.pushNamed(context, '/error', arguments: error);
                                }
                              }else{
                                newUser.documentId = widget.arguments.user!.documentId;
                                try{
                                accountAdapter.updateUser(newUser).then(
                                        (value) => Navigator.pushNamed(context, '/admin/users')
                                );
                                }on AppError catch(e){
                                  if(e.severity == ESeverityLevel.Error){
                                    ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(error: e));
                                  }else{
                                    Navigator.pushNamed(context, '/error', arguments: e);
                                  }
                                }catch(e, s){
                                  AppError error = AppError(
                                      message: "Erreur",
                                      description: e.toString()
                                  );
                                  Navigator.pushNamed(context, '/error', arguments: error);
                                }
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
