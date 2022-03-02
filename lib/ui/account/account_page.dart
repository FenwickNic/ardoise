import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/business/presentation/string_adapter.dart';
import 'package:ardoise/ui/account/account_page_arguments.dart';
import 'package:ardoise/ui/widget/paid_transaction_list.dart';
import 'package:ardoise/ui/widget/app_drawer.dart';
import 'package:ardoise/ui/widget/settings_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  final AccountPageArguments arguments;
  const AccountPage({Key? key, required this.arguments}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  FirebaseAdapter _database = FirebaseAdapter();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AppDrawer(user: widget.arguments.user),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context,
                  '/transaction/type',
                  arguments: widget.arguments);
            },
            child: Icon(Icons.add)
        ),
        body: Builder(
            builder: (context) =>
                ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: [
                      SettingsHeader(title: "Mon compte"),
                      _buildAccountInfo(),
                      PaidTransactionList(account: widget.arguments.account),
                    ]
                )
        ));
  }
  Widget _buildAccountInfo(){
    return
      Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top:20, bottom:20),
          child:
          Column(
              children: [
                Text(widget.arguments.account.accountName,
                    style: Theme.of(context).textTheme.bodyText1),
                Text(
                    StringAdapter.formatCurrency(context, widget.arguments.account.balance),
                    style: TextStyle(fontSize: 30, color: Colors.black),
                    textAlign: TextAlign.end
                ),
                InkWell(
                    child: Text("Valider les transactions en attente"),
                    onTap: () => Navigator.pushNamed(context, '/account/pending', arguments: widget.arguments)
                ),
              ]
          ));
  }

}


