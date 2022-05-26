import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saveat/blocs/api_bloc.dart';
import 'package:saveat/blocs/cart_bloc.dart';
import 'package:saveat/cart/widgets/checkout_location_address.dart';
import 'package:saveat/cart/widgets/checkout_location_new_address.dart';
import 'package:saveat/cart/widgets/checkout_location_tile.dart';
import 'package:saveat/model/carrinho/carrinho_model.dart';
import 'package:saveat/model/carrinho/entrega_carrinho.dart';
import 'package:saveat/model/empresa_model.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/title-widget.dart';

class CheckoutLocation extends StatefulWidget {
  const CheckoutLocation(this.empresa, this.bloc);

  final EmpresaModel empresa;
  final CartBloc bloc;

  @override
  _CheckoutLocationState createState() => _CheckoutLocationState(empresa: empresa);
}

class _CheckoutLocationState extends State<CheckoutLocation> {
  EmpresaModel empresa;
  ApiBloc _apiBloc;
  bool _enderecosCarregados = false;

  double _deliveryCustoMinimo;
  double _deliveryGratis;

  _CheckoutLocationState({
    this.empresa,
  });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

//    CarrinhoModel carrinho = widget.bloc.getCarrinhoDaEmpresa(empresa.id);
//    item = carrinho != null ? carrinho['itens'][0] : null;

    ApiBloc apiBloc = Provider.of<ApiBloc>(context);
    if (apiBloc != _apiBloc) {
      _apiBloc = apiBloc;
    }

    if (empresa != null) {
      _deliveryCustoMinimo = double.tryParse(empresa.deliveryCustoMinimo) ?? 0;
      _deliveryGratis = double.tryParse(empresa.deliveryFreteGratis) ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TitleWidget(
            'Como vai ser o consumo dessa delícia?',
            marginLeft: 0,
            marginTop: 7,
            marginBottom: 7,
          ),
          StreamBuilder<String>(
            stream: widget.bloc.outConsumo,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.active) {
                return Container();
              }

              // monta os tipos
              List _tipos = List();

              if (empresa.tiposConsumo.delivery && widget.bloc.valorTotalProdutos >= _deliveryCustoMinimo) {
                _tipos.add(
                  CheckoutLocationTile(
                    'delivery',
                    'Delivery',
                    () {
                      widget.bloc.selecionaConsumo(empresa.id, EntregaCarrinho.TIPO_ENTREGA_DELIVERY);
                    },
                    selected: snapshot.data == EntregaCarrinho.TIPO_ENTREGA_DELIVERY,
                  ),
                );
              }

              if (empresa.tiposConsumo.retirada) {
                _tipos.add(
                  CheckoutLocationTile(
                    'retirada',
                    'Retirada',
                    () {
                      widget.bloc.selecionaConsumo(empresa.id, EntregaCarrinho.TIPO_ENTREGA_RETIRADA);
                    },
                    selected: snapshot.data == EntregaCarrinho.TIPO_ENTREGA_RETIRADA,
                  ),
                );
              }

              if (empresa.tiposConsumo.consumo) {
                _tipos.add(
                  CheckoutLocationTile(
                    'consumo',
                    'Consumo no local',
                    () {
                      widget.bloc.selecionaConsumo(empresa.id, EntregaCarrinho.TIPO_ENTREGA_CONSUMO);
                    },
                    selected: snapshot.data == EntregaCarrinho.TIPO_ENTREGA_CONSUMO,
                  ),
                );
              }
              //

              if (snapshot.data == 'delivery' && !_enderecosCarregados) {
                _apiBloc.fetchEnderecosCliente(empresa.id);
                _enderecosCarregados = true;
              } else {
                widget.bloc.selecionaEndereco(Map(), empresa.id);
              }

              double _custoEntrega;
              if (_deliveryGratis > 0 && widget.bloc.valorTotalProdutos >= _deliveryGratis) {
                _custoEntrega = 0;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  widget.bloc.valorTotalProdutos >= _deliveryCustoMinimo
                      ? Container()
                      : Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.infoCircle,
                                  size: 14,
                                  color: Colors.red,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Delivery disponível à partir de ${maskValor(_deliveryCustoMinimo.toString())}',
                                  style: TextStyle(color: Colors.red, fontSize: 12),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                  Wrap(
                    spacing: 10,
                    children: _tipos.map<Widget>((item) {
                      return item;
                    }).toList(),
                  ),
                  snapshot.data == 'retirada' || snapshot.data == 'consumo'
                      ? Container(
                          padding: const EdgeInsets.only(top: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.exclamationTriangle,
                                    color: Colors.yellow[800],
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Você deverá ${(snapshot.data == 'retirada' ? 'retirar' : 'consumir')} seu pedido dentro do prazo válido de cada produto no seguinte endereço:',
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                empresa.empresa,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(getEndereco(empresa)),
                            ],
                          ),
                        )
                      : Container(),
                  snapshot.data == 'delivery' && widget.bloc.valorTotalProdutos >= _deliveryCustoMinimo
                      ? Container(
                          padding: const EdgeInsets.only(top: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.exclamationTriangle,
                                    color: Colors.yellow[800],
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Expanded(
                                    child: Text('Seu pedido será entregue dentro do prazo válido de cada produto no seu endereço selecionado:'),
                                  ),
                                ],
                              ),
                              StreamBuilder(
                                stream: _apiBloc.outEnderecosCliente,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData)
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: Text('Procurando seus endereços...'),
                                    );

                                  List _enderecos = snapshot.data;

                                  return StreamBuilder<Map>(
                                    initialData: {},
                                    stream: widget.bloc.outEnderecoSelecionado,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) return CircularProgressIndicator();

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: _enderecos.map<Widget>(
                                          (v) {
                                            bool selected = v == snapshot.data;

                                            return Column(
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                CheckoutLocationAddress(
                                                  empresa.id,
                                                  v,
                                                  widget.bloc,
                                                  selected: selected,
                                                  disponivel: v['disponivel'] == '1',
                                                  custo: _custoEntrega,
                                                ),
                                              ],
                                            );
                                          },
                                        ).toList()
                                          ..add(FlatButton(
                                            onPressed: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutLocationNewAddress(empresa.id, widget.bloc, _apiBloc)));
                                            },
                                            child: Text('Adicionar endereço'),
                                            textColor: Colors.green,
                                          )),
                                      );
                                    },
                                  );
                                },
                              )
                            ],
                          ),
                        )
                      : Container(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
