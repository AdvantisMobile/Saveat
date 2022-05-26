import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/checkout_provider.dart';

import '../inputs.dart';
import '../util.dart';

class CartObservacoes extends StatelessWidget {

  static TextEditingController _controller;

  @override
  Widget build(BuildContext context) {

    CheckoutProvider provider = Provider.of<CheckoutProvider>(context);

    return InkWell(
      onTap: (){

        _controller = TextEditingController(text: provider.checkout['observacoes']);

        showAlertDialog(context: context, dialog: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                InputField(
                  attribute: 'observacoes',
                  label: 'Observações',
                  autofocus: true,
                  controller: _controller,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      child: Text('Fechar'),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text('Salvar'),
                      textColor: Colors.green,
                      onPressed: (){
                        provider.checkout['observacoes'] = _controller.text;
                        Navigator.pop(context);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'OBSERVAÇÕES',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18
              ),
            ),
            SizedBox(height: 10),
            provider.checkout['observacoes'] == '' ? Text(
              'Adicionar observações',
              style: TextStyle(
                color: Colors.green
              ),
            ) : Text(
              provider.checkout['observacoes'],
            )
          ],
        ),
      ),
    );
  }
}
