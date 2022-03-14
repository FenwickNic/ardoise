import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/business/presentation/string_adapter.dart';
import 'package:ardoise/model/common/app_error.dart';
import 'package:ardoise/model/viewmodel/transactiondetails_viewmodel.dart';
import 'package:ardoise/ui/account/account_page_arguments.dart';
import 'package:flutter/material.dart';

import 'error_snackbar.dart';

class TransactionDetails extends StatelessWidget {
  final TransactionDetailsViewModel transaction;
  const TransactionDetails({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:[
          Card(
              child:
              Padding(
                padding: const EdgeInsets.only(left:50, right: 50, top:20, bottom:20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                    [
                      Text("De", style: Theme.of(context).textTheme.headline5),
                      Text(transaction.accountFrom,
                          style: Theme.of(context).textTheme.bodyText1
                      )
                    ]
                ),
              )
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.arrow_downward,size: 40),
                Text(StringAdapter.formatCurrency(context, transaction.amount), style: Theme.of(context).textTheme.headline3),
              ]
          ),

          Card(
              child:
              Padding(
                padding: const EdgeInsets.only(left:50, right: 50, top:20, bottom:20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children:
                    [
                      Text("À", style: Theme.of(context).textTheme.headline5),
                      Text(transaction.accountTo,
                          style: Theme.of(context).textTheme.bodyText1
                      ),
                    ]
                ),
              )
          ),
          const Divider(),
          Text("Libellé de l'opération" , style: Theme.of(context).textTheme.headline6),
          Text(transaction.title),
          const Divider(),
          Text("Description", style: Theme.of(context).textTheme.headline6),
          Text(transaction.description),
        ]
    );
  }
}
