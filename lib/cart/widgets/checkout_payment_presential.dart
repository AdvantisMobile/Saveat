import 'package:flutter/material.dart';
import 'package:saveat/blocs/cart_bloc.dart';
import 'package:saveat/inputs.dart';
import 'package:saveat/model/carrinho/pagamento_carrinho.dart';

class CheckoutPaymentPresential extends StatefulWidget {

  CheckoutPaymentPresential(this.bloc);

  final CartBloc bloc;

  @override
  _CheckoutPaymentPresentialState createState() => _CheckoutPaymentPresentialState();
}

class _CheckoutPaymentPresentialState extends State<CheckoutPaymentPresential> {

  CartBloc bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    bloc = widget.bloc;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 15),
        DropdownField(
          attribute: 'forma_pgto',
          label: 'Qual o método de pagamento?',
          items: [
            {'id':'1', 'nome': 'Cartão de crédito'},
            {'id':'2', 'nome': 'Cartão de débito'},
            {'id':'3', 'nome': 'Dinheiro'},
          ],
          initialValue: '3',
          indexValue: 'nome',
          onChanged: (v){
            bloc.selecionaPagamentoTipo(PagamentoCarrinho.TIPO_PAGAMENTO_PRESENCIAL, forma: int.tryParse(v));
          },
        ),
        bloc.pagamentoTipo['forma'] != 3 ? Container() : Column(
          children: <Widget>[
            SizedBox(height: 5),
            DropdownField(
              attribute: 'troco',
              label: 'Precisa de troco?',
              items: [
                {'id':'0', 'nome': 'Não preciso de troco'},
                {'id':'5', 'nome': 'Troco para R\$5,00'},
                {'id':'10', 'nome': 'Troco para R\$10,00'},
                {'id':'20', 'nome': 'Troco para R\$20,00'},
                {'id':'50', 'nome': 'Troco para R\$50,00'},
                {'id':'100', 'nome': 'Troco para R\$100,00'},
              ],
              initialValue: '0',
              indexValue: 'nome',
              onChanged: (v){
                bloc.selecionaPagamentoTipo(PagamentoCarrinho.TIPO_PAGAMENTO_PRESENCIAL, troco: v);
              },
            )
          ],
        ),
      ],
    );
  }
}
