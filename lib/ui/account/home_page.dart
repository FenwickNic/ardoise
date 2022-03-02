import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/model/common/app_error.dart';
import 'package:ardoise/model/firebase/fund_user.dart';
import 'package:ardoise/ui/widget/account_tile.dart';
import 'package:ardoise/ui/widget/app_drawer.dart';
import 'package:ardoise/ui/widget/error_snackbar.dart';
import 'package:ardoise/ui/widget/settings_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'account_page_arguments.dart';

class HomePage extends StatelessWidget {
  final FundUser user;
  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseAdapter database = FirebaseAdapter();

    return Scaffold(
        drawer: AppDrawer(user: user),
        body: ListView(children:[
          SettingsHeader(title: "Mes comptes"),
          FutureBuilder(
              future: database.fetchAccount(user),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                List<Widget> children = [];
                if (snapshot.hasError){
                  if(snapshot.error is AppError){
                    AppError error = (snapshot.error as AppError);
                    if (error.severity == ESeverityLevel.Error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          ErrorSnackBar(error: error));
                          return Container();
                    } else{
                        Navigator.pushNamed(context, '/error', arguments:error);
                    }
                  }
                }
                if (snapshot.hasData) {
                  children = [
                    AccountTile(
                      arguments: AccountPageArguments(
                          user: user, account: snapshot.data
                      ),
                    )
                  ];
                }
                return Column(children: children);
              })]
        )

    );


  }
}
