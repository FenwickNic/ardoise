import 'package:ardoise/business/data/interface_account.dart';
import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/model/firebase/enum_transaction_status.dart';
import 'package:ardoise/model/firebase/transaction.dart';

import 'package:ardoise/model/firebase/fund_user.dart';
import 'package:ardoise/model/firebase/transaction_log.dart';
import 'package:ardoise/ui/transaction/transaction_page_arguments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAdapter extends IAccountPort{

  FirebaseFirestore _database = FirebaseFirestore.instance;
  FirebaseAdapter();

  /***
   * TRANSACTIONS
   */
  @override
  Future<void> validateTransfer(String transactionId) async{
    FundTransaction transaction = await _database.collection('transaction').doc(transactionId).get().then(
      (value) => FundTransaction.fromMap(value)
    );
    _transferFunds(transaction);
  }

  @override
  Future<void> processTransaction(FundTransaction transaction){
    switch(transaction.type){
      case ETransactionType.Virement:
        return _transferFunds(transaction);
      case ETransactionType.Creance:
        return _claimFund(transaction);
    }
  }
  @override
  Future<void> _transferFunds(FundTransaction transaction) async{
    //D'abord s'assurer que la transaction est bien "payée".
    transaction.approvalStatus = ETransactionApprovalStatus.Paid;

    String transactionId = "";
    if(transaction.documentId == ""){
      DocumentReference transRef =
      await _database.collection('transaction').add(transaction.toMap());
      transactionId = transRef.id;
    }else{
      await _database.collection('transaction').doc(transaction.documentId).set(transaction.toMap());
      transactionId = transaction.documentId;
    }

    // Débiter le compte bancaire du créancier
    // Afin de s'assurer que le nouveau crédit sur le compte soit correct, nous allons
    // procéder en une seule transaction.
    DocumentReference docAccountFrom =
      _database.collection('account')
        .doc(transaction.accountFrom);
    FirebaseFirestore.instance.runTransaction((fireTransaction) async {
      //Mettre à jour le crédit sur le compte bancaire du créancier
      DocumentSnapshot snapshotFrom = await fireTransaction.get(docAccountFrom);
      if (!snapshotFrom.exists) {
        throw Exception("This account does not exist");
      }
      double newBalanceFrom = (snapshotFrom.data() as Map<String, dynamic>)['balance'] - transaction.amount;
      fireTransaction.update(docAccountFrom, {'balance': newBalanceFrom});

      return newBalanceFrom;
    }).then(
        (newBalance){
          //Créer le transaction Log en y intégrant le nouveau crédit sur le compte.
          TransactionLog log_from =TransactionLog(
              transactionId: transactionId,
              accountId: transaction.accountFrom,
              amount: -transaction.amount,
              newBalance: newBalance);
          _database.collection('transaction_log').add(log_from.toMap());
        }
    );

    //Mettre à jour le crédit sur le compte créditeur et créer le transaction Log attaché:
    // Afin de s'assurer que le nouveau crédit sur le compte soit correct, nous allons
    // procéder en une seule transaction.
    DocumentReference docAccountTo =
    _database.collection('account')
        .doc(transaction.accountTo);
    FirebaseFirestore.instance.runTransaction((fireTransaction) async {
      //Mettre à jour le crédit sur le compte bancaire du créditeur.
      DocumentSnapshot snapshotTo = await fireTransaction.get(docAccountTo);

      if (!snapshotTo.exists) {
        throw Exception("This account does not exist");
      }
      double newBalanceTo = (snapshotTo.data() as Map<String, dynamic>)['balance'] + transaction.amount;
      fireTransaction.update(docAccountTo, {'balance': newBalanceTo});

      return newBalanceTo;
    }).then(
            (newBalance){
              //Créer le transaction log.
          TransactionLog log_from =TransactionLog(
              transactionId: transactionId,
              accountId: transaction.accountTo,
              amount: transaction.amount,
              newBalance: newBalance);
          _database.collection('transaction_log').add(log_from.toMap());
        }
    );
  }

  @override
  Future<void> _claimFund(FundTransaction transaction){
    return _database.collection('transaction').add(transaction.toMap());
  }

  @override
  Future<void> cancelTransfer(String transactionId) {
    return _database.collection('transaction').doc(transactionId)
        .update({"approval_status" : ETransactionApprovalStatus.Cancelled.index});
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
        .orderBy('submission_date', descending: false)
        .where('account_from', isEqualTo: account.documentId)
        .where('approval_status', isEqualTo: ETransactionApprovalStatus.Pending.index)
        .get().then(
            (value) {
          return value.docs.map(
                  (map) => FundTransaction.fromMap(map)
          ).toList();
        });
  }

  @override
  Future<List<FundTransaction>> fetchSubmittedTransactionList(Account account) {
    //Récupérer toutes les transactions rattachées au compte.
    return _database.collection("transaction")
        .orderBy('submission_date', descending: false)
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