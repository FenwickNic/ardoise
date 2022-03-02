import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/model/common/app_error.dart';
import 'package:ardoise/model/firebase/fund_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'error_snackbar.dart';

class AppDrawer extends StatelessWidget {

  final FundUser user;
  const AppDrawer({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
          children: [
            DrawerHeader(

              decoration: BoxDecoration(
                  color: Colors.blue),
              child: InkWell(
                child: Text(user.fullname,
                    style:Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white)),
                onTap: () {
                  Navigator.pushNamed(context, '/user/details', arguments: user);
                },
              ),
            ),
            if(user.administrator)_adminTiles(context),
            _userTiles(context),
            ListTile(
                title: const Text("Se déconnecter"),
                onTap: () async{
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamed(context, '/');
                }
            )
          ]
      ),
    );
  }
  Widget _adminTiles(BuildContext context) {
    return
      ListTile(
        title: Text("Gérer les utilisateurs"),
        onTap: (){
          Navigator.pushNamed(context, '/admin/users', arguments: user);
        },
      );
  }

  Widget _userTiles(BuildContext context){
    return ListTile(
      title: Text("Gérer ses comptes"),
      onTap: () {
        FirebaseAdapter _database = FirebaseAdapter();
        try {
          _database.fetchAccount(user).then(
                  (account) =>
                  Navigator.pushNamed(context, '/home', arguments: user)
          );
        }on AppError catch(e){
          if(e.severity == ESeverityLevel.Error){
            ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(error: e));
            return;
          }else{
            Navigator.pushNamed(context, '/error', arguments: e);
          }
        }catch(e,s){
          AppError error = AppError(
              message: "Erreur",
              description: e.toString());
          Navigator.pushNamed(context, '/error', arguments: e);
        }
      },
    );
  }
}
