import '../../model/firebase/transaction.dart';

abstract class IEmailPort {
  void sendTransactionPendingEmail(FundTransaction transaction);

  void sendTransactionConfirmedEmail(FundTransaction transaction);

  void sendTransactionCancelledEmail(FundTransaction transaction);
}
