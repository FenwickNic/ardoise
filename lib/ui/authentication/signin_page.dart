import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/business/authentication/fire_auth.dart';
import 'package:ardoise/business/validator/email_validator.dart';
import 'package:ardoise/model/common/app_error.dart';
import 'package:ardoise/ui/widget/error_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Entrypoint example for various sign-in flows with Firebase.
class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();

  FirebaseAdapter transactionAdapter = FirebaseAdapter();

  @override
  void initState(){
    super.initState();

    if(FirebaseAuth.instance.currentUser != null){
      transactionAdapter.fetchUserById(FirebaseAuth.instance.currentUser!.uid)
          .then(
              (value) {
            if (value.administrator) {
              Navigator.pushNamed(
                  context, '/admin/users');
            } else {
              Navigator.pushNamed(context,
                '/home',
                arguments: value,);
            }
          });
    }
  }

  @override
  void dispose(){
    _emailTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded( child: Container(
                      padding: const EdgeInsets.only(left: 40, right: 40, bottom: 60),
                      color: Theme.of(context).colorScheme.primary,
                      height: 200,
                      alignment: AlignmentDirectional.bottomCenter,
                      child: Image.asset('assets/img/ardoise_logo_darkblue.png')
                  )),
                  Form(
                      key: _formKey,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                TextFormField(
                                    autocorrect: false,
                                    controller: _emailTextController,
                                    decoration: const InputDecoration (
                                      hintText: '',
                                      labelText: 'email',
                                      prefixIcon: Icon(Icons.mail),
                                    ),
                                    validator: (value) => EmailValidator.vaidate(value)),
                                const Divider(),
                                TextFormField(
                                    obscureText: true,
                                    controller: _passwordTextController,
                                    decoration: const InputDecoration (
                                      hintText: '',
                                      labelText: 'Password',
                                      prefixIcon: Icon(Icons.vpn_key),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Entrez votre mot de passe';
                                      }
                                      return null;
                                    }),
                                const Divider(),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                    ),
                                    child: const Text('Se connecter',
                                      style: TextStyle(
                                          fontSize: 20
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        User? user;
                                        try {
                                          user = await FireAuth
                                              .signInUsingEmailPassword(
                                            email: _emailTextController.text,
                                            password: _passwordTextController.text,
                                          );
                                        }on AppError catch(e){
                                          if(e.severity == ESeverityLevel.Error){
                                            _passwordTextController.text = "";
                                            ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(error: e));
                                            return;
                                          }else{
                                            Navigator.pushNamed(context, '/error', arguments: e);
                                          }
                                        }catch(e){
                                          AppError error = AppError(
                                              message: "Erreur",
                                              description: e.toString());
                                          Navigator.pushNamed(context, '/error', arguments: error);
                                        }
                                        if (user != null) {
                                          try {
                                            transactionAdapter.fetchUserById(
                                                user.uid).then(
                                                    (value) {
                                                  if (value.administrator) {
                                                    Navigator.pushNamed(
                                                        context, '/admin/users');
                                                  } else {
                                                    Navigator.pushNamed(context,
                                                      '/home',
                                                      arguments: value,);
                                                  }
                                                }
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
                                          //L'utilisateur n'existe pas
                                        }
                                      }
                                    }
                                ),
                                const Divider(),
                                InkWell(
                                  child: const Text(
                                    "J'ai oublié mon mot de passe",
                                    style: TextStyle(color: Colors.blue),
                                    textAlign: TextAlign.center,),
                                  onTap: () {
                                    Navigator.pushNamed(context, '/forgot-email');
                                  },
                                ),//Text('Test'),
                              ]
                          )
                      )
                  ),
                ]
            ))
    );
  }
}