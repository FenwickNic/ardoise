class TransactionListViewModel{
  DateTime date;
  List<TransactionTileViewModel> transactions;

  TransactionListViewModel({
    required this.date,
    required this.transactions});
}

class TransactionTileViewModel{
  String title;
  String description;
  String accountFrom = "";
  String accountTo = "";
  bool isCredit = false;
  double amount;
  double newBalance;

  TransactionTileViewModel(
      {required this.title,
        this.description = '',
        required this.accountFrom,
        required this.accountTo,
        required this.amount,
        required this.newBalance}) : this.isCredit = (amount >= 0);
}