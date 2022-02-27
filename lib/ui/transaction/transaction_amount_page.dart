import 'package:ardoise/business/presentation/decimal_text_input_formatter.dart';
import 'package:ardoise/ui/transaction/transaction_page_arguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class TransactionAmountPage extends StatefulWidget {
  final TransactionAmountPageArguments transaction;
  const TransactionAmountPage({Key? key, required this.transaction}) : super(key: key);

  @override
  _TransactionAmountPageState createState() => _TransactionAmountPageState();
}

class _TransactionAmountPageState extends State<TransactionAmountPage>{
  //Create the Controllers:
  final _formKey = GlobalKey<FormState>();
  TextEditingController _amountTextController = TextEditingController();

  bool _isValid = false;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Montant")
      ),
      body:Form(
      key: _formKey,
    child: Padding(
      padding: EdgeInsets.all(20),
        child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    mainAxisSize: MainAxisSize.max,
    children: <Widget>[
      Text("Combien ?",
        style: Theme.of(context).textTheme.headline6,),
      Divider(height:40),
      TextFormField(
        onChanged: (value){
          setState(()
          {
            _isValid = value.length > 0;
          });
        },
        inputFormatters: [
          DecimalTextInputFormatter(decimalRange: 2)
        ],
        autofocus: true,
        maxLines: null,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 40),
        keyboardType: TextInputType.numberWithOptions(
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
      Divider(height:40),
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
