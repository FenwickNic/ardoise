import 'package:ardoise/ui/account/account_page_arguments.dart';
import 'package:ardoise/ui/transaction/transaction_page_arguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TransactionTypePage extends StatelessWidget {
  final String accountId;
  const TransactionTypePage({Key? key, required this.accountId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Opération")
        ),
        body: ListView(
          children: [
            ListTile(
              title: const Text("Virement Immédiat"),
              onTap: () => Navigator.pushNamed(
                  context,
                  '/transaction/account',
                  arguments: TransactionAccountPageArguments(
                      transactionType: ETransactionType.Virement,
                      accountId: accountId)),

            ),
            ListTile(
              title: const Text("Demande de Paiement"),
              onTap: () => Navigator.pushNamed(
                  context,
                  '/transaction/account',
                  arguments: TransactionAccountPageArguments(
                      transactionType: ETransactionType.Creance,
                      accountId: accountId)
              ),
            )
          ],
        )
    );
  }
}
