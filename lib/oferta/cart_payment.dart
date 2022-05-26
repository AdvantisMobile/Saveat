import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saveat/inputs.dart';
import 'package:saveat/oferta/cart_payment_saldo.dart';
import 'package:saveat/provider/acesso_provider.dart';
import 'package:saveat/provider/checkout_provider.dart';
import 'package:saveat/provider/usuario_provider.dart';
import 'package:saveat/usuario/cartoes_form.dart';

import '../util.dart';

class CartPayment extends StatelessWidget {

  final Map item;
  final ScrollController scrollController;

  CartPayment(this.item, this.scrollController);

  static CheckoutProvider checkoutProvider;
  static AcessoProvider acessoProvider;
  static UsuarioProvider usuarioProvider;
  static bool _isGetCards = false;

  static TextEditingController _controllerCVV;

  @override
  Widget build(BuildContext context) {

    checkoutProvider = Provider.of<CheckoutProvider>(context);
    acessoProvider = Provider.of<AcessoProvider>(context, listen: false);
    usuarioProvider = Provider.of<UsuarioProvider>(context);

    Widget _botao(int tipo, String label, {bool enabled: true}){
      return Container(
        width: double.maxFinite,
        height: 35,
        decoration: BoxDecoration(
          border: Border.all(
            color: checkoutProvider.checkout['pagamento_tipo'] == tipo ? Colors.green : Colors.grey[300],
            width: 1
          ),
          borderRadius: BorderRadius.circular(30)
        ),
        child: FlatButton(
          onPressed: !enabled ? null : () async {
            checkoutProvider.atualizaPagamentoTipo(tipo);

            await Future.delayed(Duration(milliseconds: 500));
            scrollController.animateTo(scrollController.position.pixels + 250, duration: Duration(milliseconds: 500), curve: Curves.easeIn);
          },
          color: checkoutProvider.checkout['pagamento_tipo'] == tipo ? Colors.green : Colors.white,
          textColor: checkoutProvider.checkout['pagamento_tipo'] == tipo ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
          ),
          child: Text(label),
        ),
      );
    }

    Widget _saldoPagamento(){
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
                    child: CartPagamentoSaldo(acessoProvider.usuarioLogado['saldo'], checkoutProvider.checkout['valor_compra']),
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
                      maskValor(checkoutProvider.checkout['pagamento_saldo'].toString()),
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
                    maskValor((checkoutProvider.checkout['valor_compra'] - checkoutProvider.checkout['pagamento_saldo']).toString()),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget _adicionaisPagamento() {
      if(checkoutProvider.checkout['pagamento_tipo'] == 1 || checkoutProvider.checkout['pagamento_tipo'] == 4){
        if(!_isGetCards && usuarioProvider.usuarioCreditCards.length == 0){
          _isGetCards = !_isGetCards;
          usuarioProvider.loadingCards = true;
          usuarioProvider.getCreditCards(context);
        }

        return usuarioProvider.loadingCards ? Container(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ) : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            checkoutProvider.checkout['pagamento_tipo'] == 4 ? _saldoPagamento() : Container(),
            usuarioProvider.usuarioCreditCards.length >= 1 ? Column(
              children: <Widget>[
                SizedBox(height: 16),
                Text('Você pode escolher um cartão que adicionou anteriormente ou adicionar um novo.')
              ],
            ) : Container(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: usuarioProvider.usuarioCreditCards.map<Widget>((card){

                bool _selected = checkoutProvider.checkout['cartao'] != null && checkoutProvider.checkout['cartao']['mask'] == card['mask'] && checkoutProvider.checkout['cartao']['cvv'] != '' ? true : false;

                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(_selected ? Icons.check : Icons.radio_button_unchecked),
                          SizedBox(width: 15),
                          Text(card['brand'], textAlign: TextAlign.left,),
                          Expanded(
                            child: Text(
                              card['mask'] + (_selected ? '\ncvv: ${checkoutProvider.checkout['cartao']['cvv']}' : ''),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Roboto'
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    color: _selected ? Colors.green[100] : Colors.grey[100],
                    onPressed: (){

                      if(card['cvv'] != null && card['cvv'] != '' && !_selected) {
                        checkoutProvider.atualizaCartaoCredito(card);
                        return;
                      }

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
                              Text('Para continuar digite o código de segurança de seu cartão de crédito ${card['final']}.\n\nEste código encontra-se geralmente na parte traseira de seu cartão e é formado geralmente por 03 ou 04 números.'),
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
                                        card['cvv'] = _controllerCVV.text;
                                        checkoutProvider.atualizaCartaoCredito(card);
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
                  ),
                );
              }).toList()..add(
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text(usuarioProvider.usuarioCreditCards.length >= 1 ? 'Digitar novo cartão' : 'Digitar dados do cartão'),
                      textColor: Colors.green,
                      onPressed: () async {

                        await showAlertDialog(
                          context: context,
                          barrierDismissible: false,
                          dialog: Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: CartoesFormPage(),
                          )
                        );

                      },
                    ),
                  )
              ),
            ),
          ],
        );
      }

      if(checkoutProvider.checkout['pagamento_tipo'] == 3){

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
                checkoutProvider.atualizaPagamentoForma(int.tryParse(v));
                scrollController.animateTo(scrollController.position.pixels + 250, duration: Duration(milliseconds: 500), curve: Curves.easeIn);
              },
            ),
            checkoutProvider.checkout['pagamento_forma'] != 3 ? Container() : Column(
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
                    checkoutProvider.checkout['pagamento_troco'] = v;
                  },
                )
              ],
            ),
          ],
        );
      }

      if(checkoutProvider.checkout['pagamento_tipo'] == 20){
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Text('Boa Escolha!'),
        );
      }

      return Container();

    }

    List<Widget> _botoesPagamento(){
      List<Widget> out = List<Widget>();

      if(item['empresa']['tipos_recebimento']['credito'] != null)
        out.add(_botao(1, 'CARTÃO DE CRÉDITO'));

      if((acessoProvider.usuarioLogado['saldo'] > checkoutProvider.checkout['valor_compra']) && item['empresa']['tipos_recebimento']['saldo'] != null)
        out.add(_botao(2, 'SALDO NO APP (${maskValor(acessoProvider.usuarioLogado['saldo'].toString())})'));

      if(item['empresa']['tipos_recebimento']['credito'] != null && (acessoProvider.usuarioLogado['saldo'] > 0 && item['empresa']['tipos_recebimento']['saldo'] != null))
        out.add(_botao(4, 'SALDO + CARTÃO'));

      if(item['empresa']['tipos_recebimento']['presencial'] != null)
        out.add(_botao(3, 'PAGAR PRESENCIALMENTE'));

      return out;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'PAGAMENTO',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 18
          ),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _botoesPagamento().map((v){
            return v;
          }).toList(),
        ),
        _adicionaisPagamento(),
      ],
    );
  }
}
