import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:provider/provider.dart';
import 'package:saveat/inputs.dart';
import 'package:saveat/provider/checkout_provider.dart';
import 'package:saveat/util.dart';

class CartPagamentoSaldo extends StatelessWidget {

  final double saldoAtual;
  final double valorPedido;
  CartPagamentoSaldo(this.saldoAtual, this.valorPedido);

  static TextEditingController _controller;
  static double pagamentoSaldo;

  @override
  Widget build(BuildContext context) {

    CheckoutProvider provider = Provider.of<CheckoutProvider>(context);

    pagamentoSaldo = double.tryParse(provider.checkout['pagamento_saldo'].toString());

    _controller = MoneyMaskedTextController(initialValue: pagamentoSaldo);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 25, 16, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      'Saldo atual',
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      maskValor(saldoAtual.toString()),
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      'Total do pedido',
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      maskValor(valorPedido.toString()),
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15,),
          InputField(
            attribute: 'saldo',
            label: 'Saldo à usar',
            autofocus: true,
            controller: _controller,
            keyboardType: TextInputType.number,
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
                  double _saldo = stringToValue(_controller.text);
                  double _valorPedido = double.tryParse((valorPedido - 0.01).toStringAsFixed(2));

                  if(_saldo > saldoAtual){
                    showFlushBarDanger(context, 'Você possui no momento apenas ${maskValor(saldoAtual.toString())} para utilização.');
                    return;
                  }

                  if(_saldo > _valorPedido){
                    showFlushBarDanger(context, 'O valor máximo possível para utilização do saldo para este pedido é de ${maskValor(_valorPedido.toString())}.');
                    return;
                  }

                  provider.atualizaPagamentoSaldoParcial(_saldo);
                  Navigator.pop(context);

                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
