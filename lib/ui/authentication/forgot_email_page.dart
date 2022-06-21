import 'package:ardoise/business/authentication/fire_auth.dart';
import 'package:ardoise/business/validator/email_validator.dart';
import 'package:ardoise/model/common/app_error.dart';
import 'package:ardoise/ui/widget/error_snackbar.dart';
import 'package:flutter/material.dart';

class ForgotEmailPage extends StatelessWidget {
  const ForgotEmailPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    TextEditingController _passwordTextFieldController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: Container(
                    padding: const EdgeInsets.only(left: 40, right: 40, bottom: 60),
                    color: Theme.of(context).colorScheme.primary,
                    height: 200,
                    alignment: AlignmentDirectional.bottomCenter,
                    child: Image.asset('assets/img/ardoise_logo_darkblue.png')
                )
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
                child:Column(
                    children: [
                      TextFormField(
                        autocorrect: false,
                        controller: _passwordTextFieldController,
                        decoration: const InputDecoration(
                          labelText: 'email',
                          prefixIcon: Icon(Icons.mail),
                        ),
                          validator: (value) => EmailValidator.vaidate(value)
                      ),
                      const Divider(thickness: 0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        ),
                        child: const Text('Envoyer un email',
                          style: TextStyle(
                              fontSize: 20
                          ),
                        ),
                        onPressed: () async{
                          try{
                            await FireAuth.sendPasswordResetEmail(_passwordTextFieldController.text);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Un email vous a été envoyé.")))
                                .closed.then((_) => Navigator.pop(context));
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
                    ]
                )
            ),
          ],
        ),
      ),
    );
  }
}
