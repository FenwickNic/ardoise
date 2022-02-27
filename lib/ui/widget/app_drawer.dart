import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/model/firebase/fund_user.dart';
import 'package:ardoise/ui/account/account_page_arguments.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {

  final FundUser user;
  const AppDrawer({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
          children: [
            DrawerHeader(
              child: Text(user.fullname),
            ),
            if(user.administrator)_adminTiles(context),
            _userTiles(context),
            ListTile(
                title: const Text("Logout"),
                onTap: () {
                  FirebaseAuth.instance
                      .signOut()
                      .then(
                          (value) => Navigator.pushNamed(context, '/')
                  );
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
        _database.fetchAccount(user).then(
                (account) => Navigator.pushNamed(context, '/home', arguments: AccountPageArguments(account.documentId))
        );
      },
    );
  }
}
