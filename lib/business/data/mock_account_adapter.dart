import 'package:ardoise/business/data/interface_account.dart';
import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/model/firebase/fund_user.dart';
import 'package:ardoise/model/firebase/transaction.dart';
import 'package:ardoise/model/firebase/transaction_log.dart';

class MockAccountAdapter extends IAccountPort{
  @override
  Future<void> cancelTransfer(FundTransaction transaction) {
    // TODO: implement cancelTransfer
    throw UnimplementedError();
  }

  @override
  Future<void> claimFund(FundTransaction transaction) {
    // TODO: implement claimFund
    throw UnimplementedError();
  }

  @override
  Future<void> createAccount(Account account) {
    // TODO: implement createAccount
    throw UnimplementedError();
  }

  @override
  Future<void> createUser(FundUser user) {
    // TODO: implement createUser
    throw UnimplementedError();
  }

  @override
  Future<Account> fetchAccount(FundUser user) {
    // TODO: implement fetchAccount
    throw UnimplementedError();
  }

  @override
  Future<List<TransactionLog>> fetchPaidTransactionList(Account account) {
    // TODO: implement fetchTransactionList
    throw UnimplementedError();
  }

  @override
  Future<FundUser> fetchUserById(String userId) {
    // TODO: implement fetchUser
    throw UnimplementedError();
  }

  @override
  Future<List<FundUser>> fetchUserList() {
    // TODO: implement fetchUserList
    throw UnimplementedError();
  }

  @override
  List<FundTransaction> searchSimilar(FundTransaction transaction) {
    // TODO: implement searchSimilar
    throw UnimplementedError();
  }

  @override
  List<FundTransaction> searchTransaction(String name, FundUser user_from, FundUser user_to, ETransactionAmountFilter filter, double filter_amount, DateTime date_from, DateTime date_to) {
    // TODO: implement searchTransaction
    throw UnimplementedError();
  }

  @override
  Future<void> transferFunds(FundTransaction transaction) {
    // TODO: implement transferFunds
    throw UnimplementedError();
  }

  @override
  Future<void> updateUser(FundUser user) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }

  @override
  Future<void> validateTransfer(FundTransaction transaction) {
    // TODO: implement validateTransfer
    throw UnimplementedError();
  }

  @override
  Future<FundTransaction> fetchTransaction(TransactionLog transactionLog) {
    // TODO: implement fetchTransaction
    throw UnimplementedError();
  }

  @override
  Future<List<Account>> fetchAccountList() {
    // TODO: implement fetchAccountList
    throw UnimplementedError();
  }

  @override
  Future<List<Account>> searchAccounts(String name) {
    // TODO: implement searchAccounts
    throw UnimplementedError();
  }

  @override
  Future<Account> fetchAccountById(String accountId) {
    // TODO: implement fetchAccountById
    throw UnimplementedError();
  }

}