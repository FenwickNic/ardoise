import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/business/presentation/presentation_adapter.dart';
import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/model/viewmodel/transactionlist_viewmodel.dart';
import 'package:ardoise/ui/widget/transaction_tile.dart';
import 'package:flutter/cupertino.dart';

class PendingTransactionList extends StatefulWidget {
  final Account account;
  const PendingTransactionList({Key? key, required this.account}) : super(key: key);

  @override
  _PendingTransactionListState createState() => _PendingTransactionListState();
}

class _PendingTransactionListState extends State<PendingTransactionList> {
  FirebaseAdapter _database = FirebaseAdapter();

  //Les transactions qui sont à valider par l'utilisateur
  Future<List<TransactionTileViewModel>>? _pendingTransactionList;

  @override
  void initState() {
    super.initState();

    _pendingTransactionList = PresentationAdapter.fetchPendingTransactionList(widget.account);
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _pendingTransactionList,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(snapshot.hasData && snapshot.data!.length > 0) {
            List<TransactionTileViewModel> transactions = snapshot.data!;
            return ListView.builder(
                padding: EdgeInsets.zero,
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: transactions.length,
                itemBuilder: (builder, index) => TransactionTile(transaction: transactions[index])
            );
          }else{
            return ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
              children:[
                Center(child: Text("Aucune transaction à valider"))
              ]
            );
          }
        }
    );
  }
}