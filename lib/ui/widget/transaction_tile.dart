import 'package:ardoise/business/presentation/string_adapter.dart';
import 'package:ardoise/model/viewmodel/transactiondetails_viewmodel.dart';
import 'package:ardoise/model/viewmodel/transactionlist_viewmodel.dart';
import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  final TransactionTileViewModel transaction;
  const TransactionTile({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        TransactionDetailsViewModel viewModel = TransactionDetailsViewModel.fromTransactionTile(transaction);
        Navigator.pushNamed(context, '/transaction/details', arguments: viewModel);
      },
      title: Text(transaction.title),
      subtitle: Text(transaction.isCredit ?
      "de ${transaction.accountFrom}" :
      "à ${transaction.accountTo}"),
      leading: CircleAvatar(
        backgroundColor: transaction.isCredit? Theme.of(context).primaryColor : Theme.of(context).colorScheme.primaryVariant,
        foregroundColor: Colors.white,
        child: const Icon(Icons.euro_symbol),),
      trailing: Text(
        StringAdapter.formatCurrency(context, transaction.amount),
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}