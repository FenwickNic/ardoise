import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/ui/transaction/transaction_page_arguments.dart';
import 'package:flutter/material.dart';

class TransactionAccountPage extends StatefulWidget {
  final TransactionAccountPageArguments transaction;
  const TransactionAccountPage({Key? key, required this.transaction}) : super(key: key);

  @override
  _TransactionAccountPageState createState() => _TransactionAccountPageState();
}

class _TransactionAccountPageState extends State<TransactionAccountPage> {
  final FirebaseAdapter _database = FirebaseAdapter();

  Future<List<Account>>? _accountList;
  String _searchField = "";

  @override
  void initState() {
    _accountList = _database.searchAccounts(
        name: _searchField,
        accountToRemove: widget.transaction.account.documentId
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
                widget.transaction.transactionType == ETransactionType.Virement ?
                "Bénéficiaire":
                "Créancier")
        ),
        body: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search)
                ),
                onChanged: (value){
                  //Filter the Accounts.
                  setState(() {
                    _searchField = (
                        value.length >= 3 ? value : "");
                  });
                },
              ),
              FutureBuilder(
                  future: _accountList,
                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
                    if(snapshot.hasError){
                      return const Center(child: Text("Erreur"));
                    }
                    if(snapshot.hasData || snapshot.connectionState == ConnectionState.done) {
                      List<Account> data = snapshot.data!;
                      return Flexible(
                          child: ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (builder, index) {
                              return ListTile(
                                  onTap: () {
                                    Navigator.pushNamed(context,
                                        '/transaction/amount',
                                        arguments:
                                        widget.transaction.transactionType == ETransactionType.Virement ?
                                        TransactionAmountPageArguments(
                                            user: widget.transaction.user,
                                            currentAccount: widget.transaction.account,
                                            transactionType: widget.transaction.transactionType,
                                            accountFrom: widget.transaction.account,
                                            accountTo: data[index]
                                        ) :
                                        TransactionAmountPageArguments(
                                          user: widget.transaction.user,
                                          currentAccount: widget.transaction.account,
                                          transactionType: widget.transaction.transactionType,
                                          accountFrom: data[index],
                                          accountTo: widget.transaction.account,
                                        )

                                    );
                                  },
                                  title: Text(data[index].accountName,
                                  ));
                            },

                          ));
                    }else {
                      return const CircularProgressIndicator();
                    }
                  }

              )
            ]
        )
    );
  }
}
