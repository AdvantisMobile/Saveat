import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/checkout_provider.dart';
import 'package:saveat/provider/usuario_provider.dart';
import 'package:saveat/usuario/enderecos_form.dart';

import '../util.dart';

class CartEntrega extends StatefulWidget {

  final Map item;
  final ScrollController scrollController;

  CartEntrega(this.item, this.scrollController);

  @override
  _CartEntregaState createState() => _CartEntregaState();
}

class _CartEntregaState extends State<CartEntrega> {

  UsuarioProvider usuarioProvider;
  List _enderecos;

  double _custoMinimoDelivery;
  double _valorFreteGratis;

  @override
  void didChangeDependencies() {

    usuarioProvider = Provider.of<UsuarioProvider>(context);
    _enderecos = usuarioProvider.usuarioEnderecos;

    _custoMinimoDelivery = double.tryParse(widget.item['empresa']['delivery']['custo_minimo']);
    _valorFreteGratis = double.tryParse(widget.item['empresa']['delivery']['frete_gratis']);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'CONSUMO',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 18
          ),
        ),
        SizedBox(height: 10),
        Consumer<CheckoutProvider>(
          builder: (context, snapshot, _){
            double _valorCompra = snapshot.checkout['valor_compra'];
            double _custoEntrega = double.tryParse(snapshot.checkout['entrega_custo'].toString());

            Widget _botao(String tipo, String label){

              bool _canDelivery = _custoMinimoDelivery <= 0 && _valorCompra >= _custoMinimoDelivery && tipo != '1';

              return Container(
                height: 35,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: snapshot.checkout['entrega_tipo'] == tipo ? Colors.green : Colors.grey[300],
                    width: 1
                  ),
                  borderRadius: BorderRadius.circular(30)
                ),
                child: FlatButton(
                  onPressed: !_canDelivery ? null : (){
                    snapshot.atualizaEntrega(tipo);

                    if(tipo == '1' && _enderecos.length == 0) {
                      usuarioProvider.getEnderecos(context, origin: widget.item['empresa']['id']);
                    }
                  },
                  color: snapshot.checkout['entrega_tipo'] == tipo ? Colors.green : Colors.white,
                  textColor: snapshot.checkout['entrega_tipo'] == tipo ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)
                  ),
                  child: Text(label),
                ),
              );
            }

            Widget _tiposFrete(){
              if(snapshot.checkout['entrega_tipo'] == '1'){
                Map _enderecoSelecionado = snapshot.checkout['entrega_endereco'];

                String mensagem = '...';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 15),
                    Text(
                      mensagem,
                      style: TextStyle(
                        color: Colors.blue
                      ),
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _enderecos.map<Widget>((v){

                        String _custo = v['custo'];

                        if(_valorFreteGratis > 0 && _valorCompra - _custoEntrega >= _valorFreteGratis)
                          _custo = '0';

                        return FlatButton.icon(
                          onPressed: v['disponivel'] != '1' ? null : (){
                            snapshot.atualizaEntregaEndereco(v, double.tryParse(_custo));
                            //widget.scrollController.animateTo(MediaQuery.of(context).size.height, duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                          },
                          icon: Icon(_enderecoSelecionado == v ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                          label: Expanded(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    '${v['endereco']}, ${v['endnum']}${separa(string: v['complemento'], separator: ' ')}'
                                        + '\n${v['bairro']} - ${v['cidade']} - ${v['uf']}',
                                  ),
                                ),
                                SizedBox(width: 10),
                                v['disponivel'] != '1' ? Text(
                                  'Indisponível',
                                  style: TextStyle(
                                    color: Colors.red.withOpacity(0.5)
                                  ),
                                  ) : Text(
                                  maskValor(_custo),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold
                                  ),
                                )
                              ],
                            ),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                        );
                      }).toList()..add(
                        FlatButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EnderecosFormPage(origin: widget.item['empresa']['id'])));
                          },
                          child: Text('Adicionar endereço'),
                          textColor: Colors.green,
                        )
                      ),
                    ),
                  ],
                );
              }

              if(snapshot.checkout['entrega_tipo'] == '2' || snapshot.checkout['entrega_tipo'] == '3'){
                String mensagem = snapshot.checkout['entrega_tipo'] == '2' ? 'Você deverá retirar sua compra dentro do prazo válido em:' : 'O consumo deverá ser dentro dentro do prazo válido em:';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 15),
                    Text(
                      mensagem,
                      style: TextStyle(
                        color: Colors.blue
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.item['empresa']['empresa'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      getEndereco(widget.item['empresa'])
                    ),
                    SizedBox(height: 5),
                    Text(widget.item['empresa']['telefone']),
                  ],
                );
              }

              return Container();

            }

            List<Widget> _botoesDelivery(){
              List<Widget> out = List<Widget>();

              if(widget.item['delivery'] == '1' && (_custoMinimoDelivery == 0 || (_custoMinimoDelivery > 0 && _valorCompra >= _custoMinimoDelivery)))
                out.add(_botao('1', 'DELIVERY'));

              if(widget.item['retirada'] == '1')
                out.add(_botao('2', 'RETIRADA'));

              if(widget.item['consumo'] == '1')
                out.add(_botao('3', 'CONSUMO NO LOCAL'));

              return out;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  runSpacing: 10,
                  spacing: 10,
                  children: _botoesDelivery().map((v){
                    return v;
                  }).toList(),
                ),
                _tiposFrete(),
              ],
            );
          },
        )
      ],
    );
  }
}
