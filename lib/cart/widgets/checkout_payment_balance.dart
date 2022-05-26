import 'package:flutter/material.dart';
import 'package:saveat/blocs/cart_bloc.dart';
import 'package:saveat/cart/widgets/checkout_payment_balance_widget.dart';
import 'package:saveat/util.dart';

class CheckoutPaymentBalance extends StatelessWidget {

  const CheckoutPaymentBalance(this.bloc, this.saldo);

  final CartBloc bloc;
  final double saldo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: <Widget>[
          FlatButton(
            padding: EdgeInsets.all(0),
            onPressed: (){
              showAlertDialog(
                context: context,
                barrierDismissible: false,
                dialog: Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: CartPaymentBalanceWidget(bloc, saldo),
                ),
              );
            },
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Text(
                    'Pagamento com saldo',
                    style: TextStyle(
                        color: Colors.blue
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    maskValor(bloc.pagamentoSaldo.toString()),
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Text(
                  'Pagamento com cartão',
                  style: TextStyle(
                      color: Colors.blue
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  maskValor((bloc.valorTotalCompra - bloc.pagamentoSaldo).toString()),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
