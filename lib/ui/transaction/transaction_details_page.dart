import 'package:ardoise/model/viewmodel/transactionlist_viewmodel.dart';
import 'package:ardoise/ui/transaction/transaction_page_arguments.dart';
import 'package:ardoise/ui/widget/transaction_details.dart';
import 'package:flutter/material.dart';

class TransactionDetailsPage extends StatelessWidget {
  final TransactionTileViewModel transaction;
  const TransactionDetailsPage({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Détails"),
        ),
        body: Padding(
            padding: EdgeInsets.only(top:30, left: 20, right: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Votre transaction", style: Theme.of(context).textTheme.headline6),
                  Divider(),
                  TransactionDetails(transaction: transaction)
                ])
        ));
  }
}
