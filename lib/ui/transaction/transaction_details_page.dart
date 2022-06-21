import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/model/common/app_error.dart';
import 'package:ardoise/model/viewmodel/transactiondetails_viewmodel.dart';
import 'package:ardoise/ui/account/account_page_arguments.dart';
import 'package:ardoise/ui/widget/error_snackbar.dart';
import 'package:ardoise/ui/widget/transaction_details.dart';
import 'package:flutter/material.dart';

class TransactionDetailsPage extends StatelessWidget {
  final TransactionDetailsViewModel transaction;

  const TransactionDetailsPage({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Détails"),
        ),
        body: Container(
            child: SingleChildScrollView(
                child: Padding(
                    padding:
                        const EdgeInsets.only(top: 30, left: 20, right: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text("Votre transaction",
                              style: Theme.of(context).textTheme.headline3),
                          const Divider(thickness: 0),
                          TransactionDetails(transaction: transaction),
                          if (transaction.requiresValidation)
                            Divider(
                              height: 40,
                            ),
                          if (transaction.requiresValidation)
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                      ),
                                      child: const Text(
                                        'Refuser',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      onPressed: () async {
                                        FirebaseAdapter _database =
                                            FirebaseAdapter();
                                        _database
                                            .cancelTransfer(
                                                transaction.transactionId)
                                            .then((value) {
                                          Navigator.pushNamed(
                                              context, '/account',
                                              arguments: AccountPageArguments(
                                                  user: transaction.user,
                                                  account: transaction
                                                      .currentAccount
                                                      .documentId));
                                        });
                                      }),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                      ),
                                      child: const Text(
                                        'Accepter',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      onPressed: () async {
                                        FirebaseAdapter _database =
                                            FirebaseAdapter();
                                        try {
                                          _database
                                              .validateTransfer(
                                                  transaction.transactionId)
                                              .then((value) {
                                            Navigator.pushNamed(
                                                context, '/account',
                                                arguments: AccountPageArguments(
                                                    user: transaction.user,
                                                    account: transaction
                                                        .currentAccount
                                                        .documentId));
                                          });
                                        } on AppError catch (e) {
                                          if (e.severity ==
                                              ESeverityLevel.Error) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                    ErrorSnackBar(error: e));
                                            return;
                                          } else {
                                            Navigator.pushNamed(
                                                context, '/error',
                                                arguments: e);
                                          }
                                        } catch (e, s) {
                                          AppError error = AppError(
                                              message: "Erreur",
                                              description: e.toString());
                                          Navigator.pushNamed(context, '/error',
                                              arguments: error);
                                        }
                                      }),
                                ])
                        ])))));
  }
}
