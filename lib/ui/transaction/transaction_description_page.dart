import 'package:ardoise/ui/transaction/transaction_page_arguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TransactionDescritpionPage extends StatefulWidget {
  final TransactionDescriptionPageArguments transaction;
  const TransactionDescritpionPage({Key? key, required this.transaction}) : super(key: key);

  @override
  _TransactionDescritpionPageState createState() => _TransactionDescritpionPageState();
}

class _TransactionDescritpionPageState extends State<TransactionDescritpionPage> {
  //Create the Controllers:
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _descriptionTextController = TextEditingController();

  TransactionPageArguments? _transaction;

  @override
  void dispose(){
    _titleTextController.dispose();
    _descriptionTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Description")
        ),
        body:Form(
            key: _formKey,
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[

                      Text("Titre de la transaction:",
                        style: Theme.of(context).textTheme.headline6,),
                      TextFormField(
                          controller: _titleTextController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vous devez spécifier un titre';
                            }
                            return null;
                          }),
                      Divider(height: 80),

                      Text("Description de la transaction: ",
                        style: Theme.of(context).textTheme.headline6,),
                      TextFormField(
                        maxLines: 5,
                        controller: _descriptionTextController,
                      ),
                      Divider(height: 80),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                          ),

                          child: const Text('Valider',
                            style: TextStyle(
                                fontSize: 20
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              TransactionPageArguments transaction = TransactionPageArguments(
                                  user: widget.transaction.user,
                                  currentAccount:  widget.transaction.currentAccount,
                                  transactionType: widget.transaction.transactionType,
                                  accountFrom: widget.transaction.accountFrom,
                                  accountTo: widget.transaction.accountTo,
                                  amount: widget.transaction.amount,
                                  title: _titleTextController.text,
                                  description: _descriptionTextController.text
                              );

                              Navigator.pushNamed(
                                  context,
                                  '/transaction/summary',
                                  arguments: transaction);
                            }
                          }
                      ),
                    ]
                ))
        )
    );

  }
}
