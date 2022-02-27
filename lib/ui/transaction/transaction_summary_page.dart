import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/model/firebase/enum_transaction_status.dart';
import 'package:ardoise/model/firebase/transaction.dart';
import 'package:ardoise/model/viewmodel/transactionlist_viewmodel.dart';
import 'package:ardoise/ui/account/account_page_arguments.dart';
import 'package:ardoise/ui/transaction/transaction_page_arguments.dart';
import 'package:ardoise/ui/widget/transaction_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TransactionSummaryPage extends StatelessWidget {
  final TransactionPageArguments transaction;
  const TransactionSummaryPage({Key? key , required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Confirmer"),
        ),
        body: Padding(
            padding: EdgeInsets.only(top:30, left: 20, right: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Veuillez confirmer votre virement", style: Theme.of(context).textTheme.headline6),
                  Divider(),
                  TransactionDetails(transaction: TransactionTileViewModel(
                      title: transaction.title,
                    amount: transaction.amount,
                    accountFrom: transaction.accountFrom.accountName,
                    accountTo: transaction.accountTo.accountName,
                    description: transaction.description,
                      newBalance: 0
                  )),
                  Divider(height: 30),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                      ),
                      onPressed: () async {
                        FundTransaction fundTransaction = FundTransaction(
                            submittedBy: FirebaseAuth.instance.currentUser!.uid,
                            accountFrom: transaction.accountFrom.documentId,
                            accountTo: transaction.accountTo.documentId,
                            amount: transaction.amount,
                            title: transaction.title,
                            description: transaction.description,
                            type: transaction.transactionType,
                            approvalStatus:
                              transaction.transactionType == ETransactionType.Creance ?
                                ETransactionApprovalStatus.Pending :
                                ETransactionApprovalStatus.Paid,
                        );
                        FirebaseAdapter firebaseAdapter = FirebaseAdapter();
                        firebaseAdapter.transferFunds(fundTransaction).then(
                            (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: const Text('Votre opération est en cours'),
                                  duration: const Duration(seconds: 3),
                                )).closed.then(
                                  (reason) => Navigator.pushNamed(context, '/home', arguments: AccountPageArguments(transaction.currentAccount.documentId))
                              );
                          }
                        );
                        Navigator.pushNamed(
                            context,
                            '/home',
                            arguments: AccountPageArguments(transaction.currentAccount.documentId));
                      },
                      child: Text("Confirmer",
                        style: TextStyle(
                            fontSize: 20
                        ),
                      ))
                ])
        ));
  }
}
