import 'package:ardoise/model/viewmodel/transactionlist_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionDetailsViewModel{
  String transactionId;
  String title;
  String description;
  String accountFrom = "";
  String accountTo = "";
  double amount;
  bool requiresValidation;

  TransactionDetailsViewModel({
    this.transactionId = "",
    required this.accountFrom,
    required this.accountTo,
    required this.amount,
    required this.title,
    required this.description,
    this.requiresValidation = false
  });

  factory TransactionDetailsViewModel.fromTransactionTile(TransactionTileViewModel tile){
    return TransactionDetailsViewModel(
      transactionId : tile.transactionId,
      accountFrom:tile.accountFrom,
      accountTo: tile.accountTo,
      amount: tile.amount,
      title: tile.title,
      description: tile.description,
    );
  }
}