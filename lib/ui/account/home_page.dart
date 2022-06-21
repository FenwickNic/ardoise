import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/model/common/app_error.dart';
import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/model/firebase/fund_user.dart';
import 'package:ardoise/ui/widget/account_tile.dart';
import 'package:ardoise/ui/widget/app_drawer.dart';
import 'package:ardoise/ui/widget/error_snackbar.dart';
import 'package:ardoise/ui/widget/settings_header.dart';
import 'package:flutter/material.dart';

import 'account_page_arguments.dart';

class HomePage extends StatelessWidget {
  final FundUser user;
  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseAdapter database = FirebaseAdapter();

    return Scaffold(
        appBar:
            AppBar(
          toolbarHeight: 100,
          title:
          Padding(
              padding: EdgeInsets.only(top: 10, bottom: 20, left: 10),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                    Text("Mes Comptes",
                      style:
                      Theme.of(context).textTheme.headline1,
                    ),
              Divider(height: 10,color: Colors.transparent,thickness: 0),
              Text("Bienvenue ${user.firstname}",
                style:
                Theme.of(context).textTheme.headline2,
              ),
            ],
          )),
          leading: null,
          actions: [
            Builder(builder: (context) {
              return IconButton(onPressed: () {Scaffold.of(context).openDrawer();}, icon: Icon(Icons.settings));
            })
          ],
          automaticallyImplyLeading: false,
          centerTitle: false
        ),
        drawer: AppDrawer(user: user),
        body: ListView(children:[
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
                          user: user,
                          account: snapshot.data
                      ),
                  ];
                }
                return Column(children: children);
              })]
        )

    );


  }
}
