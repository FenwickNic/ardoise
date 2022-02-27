import 'package:ardoise/business/authentication/fire_auth.dart';
import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/business/presentation/presentation_adapter.dart';
import 'package:ardoise/business/presentation/string_adapter.dart';
import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/model/firebase/fund_user.dart';
import 'package:ardoise/model/firebase/transaction.dart';
import 'package:ardoise/model/viewmodel/transactionlist_viewmodel.dart';
import 'package:ardoise/ui/account/account_page_arguments.dart';
import 'package:ardoise/ui/widget/app_drawer.dart';
import 'package:ardoise/ui/widget/transaction_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountPage extends StatefulWidget {
  final String accountId;
  const AccountPage({Key? key, required this.accountId}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  FirebaseAdapter _database = FirebaseAdapter();

  //L'utilisateur connecté
  FundUser? _user;

  //Le compte en banque actuel
  Account? _account;

  //Les transactions que l'utilisateur a soumis et sont en attente de paiement.
  Future<List<FundTransaction>>? _submittedTransactionList;


  @override
  void initState() {
    super.initState();

    //Get the Account as well as the transaction List from the arguments.
    _database.fetchAccountById(widget.accountId)
        .then(
            (value) {
          _submittedTransactionList = _database.fetchSubmittedTransactionList(value);
          setState(() {
            _account = value;
          });
        }).catchError( (error){
    });

    _database.fetchUserById(FirebaseAuth.instance.currentUser!.uid).then(
            (value){
          setState((){
            _user = value;
          });
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer:
        _user == null ?
        null :
        AppDrawer(user: _user!),
        floatingActionButton:
        FloatingActionButton(
            onPressed: () {
              if(_account==null) return;
              Navigator.pushNamed(context,
                  '/transaction/type',
                  arguments: AccountPageArguments(_account!.documentId));
            },
            child: Icon(Icons.add)
        ),
        body:
        Builder(
            builder: (context) =>
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      _buildAccountInfo(),
                      Flexible(
                          child:
                          _account == null ? Container() : PendingTransactionList(account: _account!)),
                      Text('Les opérations courantes',
                          style: Theme.of(context).textTheme.headline5
                      ),
                      Flexible(
                          child: _account == null ? Container() : PaidTransactionList(account: _account!,)
                      )
                    ]
                )
        ));
  }

  Widget _buildHeader(BuildContext context){
    return Container(
        padding: EdgeInsets.only(left:30, right:30, top:50, bottom: 10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bienvenue',
                  style: TextStyle(
                    fontSize: 30,
                  )),
              IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () { Scaffold.of(context).openDrawer(); }
              )
            ])
    );
  }
  Widget _buildAccountInfo(){
    return
      Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top:20, bottom:20),
          child:
          Column(
              children: [
                (_account == null ?
                CircularProgressIndicator() :
                Text(_account!.accountName,
                    style: TextStyle(color: Colors.white))),
                (_account == null ?
                CircularProgressIndicator() :
                Text(
                    StringAdapter.formatCurrency(context, _account!.balance),
                    style: TextStyle(fontSize: 30, color: Colors.white),
                    textAlign: TextAlign.end
                ))
              ]
          ));
  }

}

class PaidTransactionList extends StatefulWidget {
  final Account account;
  const PaidTransactionList({Key? key, required this.account}) : super(key: key);

  @override
  _PaidTransactionListState createState() => _PaidTransactionListState();
}

class _PaidTransactionListState extends State<PaidTransactionList> {
  FirebaseAdapter _database = FirebaseAdapter();

  //Les transactions qui ont été payés
  Future<List<TransactionListViewModel>>? _paidTransactionList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _paidTransactionList = PresentationAdapter.fetchTransactionList(widget.account);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _paidTransactionList,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(snapshot.hasData) {
            List<TransactionListViewModel> data = snapshot.data!;
            if(data.length == 0){
              return ListTile(title: Text('Aucune transaction'));
            }
            return ListView.builder(
              itemCount: data.length,
              padding: EdgeInsets.only(top:20),
              itemBuilder: (builder, index) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Container(
                          padding: EdgeInsets.only(left:20),
                          child:Text(StringAdapter.formatDateLong(context, data[index].date))
                      ),
                      Divider(
                        color: Colors.grey,
                      ),
                      ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: data[index].transactions.length,
                          itemBuilder: (builder, index_transaction) => TransactionTile(transaction: data[index].transactions[index_transaction])
                      )
                    ]);
              },
            );
          }
          else{
            return
              Padding(
                  padding: EdgeInsets.only(left: 20, top: 20),
                  child: Column(

                      children: [
                        TransactionTile(),
                        TransactionTile(),
                        TransactionTile(),
                        TransactionTile(),
                      ]
                  ));
          }
        });
  }
}

class PendingTransactionList extends StatefulWidget {
  final Account account;
  const PendingTransactionList({Key? key, required this.account}) : super(key: key);

  @override
  _PendingTransactionListState createState() => _PendingTransactionListState();
}

class _PendingTransactionListState extends State<PendingTransactionList> {
  FirebaseAdapter _database = FirebaseAdapter();

  //Les transactions qui sont à valider par l'utilisateur
  Future<List<FundTransaction>>? _pendingTransactionList;

  @override
  void initState() {
    super.initState();

    _pendingTransactionList = _database.fetchPendingTransactionList(widget.account);
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _pendingTransactionList,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(snapshot.hasData && snapshot.data!.length > 0) {
            List<FundTransaction> transactions = snapshot.data!;
              return ListView.builder(
                            padding: EdgeInsets.zero,
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: transactions.length,
                            itemBuilder: (builder, index) => TransactionTile(transaction: TransactionTileViewModel(
                              transactionId: transactions[index].documentId,
                              accountTo: transactions[index].accountTo,
                              accountFrom: transactions[index].accountFrom,
                              amount: - transactions[index].amount,
                              title: transactions[index].title,
                              description: transactions[index].description,
                              newBalance: 0,
                              requiresValidation: true
                            ))
                        );
          }else{
            return Container();
          }
        }
    );
  }
}


