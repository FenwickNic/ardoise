import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TransactionTileMock extends StatelessWidget {
  const TransactionTileMock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
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
}
