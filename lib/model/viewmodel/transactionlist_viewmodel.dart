import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/model/firebase/enum_transaction_status.dart';
import 'package:ardoise/model/firebase/fund_user.dart';

class TransactionListViewModel{
  DateTime date;
  List<TransactionTileViewModel> transactions;

  TransactionListViewModel({
    required this.date,
    required this.transactions});
}

class TransactionTileViewModel{
  FundUser user;
  Account currentAccount;
  String transactionId;
  String title;
  String description;
  String accountFrom = "";
  String accountTo = "";
  bool isCredit = false;
  double amount;
  double? newBalance;
  bool requiresValidation;

  TransactionTileViewModel(
      {
        required this.user,
        required this.currentAccount,
        this.transactionId = "",
        required this.title,
        this.description = '',
        required this.accountFrom,
        required this.accountTo,
        required this.amount,
        this.newBalance,
        this.requiresValidation = false
      }) : this.isCredit = (amount >= 0);
}