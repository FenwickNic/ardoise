import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/business/presentation/string_adapter.dart';
import 'package:ardoise/model/viewmodel/transactionlist_viewmodel.dart';
import 'package:ardoise/ui/transaction/transaction_page_arguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TransactionDetails extends StatelessWidget {
  final TransactionTileViewModel transaction;
  const TransactionDetails({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:[
          Card(
              child:
              Padding(
                padding: EdgeInsets.only(left:50, right: 50, top:20, bottom:20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                    [
                      Text("De", style: Theme.of(context).textTheme.headline5),
                      Text(transaction.accountFrom)
                    ]
                ),
              )
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.arrow_downward,size: 40),
                Text(StringAdapter.formatCurrency(context, transaction.amount), style: Theme.of(context).textTheme.headline4),
              ]
          ),

          Card(
              child:
              Padding(
                padding: EdgeInsets.only(left:50, right: 50, top:20, bottom:20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children:
                    [
                      Text("À", style: Theme.of(context).textTheme.headline5),
                      Text(transaction.accountTo)
                    ]
                ),
              )
          ),
          Divider(),
          Text("Libellé de l'opération" , style: Theme.of(context).textTheme.headline6),
          Text(transaction.title),
          Divider(),
          Text("Description", style: Theme.of(context).textTheme.headline6),
          Text(transaction.description),
          if(transaction.requiresValidation)
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                  ),

                  child: const Text('Refuser',
                    style: TextStyle(
                        fontSize: 20
                    ),
                  ),
                  onPressed: () async {
                    FirebaseAdapter _database = FirebaseAdapter();
                    _database.cancelTransfer(transaction.transactionId);
                    }
              ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                  ),

                  child: const Text('Accepter',
                    style: TextStyle(
                        fontSize: 20
                    ),
                  ),
                  onPressed: () async {
                    FirebaseAdapter _database = FirebaseAdapter();
                    _database.validateTransfer(transaction.transactionId);
              }),
              ]
            )
        ]
    );
  }
}
