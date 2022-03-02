import 'package:ardoise/business/presentation/string_adapter.dart';
import 'package:ardoise/ui/account/account_page_arguments.dart';
import 'package:flutter/material.dart';

class AccountTile extends StatelessWidget {
  final AccountPageArguments arguments;
  const AccountTile({Key? key, required this.arguments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children:[
      InkWell(
        child: Card(
            child: Padding(
                padding: EdgeInsets.only(top:30, bottom: 30, left:10, right: 10),
                child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
              Text(arguments.account.accountName,
                  style: Theme.of(context).textTheme.bodyText1!
                      .copyWith(color: Colors.white)),
              Text(StringAdapter.formatCurrency(context, arguments.account.balance),
              style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white)
              ),
            ]))
        ),
      onTap: (){
          Navigator.pushNamed(context, '/account', arguments: arguments);
      },
    )]
    );
  }
}
