import 'package:ardoise/model/firebase/enum_transaction_status.dart';
import 'package:ardoise/ui/transaction/transaction_page_arguments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FundTransaction{
  String documentId = "";
  DateTime submissionDate;
  String submittedBy;
  String accountFrom = "";
  String accountTo = "";
  double amount = 0;
  String title;
  String description = "";
  ETransactionType type;
  ETransactionApprovalStatus approvalStatus;

  FundTransaction({
    this.documentId = "",
    DateTime? submissionDate,
    required this.submittedBy,
    required this.accountFrom,
    required this.accountTo,
    required this.amount,
    required this.title,
    this.description = "",
    this.type = ETransactionType.Virement,
    this.approvalStatus = ETransactionApprovalStatus.Paid
  }) : this.submissionDate = submissionDate ?? DateTime.now();

  Map<String, dynamic> toMap(){
    return {
      'submission_date': submissionDate,
      'submitted_by': submittedBy,
      'account_from': accountFrom,
      'account_to': accountTo,
      'amount': amount,
      'title': title,
      'description' : description,
      'type' : type.index,
      'approval_status': approvalStatus.index
    };
  }
  factory FundTransaction.fromMap(DocumentSnapshot<Map<String, dynamic>> doc){
    Map<String, dynamic>? data = doc.data();

    if(data == null){
      throw new Exception("Transaction not found");
    }

    return FundTransaction(
        documentId: doc.id,
        submissionDate: DateTime.parse(data['submission_date'].toDate().toString()),
        submittedBy: data['submitted_by'],
        accountFrom: data['account_from'],
        accountTo: data['account_to'],
        amount: data['amount'],
        title: data['title'],
        description: data['description'],
        approvalStatus: ETransactionApprovalStatus.values[data['approval_status']],
      type: ETransactionType.values[data['type']]
    );
  }
}