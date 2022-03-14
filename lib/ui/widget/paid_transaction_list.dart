import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/business/presentation/presentation_adapter.dart';
import 'package:ardoise/business/presentation/string_adapter.dart';
import 'package:ardoise/model/common/app_error.dart';
import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/model/firebase/fund_user.dart';
import 'package:ardoise/model/viewmodel/transactionlist_viewmodel.dart';
import 'package:ardoise/ui/widget/transaction_tile.dart';
import 'package:ardoise/ui/widget/transaction_tile_mock.dart';
import 'package:flutter/material.dart';

import 'error_snackbar.dart';

class PaidTransactionList extends StatefulWidget {
  final FundUser user;
  final Account account;
  const PaidTransactionList({Key? key, required this.user, required this.account}) : super(key: key);

  @override
  _PaidTransactionListState createState() => _PaidTransactionListState();
}

class _PaidTransactionListState extends State<PaidTransactionList> {
  final FirebaseAdapter _database = FirebaseAdapter();
  //Les transactions qui ont été payés
  Future<List<TransactionListViewModel>>? _paidTransactionList;

  @override
  void initState() {
    super.initState();
    try {
      _paidTransactionList =
          PresentationAdapter.fetchTransactionList(widget.user, widget.account);
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
      Navigator.pushNamed(context, '/error', arguments: error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _paidTransactionList,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(snapshot.hasData) {
            List<TransactionListViewModel> data = snapshot.data!;
            if(data.isEmpty){
              return const
              SizedBox(
                  height: 100,
                  child: Center(
                      child: Text("Aucune transaction")));
            }
            return ListView.builder(
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: data.length,
              padding: const EdgeInsets.only(top:20),
              itemBuilder: (builder, index) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Container(
                          padding: const EdgeInsets.only(left:20),
                          child:Text(StringAdapter.formatDateLong(context, data[index].date))
                      ),
                      const Divider(
                        color: Colors.grey,
                      ),
                      ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: data[index].transactions.length,
                          itemBuilder: (builder, indexTransaction) => TransactionTile(transaction: data[index].transactions[indexTransaction])
                      )
                    ]);
              },
            );
          }
          else{
            return
              Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20),
                  child: Column(
                      children: List.generate(5, (index) => const TransactionTileMock())
                  ));
          }
        });
  }
}