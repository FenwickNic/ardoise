import 'package:ardoise/business/authentication/fire_auth.dart';
import 'package:ardoise/business/data/interface_account.dart';
import 'package:ardoise/model/common/app_error.dart';
import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/model/firebase/enum_transaction_status.dart';
import 'package:ardoise/model/firebase/transaction.dart';

import 'package:ardoise/model/firebase/fund_user.dart';
import 'package:ardoise/model/firebase/transaction_log.dart';
import 'package:ardoise/ui/transaction/transaction_page_arguments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class FirebaseAdapter extends IAccountPort{

  final FirebaseFirestore _database = FirebaseFirestore.instance;
  FirebaseAdapter();

  ///
  ///TRANSACTIONS
  ///
  @override
  Future<void> validateTransfer(String transactionId) async{
    try {
      FundTransaction transaction = await _database.collection('transaction')
          .doc(transactionId).get()
          .then(
              (value) => FundTransaction.fromMap(value)
      );
      await _transferFunds(transaction);
    }catch(e, stackTrace){
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw AppError(
          severity: ESeverityLevel.Error,
          message: "Impossible de valider le transfert",
          description: "Une erreur est intervenur et nous n'avons pas pu valider le transfert veuillez contacter votre administrateur."
      );
    }
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

  Future<void> _transferFunds(FundTransaction transaction) async{
    //D'abord s'assurer que la transaction est bien "payée".
    transaction.approvalStatus = ETransactionApprovalStatus.Paid;
    try {
      if (transaction.documentId == "") {
        DocumentReference transRef =
        await _database.collection('transaction').add(transaction.toMap());
        transaction.documentId = transRef.id;
      } else {
        await _database.collection('transaction')
            .doc(transaction.documentId)
            .set(transaction.toMap());
      }
    }catch(e, stack){
      await Sentry.captureException(
        e,
        stackTrace: stack,
      );
      throw AppError(
          severity: ESeverityLevel.Error,
          message: "Opération impossible",
          description: "Une erreur est intervenue et nous n'avons pas pu valider le transfert veuillez contacter votre administrateur."
      );
    }

    // Débiter le compte bancaire du créancier et du créditeur en même temps
    // Afin de s'assurer que le nouveau crédit sur le compte soit correct, nous allons
    // procéder en une seule transaction.
    DocumentReference docAccountFrom =
    _database.collection('account').doc(transaction.accountFrom);
    DocumentReference docAccountTo =
    _database.collection('account').doc(transaction.accountTo);

    await FirebaseFirestore.instance.runTransaction((fireTransaction) async {
      //Récupérer les comptes bancaires
      DocumentSnapshot snapshotFrom = await fireTransaction.get(docAccountFrom);
      DocumentSnapshot snapshotTo = await fireTransaction.get(docAccountTo);

      if (!snapshotFrom.exists || !snapshotTo.exists) {
        throw Exception("This account does not exist");
      }

      //Mettre à jour le crédit sur le compte bancaire du créancier
      double oldBalanceFrom = (snapshotFrom.data() as Map<String, dynamic>)['balance'];
      double newBalanceFrom = oldBalanceFrom - transaction.amount;
      fireTransaction.update(docAccountFrom, {'balance': newBalanceFrom});

      //Mettre à jour le compte du créditeur
      double oldBalanceTo = (snapshotTo.data() as Map<String, dynamic>)['balance'];
      double newBalanceTo = oldBalanceTo + transaction.amount;
      fireTransaction.update(docAccountTo, {'balance': newBalanceTo});

      //Ajouter un transaction log pour le créancier
      TransactionLog logFrom =TransactionLog(
          transactionId: transaction.documentId,
          accountId: transaction.accountFrom,
          amount: -transaction.amount,
          newBalance: newBalanceFrom);
      fireTransaction.set(_database.collection('transaction_log').doc(), logFrom.toMap());

      //Ajouter un transaction log pour le créditeur
      TransactionLog logTo =TransactionLog(
          transactionId: transaction.documentId,
          accountId: transaction.accountTo,
          amount: transaction.amount,
          newBalance: newBalanceTo);
      _database.collection('transaction_log').add(logTo.toMap());
    }).onError((e, stackTrace) async{
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );

      //Set the transaction to Pending
      transaction.approvalStatus = ETransactionApprovalStatus.Pending;
      await _database.collection('transaction')
          .doc(transaction.documentId)
          .set(transaction.toMap());

      //Remove all transactions
      _database.collection('transaction_log')
          .where('transaction_id', isEqualTo: transaction.documentId).get()
      .then((snapshots) {
        for(var item in snapshots.docs){
          item.reference.delete();
        }
      });

      //Log error
      AppError error = AppError(
          severity: ESeverityLevel.Error,
          message: "${transaction.documentId}: Opération interrompue",
          description: e.toString()
      );
      throw error;
    });
  }

  Future<void> _claimFund(FundTransaction transaction) async {
    try {
      _database.collection('transaction').add(transaction.toMap());
    }    catch(e, stack) {
      await Sentry.captureException(
        e,
        stackTrace: stack,
      );
      throw AppError(
          severity: ESeverityLevel.Error,
          message: "Opération impossible",
          description: "Une erreur est intervenue et nous n'avons pas pu valider le transfert veuillez contacter votre administrateur."
      );
    }
  }

  @override
  Future<void> cancelTransfer(String transactionId) async{
    try {
      _database.collection('transaction').doc(transactionId)
          .update(
          {"approval_status": ETransactionApprovalStatus.Cancelled.index});
    }    catch(e, stack){
      await Sentry.captureException(
        e,
        stackTrace: stack,
      );
      throw AppError(
          severity: ESeverityLevel.Error,
          message: "Opération impossible",
          description: "Une erreur est intervenue et nous n'avons pas pu valider le transfert veuillez contacter votre administrateur."
      );
    }
  }

  @override
  Future<List<TransactionLog>> fetchPaidTransactionList(Account account) async{
    try{
      //Récupérer toutes les transactions rattachées au compte.
      return _database.collection("transaction_log")
          .orderBy('date', descending: true)
          .where('account_id', isEqualTo: account.documentId)
          .get().then(
              (value) {
            return value.docs.map(
                    (map) => TransactionLog.fromMap(map)).toList();
          });
    }    catch(e, stack){
      await Sentry.captureException(
        e,
        stackTrace: stack,
      );
      throw AppError(
          severity: ESeverityLevel.Error,
          message: "Opération impossible",
          description: "Une erreur est intervenue et nous n'avons pas pu valider le transfert veuillez contacter votre administrateur."
      );
    }
  }

  @override
  Future<List<FundTransaction>> fetchPendingTransactionList(Account account) async{
    try{
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
    }    catch(e, stack){
      await Sentry.captureException(
        e,
        stackTrace: stack,
      );
      throw AppError(
          severity: ESeverityLevel.Error,
          message: "Opération impossible",
          description: "Une erreur est intervenue et nous n'avons pas pu valider le transfert veuillez contacter votre administrateur."
      );
    }
  }

  @override
  Future<List<FundTransaction>> fetchSubmittedTransactionList(Account account) async{
    try{
      //Récupérer toutes les transactions rattachées au compte.
      return _database.collection("transaction")
          .orderBy('submission_date', descending: false)
          .where('account_to', isEqualTo: account.documentId)
          .where('approval_status', isEqualTo: ETransactionApprovalStatus.Pending.index)
          .get().then(
              (value) {
            return value.docs.map((map) => FundTransaction.fromMap(map)).toList();
          });
    }    catch(e, stack){
      await Sentry.captureException(
        e,
        stackTrace: stack,
      );
      throw AppError(
          severity: ESeverityLevel.Error,
          message: "Opération impossible",
          description: "Une erreur est intervenue et nous n'avons pas pu valider le transfert veuillez contacter votre administrateur."
      );
    }
  }

  @override
  Future<FundTransaction> fetchTransaction(TransactionLog transactionLog) async{
    try{
      return _database
          .collection("transaction")
          .doc(transactionLog.transactionId)
          .get()
          .then((transaction) => FundTransaction.fromMap(transaction));
    }    catch(e, stack){
      await Sentry.captureException(
        e,
        stackTrace: stack,
      );
      throw AppError(
          severity: ESeverityLevel.Error,
          message: "Opération impossible",
          description: "Une erreur est intervenue et nous n'avons pas pu valider le transfert veuillez contacter votre administrateur."
      );
    }
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
    try{
      await _database
          .collection('account')
          .add(account.toMap());
    }    catch(e, stack){
      await Sentry.captureException(
        e,
        stackTrace: stack,
      );
      throw AppError(
          severity: ESeverityLevel.Error,
          message: "Opération impossible",
          description: "Une erreur est intervenue et nous n'avons pas pu valider le transfert veuillez contacter votre administrateur."
      );
    }
  }

  @override
  Future<Account> fetchAccount(FundUser user) async{
    try{
      return _database.collection('account')
          .where(
          'user_id',
          isEqualTo: user.documentId)
          .get().then(
              (value) => Account.fromMap(value.docs.first)
      );
    }    catch(e, stack){
      await Sentry.captureException(
        e,
        stackTrace: stack,
      );
      throw AppError(
          severity: ESeverityLevel.Error,
          message: "Opération impossible",
          description: "Une erreur est intervenue et nous n'avons pas pu valider le transfert veuillez contacter votre administrateur."
      );
    }
  }

  @override
  Future<List<Account>> fetchAccountList() async{
    try{
      return _database.collection('account').get().then(
              (value) =>
              (value.docs.map(
                      (account) =>
                      Account.fromMap(account)
              )
              ).toList()
      );
    }    catch(e, stack){
      await Sentry.captureException(e, stackTrace: stack);
      throw AppError(
          severity: ESeverityLevel.Error,
          message: "Opération impossible",
          description: "Une erreur est intervenue et nous n'avons pas pu valider le transfert veuillez contacter votre administrateur."
      );
    }
  }

  @override
  Future<List<Account>> searchAccounts({String name = "", String accountToRemove = ""}) async {
    try{
      return fetchAccountList().then((accounts) {
        if(name.isEmpty && accountToRemove == "") return accounts;
        List<Account> filteredList = [];
        for (Account account in accounts) {
          if (
            accountToRemove != account.documentId &&
            account.accountName.toLowerCase().contains(name.toLowerCase())
          ) {
            filteredList.add(account);
          }
        }
        return filteredList;
      });
    }    catch(e, stack){
      await Sentry.captureException(
        e,
        stackTrace: stack,
      );
      throw AppError(
          severity: ESeverityLevel.Error,
          message: "Opération impossible",
          description: "Une erreur est intervenue et nous n'avons pas pu valider le transfert veuillez contacter votre administrateur."
      );
    }
  }

  @override
  Future<Account> fetchAccountById(String accountId) async{
    try{
      return _database.collection('account').doc(accountId).get().then(
              (value) => Account.fromMap(value)
      );
    }    catch(e, stack){
      await Sentry.captureException(
        e,
        stackTrace: stack,
      );
      throw AppError(
          severity: ESeverityLevel.Error,
          message: "Opération impossible",
          description: "Une erreur est intervenue et nous n'avons pas pu valider le transfert veuillez contacter votre administrateur."
      );
    }
  }

  /***
   * USERS
   */
  @override
  Future<void> createUser(FundUser user) async {
    try {
      //Créer un utilisateur dans le moteur d'authentification.
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: user.email,
          password: "test123"
      ).then((value) => user.documentId = value.user!.uid);
    } on FirebaseAuthException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      switch(e.code) {
        case 'weak-password':
          throw AppError(
              severity: ESeverityLevel.Error,
              message: "Impossible de créer cet utilisateur",
              description: "Le mot de passe doit contenir des chiffres ainsi que des lettres.");
        case 'email-already-in-use':
          throw AppError(
              severity: ESeverityLevel.Error,
              message: "Impossible de créer cet utilisateur",
              description: "L'utilisateur semble déjà exister. Si vous êtes le propriétaire de cet email, veuillez essayer de vous connecter."
          );
        case 'invalid-email':
          throw AppError(
              severity: ESeverityLevel.Error,
              message: "Impossible de créer cet utilisateur",
              description: "L'email est invalide."
          );
        case 'operation-not-allowed':
          throw AppError(
              severity: ESeverityLevel.Critical,
              message: "Impossible de créer des utilisateurs",
              description: "L'opération n'est pas permise. Il faudra contacter votre administrateur."
          );
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw AppError();
    }

    FirebaseFirestore.instance.runTransaction((fireTransaction) async{
      //Créer un utilisateur en base de donnée
      fireTransaction.set(_database.collection('user').doc(user.documentId),
          user.toMap()
      );

      //Créer un compte pour cet utilisateur.
      Account account = Account(
        accountName: user.fullname,
        userId:user.documentId,
        creationDate: DateTime.now(),
      );
      //Créer un Compte en base de donnée
      fireTransaction.set(_database.collection('account').doc(),
          account.toMap()
      );
    }).onError((e, stackTrace) {
      AppError error = AppError(
          severity: ESeverityLevel.Error,
          message: "Opération interrompue",
          description: e.toString()
      );
      throw error;
    });

    FireAuth.sendPasswordResetEmail(user.email);
  }

  @override
  Future<FundUser> fetchUserById(String userId) async{
    try {
      return _database.collection("user").doc(userId).get().then(
              (value) => FundUser.fromMap(value)
      );
    }catch(e, stack){
      await Sentry.captureException(
        e,
        stackTrace: stack,
      );
      AppError error = AppError(
          severity: ESeverityLevel.Error,
          message: "Opération interrompue",
          description: e.toString()
      );
      throw error;
    }
  }

  @override
  Future<List<FundUser>> fetchUserList() async{
    try{
      return _database.collection("user").get().then(
              (value){
            return value.docs.map(
                    (map) => FundUser.fromMap(map)
            ).toList();
          }
      );
    }catch(e, stack){
      await Sentry.captureException(
        e,
        stackTrace: stack,
      );
      AppError error = AppError(
          severity: ESeverityLevel.Error,
          message: "Opération interrompue",
          description: e.toString()
      );
      throw error;
    }
  }

  @override
  Future<void> updateUser(FundUser user) async{
    try{
      return _database.collection('user')
          .doc(user.documentId)
          .update(user.toMap());
    }catch(e, stack){
      await Sentry.captureException(
        e,
        stackTrace: stack,
      );
      AppError error = AppError(
          severity: ESeverityLevel.Error,
          message: "Opération interrompue",
          description: e.toString()
      );
      throw error;
    }
  }
}