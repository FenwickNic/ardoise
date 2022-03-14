import 'package:ardoise/business/presentation/string_adapter.dart';
import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/model/firebase/fund_user.dart';
import 'package:ardoise/ui/account/account_page_arguments.dart';
import 'package:flutter/material.dart';

class AccountTile extends StatelessWidget {
  final FundUser user;
  final Account account;
  const AccountTile({Key? key, required this.user, required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
              child: Padding(
                  padding: const EdgeInsets.only(top:20, bottom: 20, left:30, right: 10),
                  child:Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(account.accountName,
                            style: Theme.of(context).textTheme.headline2!.copyWith(fontWeight: FontWeight.bold)),
                        Text(StringAdapter.formatCurrency(context, account.balance),
                            style: Theme.of(context).textTheme.headline2!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)
                        ),
                      ]))
          )]),
      onTap: (){
        Navigator.pushNamed(context, '/account', arguments:
        AccountPageArguments(user: user, account: account.documentId));
      },
    );
  }
}
