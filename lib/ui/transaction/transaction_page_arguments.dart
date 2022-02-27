import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/model/firebase/transaction.dart';

enum ETransactionType{
  Virement,
  Creance,
}

class TransactionAccountPageArguments{
  String accountId;
  ETransactionType transactionType;

  TransactionAccountPageArguments({
      required this.transactionType,
      required this.accountId
  });
}

class TransactionAmountPageArguments {
  Account currentAccount;
  ETransactionType transactionType;
  Account accountFrom;
  Account accountTo;

  TransactionAmountPageArguments({
    required this.currentAccount,
    required this.transactionType,
    required this.accountFrom,
    required this.accountTo,
  });
}

  class TransactionDescriptionPageArguments {
    Account currentAccount;

    ETransactionType transactionType;
    Account accountFrom;
    Account accountTo;
    double amount;

    TransactionDescriptionPageArguments({
      required this.currentAccount,
      required this.transactionType,
      required this.accountFrom,
      required this.accountTo,
      required this.amount
    });
  }

class TransactionPageArguments{
  Account currentAccount;

  ETransactionType transactionType;
  Account accountFrom;
  Account accountTo;
  double amount;
  String title;
  String description;

  TransactionPageArguments({
    required this.currentAccount,
    required this.transactionType,
    required this.accountFrom,
    required this.accountTo,
    required this.amount,
    required this.title ,
    required this.description ,
  });
}