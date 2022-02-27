import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/ui/transaction/transaction_page_arguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TransactionAccountPage extends StatefulWidget {
  final TransactionAccountPageArguments transaction;
  const TransactionAccountPage({Key? key, required this.transaction}) : super(key: key);

  @override
  _TransactionAccountPageState createState() => _TransactionAccountPageState();
}

class _TransactionAccountPageState extends State<TransactionAccountPage> {
  FirebaseAdapter _database = FirebaseAdapter();

  Account? _account;
  Future<List<Account>>? _accountList;
  String _searchField = "";

  @override
  void initState() {
    _database.fetchAccountById(widget.transaction.accountId).then(
            (value) {
              setState((){
                _account = value;
              });
              _accountList = _database.searchAccounts(_searchField);
            }
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
                decoration: InputDecoration(
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
                        return Center(child: Text("Erreur"));
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
                                                currentAccount: _account!,
                                                transactionType: widget.transaction.transactionType,
                                                accountFrom: _account!,
                                                accountTo: data[index]
                                            ) :
                                            TransactionAmountPageArguments(
                                                currentAccount: _account!,
                                                transactionType: widget.transaction.transactionType,
                                                accountFrom: data[index],
                                                accountTo: _account!,
                                            )

                                        );
                                      },
                                      title: Text(data[index].accountName,
                                      ));
                                },

                          ));
                      }else return CircularProgressIndicator();
                    }

              )
            ]
        )
    );
  }
}
