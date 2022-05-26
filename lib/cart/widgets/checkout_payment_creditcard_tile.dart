import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saveat/blocs/cart_bloc.dart';
import 'package:saveat/inputs.dart';
import 'package:saveat/util.dart';

class CheckoutPaymentCreditCardTile extends StatelessWidget {

  const CheckoutPaymentCreditCardTile(this.item, this.bloc);

  final Map item;
  final CartBloc bloc;

  static TextEditingController _controllerCVV;

  @override
  Widget build(BuildContext context) {

    bool _selected = false;
    if(bloc.cartaoSelecionado != null){
      _selected = bloc.cartaoSelecionado['mask'] == item['mask'] && bloc.cartaoSelecionado['cvv'] != null;
    }

    return InkWell(
      onTap: (){

        _controllerCVV = TextEditingController();

        showAlertDialog(context: context, dialog: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Para continuar digite o código de segurança de seu cartão de crédito final ${item['final']}.\n\nEste código encontra-se geralmente na parte traseira de seu cartão e pode ser formado por 03 ou 04 números.',
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: InputField(
                        attribute: 'cvv',
                        label: 'Código de segurança',
                        autofocus: true,
                        controller: _controllerCVV,
                        keyboardType: TextInputType.number,
                        required: true,
                      ),
                    ),
                    SizedBox(width: 15),
                    Image.asset('assets/images/cvv_icon.jpg'),
                  ],
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
                      child: Text('Confirmar'),
                      textColor: Colors.green,
                      onPressed: (){
                        if(_controllerCVV.text != '' && (_controllerCVV.text.length == 3 || _controllerCVV.text.length == 4)){
                          item['cvv'] = _controllerCVV.text;
                          bloc.selecionaCartao(item);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ));

      },
      child: Row(
        children: <Widget>[
          Container(
            width: 26,
            height: 26,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey
              )
            ),
            child: _selected ? Container(
              color: Colors.green,
            ) : Container(),
          ),
          SizedBox(width: 10,),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: (item['brand'] != '' ? 20 : 0)),
                      child: Text(item['brand'].toString().toUpperCase()),
                    ),
                    _selected ? Text(
                      'CVV: ${bloc.cartaoSelecionado['cvv']}'
                    ) : Container(),
                  ],
                ),
                Text(
                  item['mask'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
