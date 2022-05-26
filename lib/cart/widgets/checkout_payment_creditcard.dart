import 'package:flutter/material.dart';
import 'package:saveat/blocs/api_bloc.dart';
import 'package:saveat/blocs/cart_bloc.dart';
import 'package:saveat/cart/widgets/checkout_payment_creditcard_tile.dart';
import 'package:saveat/usuario/cartoes_form.dart';
import 'package:saveat/util.dart';

class CheckoutPaymentCreditCard extends StatefulWidget {

  CheckoutPaymentCreditCard(this.cartBloc, this.apiBloc);

  final CartBloc cartBloc;
  final ApiBloc apiBloc;

  @override
  _CheckoutPaymentCreditCardState createState() => _CheckoutPaymentCreditCardState();
}

class _CheckoutPaymentCreditCardState extends State<CheckoutPaymentCreditCard> with AutomaticKeepAliveClientMixin {

  CartBloc cartBloc;
  ApiBloc apiBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    cartBloc = widget.cartBloc;
    apiBloc = widget.apiBloc;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<List>(
      stream: apiBloc.outCartaoCreditoUsuario,
      builder: (context, snapshot){
        if(!snapshot.hasData)
          return Container(
            padding: const EdgeInsets.only(top: 15),
            child: Text('Buscando seus cartões cadastrados...'),
          );

        List _cartoes = snapshot.data;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _cartoes.length == 0 ? Container() : Column(
              children: <Widget>[
                SizedBox(height: 10,),
                Text(
                  'Você pode escolher um cartão que adicionou anteriormente ou adicionar um novo'
                ),
                SizedBox(height: 15,),
                StreamBuilder<Map>(
                  stream: cartBloc.outCartaoSelecionado,
                  builder: (context, snapshot) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _cartoes.map<Widget>((v){
                        return Column(
                          children: <Widget>[
                            CheckoutPaymentCreditCardTile(v, cartBloc),
                            SizedBox(height: 10,),
                          ],
                        );
                      }).toList(),
                    );
                  }
                ),
              ],
            ),
            FlatButton(
              onPressed: () async {
                Map cartao = await showAlertDialog(
                  context: context,
                  barrierDismissible: false,
                  dialog: Dialog(
                    child: CartoesFormPage(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                  )
                );

                if(cartao != null){
                  apiBloc.addCartaoTemp(cartao);
                  cartBloc.selecionaCartao(cartao);
                }

              },
              child: Text(_cartoes.length == 0 ? 'Cadastrar um cartão' : 'Digitar novo cartão'),
              textColor: Colors.green,
            ),
          ],
        );
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
