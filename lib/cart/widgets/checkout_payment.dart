import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saveat/blocs/api_bloc.dart';
import 'package:saveat/blocs/cart_bloc.dart';
import 'package:saveat/cart/widgets/checkout_payment_balance.dart';
import 'package:saveat/cart/widgets/checkout_payment_creditcard.dart';
import 'package:saveat/cart/widgets/checkout_payment_presential.dart';
import 'package:saveat/cart/widgets/checkout_payment_tile.dart';
import 'package:saveat/model/carrinho/carrinho_model.dart';
import 'package:saveat/model/carrinho/pagamento_carrinho.dart';
import 'package:saveat/model/empresa_model.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/title-widget.dart';

class CheckoutPayment extends StatefulWidget {
  const CheckoutPayment(this.empresaId, this.bloc);

  final String empresaId;
  final CartBloc bloc;

  @override
  _CheckoutPaymentState createState() => _CheckoutPaymentState();
}

class _CheckoutPaymentState extends State<CheckoutPayment> {
  EmpresaModel empresa;
  ApiBloc _apiBloc;
  bool _loadedCards = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    CarrinhoModel carrinho = widget.bloc.getCarrinhoDaEmpresa(widget.empresaId);
    empresa = carrinho.empresa;

    ApiBloc apiBloc = Provider.of<ApiBloc>(context, listen: false);
    if (apiBloc != _apiBloc) _apiBloc = apiBloc;
    _apiBloc.getSaldoUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 13,
        right: 13,
        bottom: 60,
      ),
      child: Column(
        children: <Widget>[
          TitleWidget(
            'Pagamento',
            marginLeft: 0,
            marginTop: 0,
            marginBottom: 7,
          ),
          StreamBuilder<double>(
            initialData: 0,
            stream: _apiBloc.outSaldoUsuario,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.connectionState != ConnectionState.active) return CircularProgressIndicator();

              double saldoUsuario = snapshot.data;

              return StreamBuilder<String>(
                stream: widget.bloc.outPagamentoTipo,
                builder: (context, snapshot) {
                  // monta os tipos
                  List _tipos = List();

                  if (empresa.tiposRecebimento.credito) {
                    _tipos.add(CheckoutPaymentTile(
                      'credito',
                      'Cartão de Crédito',
                      () {
                        widget.bloc.selecionaPagamentoTipo(PagamentoCarrinho.TIPO_PAGAMENTO_CREDITO);
                      },
                      selected: snapshot.data == 'credito',
                    ));
                  }

                  if (empresa.tiposRecebimento.saldo && saldoUsuario >= widget.bloc.valorTotalCompra) {
                    _tipos.add(CheckoutPaymentTile(
                      'saldo',
                      'Saldo no APP (${maskValor(saldoUsuario.toString())})',
                      () {
                        widget.bloc.selecionaPagamentoTipo(PagamentoCarrinho.TIPO_PAGAMENTO_SALDO);
                      },
                      selected: snapshot.data == 'saldo',
                    ));
                  }

                  if (empresa.tiposRecebimento.credito && (empresa.tiposRecebimento.saldo && saldoUsuario > 0)) {
                    _tipos.add(CheckoutPaymentTile(
                      'saldo_cartao',
                      'Saldo + Cartão de Crédito',
                      () {
                        widget.bloc.selecionaPagamentoTipo(PagamentoCarrinho.TIPO_PAGAMENTO_SALDO_CARTAO);
                      },
                      selected: snapshot.data == 'saldo_cartao',
                    ));
                  }

                  if (empresa.tiposRecebimento.presencial) {
                    _tipos.add(CheckoutPaymentTile(
                      'presencial',
                      'Presencialmente',
                      () {
                        widget.bloc.selecionaPagamentoTipo(PagamentoCarrinho.TIPO_PAGAMENTO_PRESENCIAL);
                      },
                      selected: snapshot.data == 'presencial',
                    ));
                  }
                  //

                  if ((snapshot.data == 'credito' || snapshot.data == 'saldo_cartao') && !_loadedCards) {
                    _apiBloc.getCartaoCreditoUsuario();
                    _loadedCards = true;
                  }

                  return Column(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _tipos.map<Widget>((v) {
                          return v;
                        }).toList(),
                      ),
                      snapshot.data == 'credito' || snapshot.data == 'saldo_cartao'
                          ? Column(
                              children: <Widget>[
                                snapshot.data == 'saldo_cartao' ? CheckoutPaymentBalance(widget.bloc, saldoUsuario) : Container(),
                                CheckoutPaymentCreditCard(widget.bloc, _apiBloc),
                              ],
                            )
                          : Container(),
                      snapshot.data == 'presencial' ? CheckoutPaymentPresential(widget.bloc) : Container(),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
