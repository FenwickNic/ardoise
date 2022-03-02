import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/business/presentation/presentation_adapter.dart';
import 'package:ardoise/business/presentation/string_adapter.dart';
import 'package:ardoise/model/common/app_error.dart';
import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/model/viewmodel/transactionlist_viewmodel.dart';
import 'package:ardoise/ui/widget/transaction_tile.dart';
import 'package:ardoise/ui/widget/transaction_tile_mock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'error_snackbar.dart';

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
    try {
      _paidTransactionList =
          PresentationAdapter.fetchTransactionList(widget.account);
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
      Navigator.pushNamed(context, '/error', arguments: e);
    }
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
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
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
                      children: List.generate(5, (index) => TransactionTileMock())
                  ));
          }
        });
  }
}