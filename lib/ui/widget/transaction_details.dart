import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/business/presentation/string_adapter.dart';
import 'package:ardoise/model/common/app_error.dart';
import 'package:ardoise/model/viewmodel/transactiondetails_viewmodel.dart';
import 'package:flutter/cupertino.dart';
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
                padding: EdgeInsets.only(left:50, right: 50, top:20, bottom:20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                    [
                      Text("De", style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.white)),
                      Text(transaction.accountFrom,
                          style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white)
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
                padding: EdgeInsets.only(left:50, right: 50, top:20, bottom:20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children:
                    [
                      Text("À", style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.white)),
                      Text(transaction.accountTo,
                          style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white)
                      ),
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
                        try {
                          _database.validateTransfer(transaction.transactionId);
                        }on AppError catch(e){
                          if(e.severity == ESeverityLevel.Error){
                            ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(error: e));
                            return;
                          }else{
                            Navigator.pushNamed(context, '/error', arguments: e);
                          }
                        }catch(e,s){
                          AppError error = AppError(
                              message: "Erreur",
                              description: e.toString());
                          Navigator.pushNamed(context, '/error', arguments: e);
                        }
                        }
                      ),
                ]
            )
        ]
    );
  }
}
