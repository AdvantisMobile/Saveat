import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:saveat/blocs/cart_bloc.dart';
import 'package:saveat/inputs.dart';
import 'package:saveat/model/carrinho/pagamento_carrinho.dart';
import 'package:saveat/util.dart';

class CartPaymentBalanceWidget extends StatelessWidget {

  CartPaymentBalanceWidget(this.bloc, this.saldoAtual);

  final CartBloc bloc;
  final double saldoAtual;

  static TextEditingController _controller;
  static double pagamentoSaldo;

  @override
  Widget build(BuildContext context) {

    pagamentoSaldo = double.tryParse(bloc.pagamentoSaldo.toString());

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
                      maskValor(bloc.valorTotalCompra.toString()),
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
            initialValue: null,
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
                  double _valorPedido = double.tryParse((bloc.valorTotalCompra - 0.01).toStringAsFixed(2));

                  if(_saldo > saldoAtual){
                    showFlushBarDanger(context, 'Você possui no momento apenas ${maskValor(saldoAtual.toString())} para utilização.');
                    return;
                  }

                  if(_saldo > _valorPedido){
                    showFlushBarDanger(context, 'O valor máximo possível para utilização do saldo para este pedido é de ${maskValor(_valorPedido.toString())}.');
                    return;
                  }

                  bloc.pagamentoSaldo = _saldo;
                  bloc.selecionaPagamentoTipo(PagamentoCarrinho.TIPO_PAGAMENTO_SALDO_CARTAO, saldo: _saldo);
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
