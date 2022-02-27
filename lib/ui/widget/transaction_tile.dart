import 'package:ardoise/business/presentation/string_adapter.dart';
import 'package:ardoise/model/firebase/transaction_log.dart';
import 'package:ardoise/model/viewmodel/transactionlist_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TransactionTile extends StatelessWidget {
  final TransactionTileViewModel? transaction;
  const TransactionTile({Key? key, this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(transaction == null){
      return
        Shimmer.fromColors(
            baseColor: Colors.grey[350]!,
            highlightColor: Colors.grey[300]!,
            child: Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Row(
              children: [
                CircleAvatar(),
                Padding(
                    padding:EdgeInsets.only(left:30),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height:20,
                            width:100,
                            color: Colors.grey[350],
                          ),Divider(height: 5,),
                          Container(
                              height:20,
                              width:150,
                              color: Colors.grey[350])]))
              ]
            ),
            Container(
                color: Colors.grey[350],
                height: 45,
                width:100
            )
          ]
      )));
    }
    return ListTile(
      onTap: () {
        Navigator.pushNamed(context, '/transaction/details', arguments: transaction);
      },
      title: Text(transaction!.title),
      subtitle: Text(transaction!.isCredit ?
      "de ${transaction!.accountFrom}" :
      "à ${transaction!.accountTo}"),
      leading: CircleAvatar(
        backgroundColor: transaction!.isCredit? Colors.blue : Colors.pink,
        foregroundColor: Colors.white,
        child: Icon(Icons.euro_symbol),),
      trailing: Text(
        StringAdapter.formatCurrency(context, transaction!.amount),
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}