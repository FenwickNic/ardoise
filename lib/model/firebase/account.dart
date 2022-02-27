import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Account{
  /*L'Index du document pour la base de donnée.*/
  String documentId = "";
  /*Le nom du compte pour l'utilisateur.*/
  String accountName = "";
  /* Le propriétaire du compte */
  String userId = "";
  /* Le montant crédité sur le compte.*/
  double balance = 0;
  /*La date de création du compte*/
  DateTime creationDate = DateTime.now();

  Account({
    this.documentId = "",
    required this.accountName,
    required this.userId,
    this.balance = 0,
    creationDate}) : this.creationDate = creationDate ?? DateTime.now();

  Map<String, dynamic> toMap(){
    return{
      'account_name': accountName,
      'user_id': userId,
      'balance': balance,
      'creation_date': creationDate
    };
  }

  factory Account.fromMap(DocumentSnapshot<Map<String, dynamic>> doc){
    Map<String, dynamic>? data = doc.data();

    if(data == null || data.isEmpty){
      throw new Exception("Account not found");
    }
    return Account(
      documentId: doc.id,
      accountName: data['account_name'],
      userId: data['user_id'],
      balance: data['balance'].toDouble(),
      creationDate: DateTime.parse(data['creation_date'].toDate().toString()),
    );
  }

  factory Account.unknown(){
    return Account(
      userId: "",
      accountName: "Inconnu",
      documentId: "",
      balance: 0,
      creationDate: DateTime.now()
    );
  }
}