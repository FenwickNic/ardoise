import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/business/authentication/fire_auth.dart';
import 'package:ardoise/business/validator/email_validator.dart';
import 'package:ardoise/ui/account/account_page_arguments.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
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
  User? user;

  FirebaseAdapter transactionAdapter = FirebaseAdapter();

  @override
  void initState() {
    super.initState();
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
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left:40, right:40),
                height: 200,
                alignment: AlignmentDirectional.bottomCenter,
                child: Image.asset('assets/img/monardoise_logo.png')
              ),
              Expanded(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 40, right: 40),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              TextFormField(
                                  autocorrect: false,
                                  controller: _emailTextController,
                                  decoration: const InputDecoration (
                                    isDense: true,
                                     border: InputBorder.none,
                                     //fillColor: Colors.white10,
                                      filled: true,
                                      hintText: '',
                                      labelText: 'email',
                                  ),
                                  validator: (value) => EmailValidator.vaidate(value)),
                              TextFormField(
                                  obscureText: true,
                                  controller: _passwordTextController,
                                  decoration: const InputDecoration (
                                      isDense: true,
                                      border: InputBorder.none,
                                      filled: true,
                                      hintText: '',
                                      labelText: 'Password'
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Entrez votre mot de passe';
                                    }
                                    return null;
                                  }),

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
                                      User? user = await FireAuth.signInUsingEmailPassword(
                                        email: _emailTextController.text,
                                        password: _passwordTextController.text,
                                        context: context
                                      );
                                      if (user != null) {
                                        transactionAdapter.fetchUserById(user.uid).then(
                                            (value) {
                                              if(value.administrator) {
                                                Navigator.pushNamed(
                                                    context, '/admin/users');
                                              } else{
                                                transactionAdapter.fetchAccount(value).then(
                                                  (account){
                                                    Navigator.pushNamed(context,
                                                      '/home',
                                                      arguments: AccountPageArguments(account.documentId),);
                                                  });
                                              }
                                            }
                                        );
                                      }else{
                                      }
                                    }
                                  }
                              ),
                              //Text('Test'),
                            ])),
                  )),
              Container(
                alignment: AlignmentDirectional.center,
                height: 200,
              )
            ]
        )
    );
  }
}

class _UserInfoCard extends StatefulWidget {
  const _UserInfoCard({Key? key, this.user}) : super(key: key);

  final User? user;

  @override
  _UserInfoCardState createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<_UserInfoCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              alignment: Alignment.center,
              child: const Text(
                'User info',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (widget.user != null)
              if (widget.user!.photoURL != null)
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Image.network(widget.user!.photoURL!),
                )
              else
                Align(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Colors.black,
                    child: const Text(
                      'No image',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            Text(
              widget.user == null
                  ? 'Not signed in'
                  : '${widget.user!.isAnonymous ? 'User is anonymous\n\n' : ''}'
                  'Email: ${widget.user!.email} (verified: ${widget.user!.emailVerified})\n\n'
                  'Phone number: ${widget.user!.phoneNumber}\n\n'
                  'Name: ${widget.user!.displayName}\n\n\n'
                  'ID: ${widget.user!.uid}\n\n'
                  'Tenant ID: ${widget.user!.tenantId}\n\n'
                  'Refresh token: ${widget.user!.refreshToken}\n\n\n'
                  'Created: ${widget.user!.metadata.creationTime.toString()}\n\n'
                  'Last login: ${widget.user!.metadata.lastSignInTime}\n\n',
            ),
            if (widget.user != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.user!.providerData.isEmpty
                        ? 'No providers'
                        : 'Providers:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  for (var provider in widget.user!.providerData)
                    Dismissible(
                      key: Key(provider.uid!),
                      onDismissed: (action) =>
                          widget.user!.unlink(provider.providerId),
                      child: Card(
                        color: Colors.grey[700],
                        child: ListTile(
                          leading: provider.photoURL == null
                              ? IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () =>
                                  widget.user!.unlink(provider.providerId))
                              : Image.network(provider.photoURL!),
                          title: Text(provider.providerId),
                          subtitle: Text(
                              "${provider.uid == null ? "" : "ID: ${provider.uid}\n"}"
                                  "${provider.email == null ? "" : "Email: ${provider.email}\n"}"
                                  "${provider.phoneNumber == null ? "" : "Phone number: ${provider.phoneNumber}\n"}"
                                  "${provider.displayName == null ? "" : "Name: ${provider.displayName}\n"}"),
                        ),
                      ),
                    ),
                ],
              ),
            Visibility(
              visible: widget.user != null,
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () => widget.user!.reload(),
                      icon: const Icon(Icons.refresh),
                    ),
                    IconButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) =>
                            UpdateUserDialog(user: widget.user),
                      ),
                      icon: const Icon(Icons.text_snippet),
                    ),
                    IconButton(
                      onPressed: () => widget.user!.delete(),
                      icon: const Icon(Icons.delete_forever),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateUserDialog extends StatefulWidget {
  const UpdateUserDialog({Key? key, this.user}) : super(key: key);

  final User? user;

  @override
  _UpdateUserDialogState createState() => _UpdateUserDialogState();
}

class _UpdateUserDialogState extends State<UpdateUserDialog> {
  TextEditingController? _nameController;
  TextEditingController? _urlController;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.user!.displayName);
    _urlController = TextEditingController(text: widget.user!.photoURL);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update profile'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            TextFormField(
              controller: _nameController,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'displayName'),
            ),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'photoURL'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              autocorrect: false,
              validator: (String? value) {
                if (value != null && value.isNotEmpty) {
                  var uri = Uri.parse(value);
                  if (uri.isAbsolute) {
                    //You can get the data with dart:io or http and check it here
                    return null;
                  }
                  return 'Faulty URL!';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.user!.updateDisplayName(_nameController!.text);
            widget.user!.updatePhotoURL(_urlController!.text);

            Navigator.of(context).pop();
          },
          child: const Text('Update'),
        )
      ],
    );
  }

  @override
  void dispose() {
    _nameController!.dispose();
    _urlController!.dispose();
    super.dispose();
  }
}