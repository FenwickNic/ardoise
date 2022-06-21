import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/model/firebase/fund_user.dart';
import 'package:ardoise/model/viewmodel/transactionlist_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionDetailsViewModel {
  FundUser user;
  Account currentAccount;

  String transactionId;
  String title;
  String description;
  String accountFrom = "";
  String accountTo = "";
  double amount;
  bool requiresValidation;

  TransactionDetailsViewModel(
      {required this.user,
      required this.currentAccount,
      this.transactionId = "",
      required this.accountFrom,
      required this.accountTo,
      required this.amount,
      required this.title,
      required this.description,
      this.requiresValidation = false});

  factory TransactionDetailsViewModel.fromTransactionTile(TransactionTileViewModel tile) {
    return TransactionDetailsViewModel(
        currentAccount: tile.currentAccount,
        user: tile.user,
        transactionId: tile.transactionId,
        accountFrom: tile.accountFrom,
        accountTo: tile.accountTo,
        amount: tile.amount,
        title: tile.title,
        description: tile.description,
        requiresValidation: tile.requiresValidation);
  }
}
