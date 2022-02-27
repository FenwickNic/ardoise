import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/model/firebase/transaction.dart';
import 'package:ardoise/model/firebase/fund_user.dart';
import 'package:ardoise/model/firebase/transaction_log.dart';
import 'package:ardoise/model/viewmodel/transactionlist_viewmodel.dart';

enum ETransactionAmountFilter{
  LessThan,
  MoreThan,
  Equal
}

enum ETransactionFlagFilter{
  All,
  Active,
  Deleted
}

abstract class IAccountPort{
  //====================== CREER ================
  /***
   * Créer un utilisateur en base de donnée
   */
  Future<void> createUser(FundUser user);

  /***
   * Créer un compte bancaire en base de donneee.
   */
  Future<void> createAccount(Account account);

  //========================= UPDATE
  Future<void> updateUser(FundUser user);

  //======================== TRANSFERER ============
  /***
   * Cette méthode se charge de créer la transaction quelque soit son type.
   */
  Future<void> processTransaction(FundTransaction transaction);

  /***
   * Valider un transfert d'argent. Ceci peut être nécessaire lorsqu'un utilisateur
   * réclame de l'argent à un autre.
   */
  Future<void> validateTransfer(String transactionId);

  /***
   * Il est possible d'annuler une transaction soit lorsque:
   *  - l'utilisateur refuse un virement qui lui a été demandé
   *  - l'utilisateur annule sa propre demande de virement.
   *  - l'utilisateur a viré ou reçu de l'argent par erreur.
   */
  Future<void> cancelTransfer(String transactionId);

  //============================== RECUPERER ==================
  /***
   * Récupérer un utilisateur
   */
  Future<FundUser> fetchUserById(String userId);

  /***
   * Récupérer tous les utilisateurs
   */
  Future<List<FundUser>> fetchUserList();

  /***
   * Récupère le compte lié à un utilisateur
   */
  Future <Account> fetchAccount(FundUser user);

  Future<Account> fetchAccountById(String accountId);

  /***
   * Récupère la liste des comptes géré.
   */
  Future <List<Account>> fetchAccountList();

  /***
   * Récupérer la liste de toutes les transactions pour un compte
   */
  Future<List<TransactionLog>> fetchPaidTransactionList(Account account);

  /***
   * Récupère une transaction spécifique à un transaction Log.
   */
  Future<FundTransaction> fetchTransaction(TransactionLog transactionLog);

  /***
   * Filtrer la liste des transactions
   */
  List<FundTransaction> searchTransaction(
      String name,
      FundUser user_from,
      FundUser user_to,
      ETransactionAmountFilter filter,
      double filter_amount,
      DateTime date_from,
      DateTime date_to
      );

  /***
   * Afin de limiter les doublons, récupérer les transactions similaires à celle qui va être
   * passée.
   */
  List<FundTransaction> searchSimilar(FundTransaction transaction);

  Future<List<Account>> searchAccounts(String name);
}