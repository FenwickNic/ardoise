import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/model/firebase/fund_user.dart';

enum ETransactionType{
  Virement,
  Creance,
}

class TransactionTypePageArguments{
  Account account;
  FundUser user;

  TransactionTypePageArguments({
    required this.user,
    required this.account
  });
}

class TransactionAccountPageArguments{
  FundUser user;
  Account account;
  ETransactionType transactionType;

  TransactionAccountPageArguments({
    required this.transactionType,
    required this.account,
    required this.user
  });
}

class TransactionAmountPageArguments {
  FundUser user;

  Account currentAccount;
  ETransactionType transactionType;
  Account accountFrom;
  Account accountTo;

  TransactionAmountPageArguments({
    required this.currentAccount,
    required this.transactionType,
    required this.accountFrom,
    required this.accountTo,
    required this.user
  });
}

class TransactionDescriptionPageArguments {
  FundUser user;
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
    required this.amount,
    required this.user
  });
}

class TransactionPageArguments{
  FundUser user;
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
    required this.user
  });
}