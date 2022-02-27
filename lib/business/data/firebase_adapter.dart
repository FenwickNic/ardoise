import 'package:ardoise/business/data/interface_account.dart';
import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/model/firebase/enum_transaction_status.dart';
import 'package:ardoise/model/firebase/transaction.dart';

import 'package:ardoise/model/firebase/fund_user.dart';
import 'package:ardoise/model/firebase/transaction_log.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAdapter extends IAccountPort{

  FirebaseFirestore _database = FirebaseFirestore.instance;
  FirebaseAdapter();

  /***
   * TRANSACTIONS
   */
  @override
  Future<void> validateTransfer(FundTransaction transaction) {
    // TODO: implement validateTransfer
    throw UnimplementedError();
    //Mettre à jour la transaction en base de donnée,

    //Mettre à jour le crédit des 2 comptes,

    //Ajouter une ligne dans le transaction log.
  }

  @override
  Future<void> transferFunds(FundTransaction transaction) async{
    //Créer la transaction en base de donnée,
    DocumentReference transRef = await _database.collection('transaction').add(transaction.toMap());

    //Débiter le compte bancaire du créancier
    DocumentReference account_from =
      _database.collection('account')
        .doc(transaction.accountFrom);
    //Mettre à jour le crédit sur le compte débiteur et créer le transaction Log attaché:
    FirebaseFirestore.instance.runTransaction((fireTransaction) async {
      DocumentSnapshot snapshot_from = await fireTransaction.get(account_from);

      if (!snapshot_from.exists) {
        throw Exception("This account does not exist");
      }
      double newBalance_from = snapshot_from.data()['balance'] - transaction.amount;
      fireTransaction.update(account_from, {'balance': newBalance_from});

      return newBalance_from;
    }).then(
        (newBalance){
          TransactionLog log_from =TransactionLog(
              transactionId: transRef.id,
              accountId: transaction.accountFrom,
              amount: -transaction.amount,
              newBalance: newBalance);
          _database.collection('transaction_log').add(log_from.toMap());
        }
    );

    //Mettre à jour le crédit sur le compte créditeur et créer le transaction Log attaché:
    DocumentReference account_to =
    _database.collection('account')
        .doc(transaction.accountTo);
    //Mettre à jour le crédit sur le compte débiteur et créer le transaction Log attaché:
    FirebaseFirestore.instance.runTransaction((fireTransaction) async {
      DocumentSnapshot snapshot_to = await fireTransaction.get(account_to);

      if (!snapshot_to.exists) {
        throw Exception("This account does not exist");
      }
      double newBalance_to = snapshot_to.data()['balance'] + transaction.amount;
      fireTransaction.update(account_to, {'balance': newBalance_to});

      return newBalance_to;
    }).then(
            (newBalance){
          TransactionLog log_from =TransactionLog(
              transactionId: transRef.id,
              accountId: transaction.accountTo,
              amount: transaction.amount,
              newBalance: newBalance);
          _database.collection('transaction_log').add(log_from.toMap());
        }
    );
  }

  @override
  Future<void> cancelTransfer(FundTransaction transaction) {
    // TODO: implement cancelTransfer
    throw UnimplementedError();
    //Mettre à jour la transaction en base de donnée

    //Ajouter un champ au transaction log.
  }

  @override
  Future<void> claimFund(FundTransaction transaction) {
    // TODO: implement claimFund
    throw UnimplementedError();

    //Créer la transaction en base de donnée.

    //Ajouter un éléement au transaction log.
  }

  @override
  Future<List<TransactionLog>> fetchPaidTransactionList(Account account) {
    //Récupérer toutes les transactions rattachées au compte.
    return _database.collection("transaction_log")
        .orderBy('date', descending: true)
        .where('account_id', isEqualTo: account.documentId)
        .get().then(
            (value) {
          return value.docs.map(
                  (map) => TransactionLog.fromMap(map)).toList();
        });
  }

  @override
  Future<List<FundTransaction>> fetchPendingTransactionList(Account account) {
    //Récupérer toutes les transactions rattachées au compte.
    return _database.collection("transaction")
        .orderBy('date', descending: true)
        .where('account_from', isEqualTo: account.documentId)
        .where('approval_status', isEqualTo: ETransactionApprovalStatus.Pending.index)
        .get().then(
            (value) {
          return value.docs.map((map) => FundTransaction.fromMap(map)).toList();
        });
  }

  @override
  Future<List<FundTransaction>> fetchSubmittedTransactionList(Account account) {
    //Récupérer toutes les transactions rattachées au compte.
    return _database.collection("transaction")
        .orderBy('date', descending: true)
        .where('account_to', isEqualTo: account.documentId)
        .where('approval_status', isEqualTo: ETransactionApprovalStatus.Pending.index)
        .get().then(
            (value) {
          return value.docs.map((map) => FundTransaction.fromMap(map)).toList();
        });
  }

  @override
  Future<FundTransaction> fetchTransaction(TransactionLog transactionLog){
    return _database
        .collection("transaction")
        .doc(transactionLog.transactionId)
        .get()
        .then((transaction) => FundTransaction.fromMap(transaction));
  }

  @override
  List<FundTransaction> searchSimilar(FundTransaction transaction) {
    // TODO: implement searchSimilar
    throw UnimplementedError();
    //Filtrer la liste des transactions.
  }

  @override
  List<FundTransaction> searchTransaction(String name, FundUser user_from, FundUser user_to, ETransactionAmountFilter filter, double filter_amount, DateTime date_from, DateTime date_to) {
    // TODO: implement searchTransaction
    throw UnimplementedError();

    //Filtrer la liste des transactions.

  }


  /***
   * ACCOUNTS
   */
  @override
  Future<void> createAccount(Account account) async{
    await _database
        .collection('account')
        .add(account.toMap())
        .catchError(
            (error) => print("Failed to create account: $error")
    );
  }

  @override
  Future<Account> fetchAccount(FundUser user) {
    return _database.collection('account')
        .where(
        'user_id',
        isEqualTo: user.documentId)
        .get().then(
            (value) => Account.fromMap(value.docs.first)
    );
  }

  @override
  Future<List<Account>> fetchAccountList() {
    return _database.collection('account').get().then(
            (value) =>
            (value.docs.map(
                    (account) =>
                    Account.fromMap(account)
            )
            ).toList()
    );
  }

  @override
  Future<List<Account>> searchAccounts(String? name) async {
    return fetchAccountList().then((accounts) {
      if(name== null || name.isEmpty) return accounts;
      List<Account> filteredList = [];
      for (Account account in accounts) {
        if (account.accountName.toLowerCase().contains(name.toLowerCase())) {
          filteredList.add(account);
        }
      }
      print(filteredList.length);
      return filteredList;
    });
  }

  @override
  Future<Account> fetchAccountById(String accountId) {
    return _database.collection('account').doc(accountId).get().then(
            (value) => Account.fromMap(value)
    );
  }

  /***
   * USERS
   */
  @override
  Future<void> createUser(FundUser user) async {
    //Créer un utilisateur dans le moteur d'authentification.
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: user.email,
          password: "test123"
      ).then((value) => user.documentId = value.user!.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    //Créer un utilisateur en base de donnée
    await _database.collection('user')
        .doc(user.documentId)
        .set(user.toMap())
        .then((value) {
      //Créer un compte pour cet utilisateur.
      Account account = Account(
        accountName: user.fullname,
        userId:user.documentId,
        creationDate: DateTime.now(),
      );
      _database.collection('account').add(account.toMap())
          .catchError((error) => print("Failed to create account: $error"));
      ;
    }).catchError((error) => print("Failed to add user: $error"));;
  }

  @override
  Future<FundUser> fetchUserById(String userId) {
    return _database.collection("user").doc(userId).get().then(
            (value) => FundUser.fromMap(value)
    );
  }

  @override
  Future<List<FundUser>> fetchUserList() {
    return _database.collection("user").get().then(
            (value){
          return value.docs.map(
                  (map) => FundUser.fromMap(map)
          ).toList();
        }
    );
  }

  @override
  Future<void> updateUser(FundUser user) {
    return _database.collection('user')
        .doc(user.documentId)
        .update(user.toMap());
  }
}