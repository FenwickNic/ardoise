import 'package:ardoise/ui/transaction/transaction_page_arguments.dart';
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

  @override
  void dispose(){
    _titleTextController.dispose();
    _descriptionTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    },

      child: Scaffold(
        appBar: AppBar(
            title: const Text("Description")
        ),
        body:Form(
            key: _formKey,
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: ListView(
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
                      const Divider(height: 80, thickness: 0),

                      Text("Description de la transaction: ",
                        style: Theme.of(context).textTheme.headline6,),
                      TextFormField(
                        maxLines: 5,
                        controller: _descriptionTextController,
                      ),
                      const Divider(height: 80, thickness: 0),
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
    ));
  }
}
