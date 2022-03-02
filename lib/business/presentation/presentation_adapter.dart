import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/model/firebase/enum_transaction_status.dart';
import 'package:ardoise/model/viewmodel/transactionlist_viewmodel.dart';
import 'package:flutter/material.dart';

class PresentationAdapter{
  static Future<List<TransactionListViewModel>> fetchTransactionList(Account account){
    List<TransactionListViewModel> transactions = [];
    FirebaseAdapter database = FirebaseAdapter();

    return database.fetchPaidTransactionList(account).then(
        (transactionLogs) async {
          List<Account> allAccounts = [];
          await database.fetchAccountList().then(
                  (accounts) => allAccounts = accounts
          );

          //On initialise la date et la liste de Tiles.
          DateTime tempDate = DateTime.now();
          List<TransactionTileViewModel> tileList = [];
          // On récupère le transaction Logs
          for (var transactionLog in transactionLogs)  {
            //On ajoute les Tile dans le cas où la date aurait changée.
            if(tempDate.day != transactionLog.date.day ||
                tempDate.month != transactionLog.date.month ||
                tempDate.year != transactionLog.date.year){
              if(!tileList.isEmpty){
                TransactionListViewModel viewModel = TransactionListViewModel(
                    date: tempDate,
                    transactions: tileList);
                transactions.add(viewModel);
              }
              //On réinitialise les indexes.
              tileList = [];
              tempDate = transactionLog.date;
            }

            //On récupère les informations de la base de donnée.
            await database.fetchTransaction(transactionLog).then(
                    (transaction) {
                      TransactionTileViewModel tile = TransactionTileViewModel
                        (
                          transactionId: transaction.documentId,
                          title: transaction.title,
                          accountFrom: allAccounts.firstWhere((element) {
                             return transaction.accountFrom == element.documentId;
                          }).accountName,
                          accountTo: allAccounts.firstWhere((element) {
                            return transaction.accountTo == element.documentId;
                          }, orElse: () => Account.unknown()).accountName,
                          amount: transactionLog.amount,
                          newBalance: transactionLog.newBalance);
                      tileList.add(tile);
                    });
          }
          if(!tileList.isEmpty){

            TransactionListViewModel viewModel = TransactionListViewModel(
                date: tempDate,
                transactions: tileList);
            transactions.add(viewModel);
          }
          return transactions;
        }
    );
  }

  static Future<List<TransactionTileViewModel>> fetchPendingTransactionList(Account account){
    List<TransactionTileViewModel> transactions = [];
    FirebaseAdapter database = FirebaseAdapter();

    return database.fetchPendingTransactionList(account).then(
        (transactionList) {
          transactionList.forEach((transaction) {
            TransactionTileViewModel transactionViewModel = TransactionTileViewModel(
                title: transaction.title,
                accountFrom: transaction.accountFrom,
                accountTo: transaction.accountTo,
                amount: -transaction.amount,
                description: transaction.description,
                transactionId: transaction.documentId,
                newBalance: account.balance + transaction.amount,
                requiresValidation: (transaction.approvalStatus == ETransactionApprovalStatus.Pending),
            );

            transactions.add(transactionViewModel);
          });
          return transactions;
        }
    );
  }
}