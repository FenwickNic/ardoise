import 'package:ardoise/business/presentation/string_adapter.dart';
import 'package:ardoise/ui/widget/pending_transaction_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'account_page_arguments.dart';

class AccountPendingPage extends StatelessWidget {
  final AccountPageArguments arguments;
  const AccountPendingPage({Key? key, required this.arguments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:Text("En attente de validation"),
        ),
        body: Builder(
            builder: (context) =>
                ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: [
                      _buildAccountInfo(context),
                      PendingTransactionList(account: arguments.account),
                    ]
                )
        ));
  }
  Widget _buildAccountInfo(BuildContext context){
    return
      Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top:20, bottom:20),
          child:
          Column(
              children: [
                Text(arguments.account.accountName,
                    style: Theme.of(context).textTheme.bodyText1),
                Text(
                    StringAdapter.formatCurrency(context, arguments.account.balance),
                    style: TextStyle(fontSize: 30, color: Colors.black),
                    textAlign: TextAlign.end
                )
              ]
          ));
  }
}
