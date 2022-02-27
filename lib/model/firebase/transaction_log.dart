import 'package:cloud_firestore/cloud_firestore.dart';

enum ETransactionAction{
  create,
  validate,
  cancel
}

class TransactionLog{
  /*L'index en base de donnée de ce mouvement.*/
  String documentId;
  /*L'index en base de donnée de la transaction.*/
  String transactionId;
  /*L'index en base de donnée du compte bancaire.*/
  String accountId;
  /*Le montant de la transaction.*/
  double amount;
  /*La date où le virement a été effectué.*/
  DateTime date;
  /*Le montant crédité sur le compte après le virement effectué.*/
  double newBalance;

  TransactionLog({
    this.documentId = "",
    required this.transactionId,
    required this.accountId,
    DateTime? date,
    required this.amount,
    required this.newBalance
  }) : this.date = date ?? DateTime.now();

  Map<String, dynamic> toMap(){
    return {
      'transaction_id': transactionId,
      'account_id': accountId,
      'date': date,
      'amount':amount,
      'new_balance': newBalance
    };
  }

  factory TransactionLog.fromMap(DocumentSnapshot<Map<String, dynamic>> doc){
    Map<String, dynamic>? data = doc.data();

    if(data == null || data.isEmpty){
      throw new Exception("Account not found");
    }

    return TransactionLog(
        documentId: doc.id,
        transactionId: data['transaction_id'],
        accountId: data['account_id'],
        date: DateTime.parse(data['date'].toDate().toString()),
        amount: data['amount'],
        newBalance: data['new_balance']
    );
  }
}