import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/business/presentation/presentation_adapter.dart';
import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/model/firebase/fund_user.dart';
import 'package:ardoise/model/viewmodel/transactionlist_viewmodel.dart';
import 'package:ardoise/ui/widget/transaction_tile.dart';
import 'package:ardoise/ui/widget/transaction_tile_mock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PendingTransactionList extends StatefulWidget {
  final FundUser user;
  final Account account;

  const PendingTransactionList(
      {Key? key, required this.user, required this.account})
      : super(key: key);

  @override
  _PendingTransactionListState createState() => _PendingTransactionListState();
}

class _PendingTransactionListState extends State<PendingTransactionList> {
  //Les transactions qui sont à valider par l'utilisateur
  Future<List<TransactionTileViewModel>>? _pendingTransactionList;
  FirebaseAdapter _database = FirebaseAdapter();

  @override
  void initState() {
    super.initState();
    _pendingTransactionList = PresentationAdapter.fetchPendingTransactionList(
        widget.user, widget.account);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _pendingTransactionList,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            List<TransactionTileViewModel> transactions = snapshot.data!;
            if (transactions.isEmpty) {
              return const SizedBox(
                  height: 100,
                  child: Center(child: Text("Aucune transaction à valider")));
            }
            return ListView.builder(
                padding: EdgeInsets.zero,
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: transactions.length,
                itemBuilder: (builder, index) =>
                    TransactionTile(transaction: transactions[index]));
          } else {
            return Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: Column(
                    children: List.generate(
                        5, (index) => const TransactionTileMock())));
          }
        });
  }
}
