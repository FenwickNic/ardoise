import 'dart:io';

import 'package:ardoise/model/firebase/transaction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../model/firebase/account.dart';
import 'interface_email.dart';

class FirebaseEmailAdapter extends IEmailPort {
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  FirebaseEmailAdapter();

  @override
  Future<void> sendTransactionConfirmedEmail(FundTransaction transaction) async {
    dynamic data = await this._getData(transaction);
    dynamic template = {
      "name": "transaction-confirmed",
      "data": data
    };
    _database.collection("mail").add(
        {
          "to": "nicolas.fenwick@gmail.com",
          "template": template
        }
    );
  }

  @override
  void sendTransactionPendingEmail(FundTransaction transaction) async {
    dynamic data = await this._getData(transaction);
    dynamic template = {
      "name": "transaction-pending",
      "data": data
    };
    _database.collection("mail").add(
        {
          "to": "nicolas.fenwick@gmail.com",
          "template": template
        }
    );
  }

  void sendTransactionCancelledEmail(FundTransaction transaction) async {
    dynamic data = await this._getData(transaction);
    dynamic template = {
      "name": "transaction-cancelled",
      "data": data
    };
    _database.collection("mail").add(
        {
          "to": "nicolas.fenwick@gmail.com",
          "template": template
        }
    );
  }

  dynamic _getData(FundTransaction transaction) async {
    //On récupère les noms des utilisateurs
    var queries = [
      _database.collection("account").doc(transaction.accountFrom).get(),
      _database.collection("account").doc(transaction.accountTo).get()];
    List<Account> accounts = await Future.wait(queries).then(
            (value) => value.map((json) {
          return Account.fromMap(json);
        }).toList());
    //Formatter l'email
    String amount = NumberFormat.simpleCurrency(
        locale: Platform.localeName,
        name: "€",
        decimalDigits: 2
    ).format(transaction.amount);
    dynamic data = {
      "amount": amount,
      "from": accounts[0].accountName,
      "to": accounts[1].accountName,
      "title": transaction.title,
      "description": transaction.description
    };
    return data;
  }

}