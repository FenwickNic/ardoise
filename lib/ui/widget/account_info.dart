import 'package:ardoise/business/presentation/string_adapter.dart';
import 'package:ardoise/model/firebase/account.dart';
import 'package:flutter/material.dart';

class AccountInfo extends StatelessWidget {
  final Account account;
  const AccountInfo({Key? key, required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      Container(
          color: Theme.of(context).primaryColor,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(top:20, bottom:20),
          child:
          Column(
              children: [
                Text(account.accountName,
                    style: Theme.of(context).textTheme.headline2),
                Text(
                    StringAdapter.formatCurrency(context, account.balance),
                    style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.end
                ),
              ]
          ));
  }
}
