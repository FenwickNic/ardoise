import 'package:ardoise/business/presentation/decimal_text_input_formatter.dart';
import 'package:ardoise/ui/transaction/transaction_page_arguments.dart';
import 'package:flutter/material.dart';

class TransactionAmountPage extends StatefulWidget {
  final TransactionAmountPageArguments transaction;
  const TransactionAmountPage({Key? key, required this.transaction}) : super(key: key);

  @override
  _TransactionAmountPageState createState() => _TransactionAmountPageState();
}

class _TransactionAmountPageState extends State<TransactionAmountPage>{
  //Create the Controllers:
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountTextController = TextEditingController();

  bool _isValid = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose(){
    _amountTextController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Montant")
        ),
        body:Form(
            key: _formKey,
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text("Combien ?",
                        style: Theme.of(context).textTheme.headline6,),
                      const Divider(height:40,thickness: 0),
                      TextFormField(
                          onChanged: (value){
                            setState(()
                            {
                              _isValid = value.isNotEmpty;
                            });
                          },
                          inputFormatters: [
                            DecimalTextInputFormatter(decimalRange: 2)
                          ],
                          autofocus: true,
                          maxLines: null,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 40),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: false),
                          controller: _amountTextController,
                          decoration: const InputDecoration (
                            suffixIcon: Icon(Icons.euro, size: 50,),
                            isCollapsed: true,

                            //border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vous devez spécifier un montant';
                            } if(double.tryParse(value) == null){
                              return "Montant invalide";
                            }
                            return null;
                          }),
                      const Divider(height:40),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                          ),

                          child: const Text('Valider',
                            style: TextStyle(
                                fontSize: 20
                            ),
                          ),
                          onPressed: !_isValid ? null :
                              () async {
                            if (_formKey.currentState!.validate()) {

                              String stringAmount = _amountTextController.text;
                              double? amount = double.tryParse(stringAmount);

                              if(amount != null){
                                TransactionDescriptionPageArguments transaction = TransactionDescriptionPageArguments(
                                    user: widget.transaction.user,
                                    currentAccount:  widget.transaction.currentAccount,
                                    accountTo: widget.transaction.accountTo,
                                    accountFrom: widget.transaction.accountFrom,
                                    transactionType: widget.transaction.transactionType,
                                    amount: amount
                                );
                                Navigator.pushNamed(
                                    context,
                                    '/transaction/description',
                                    arguments: transaction);
                              }
                            }
                          }
                      ),
                    ]
                ))
        )
    );

  }
}
