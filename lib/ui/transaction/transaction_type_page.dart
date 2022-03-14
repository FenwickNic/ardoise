import 'package:ardoise/ui/transaction/transaction_page_arguments.dart';
import 'package:flutter/material.dart';

class TransactionTypePage extends StatelessWidget {
  final TransactionTypePageArguments arguments;
  const TransactionTypePage({Key? key, required this.arguments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Opération")
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
                      account: arguments.account,
                      user: arguments.user
                  )),

            ),
            ListTile(
              title: const Text("Demande de Paiement"),
              onTap: () => Navigator.pushNamed(
                  context,
                  '/transaction/account',
                  arguments: TransactionAccountPageArguments(
                      transactionType: ETransactionType.Creance,
                      account: arguments.account,
                      user: arguments.user
                  )
              ),
            )
          ],
        )
    );
  }
}
