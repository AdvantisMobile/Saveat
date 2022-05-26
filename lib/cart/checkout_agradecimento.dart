import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saveat/blocs/api_bloc.dart';
import 'package:saveat/util.dart';
import 'package:screenshot_share_image/screenshot_share_image.dart';

class CheckoutAgradecimento extends StatefulWidget {

  CheckoutAgradecimento(this.pedidoId);

  final String pedidoId;

  @override
  _CheckoutAgradecimentoState createState() => _CheckoutAgradecimentoState();
}

class _CheckoutAgradecimentoState extends State<CheckoutAgradecimento> {

  ApiBloc _apiBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    ApiBloc apiBloc = Provider.of<ApiBloc>(context, listen: false);
    if(apiBloc != _apiBloc){
      _apiBloc = apiBloc;
      _apiBloc.getPedidoCliente(widget.pedidoId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map>(
      stream: _apiBloc.outPedidocliente,
      builder: (context, snapshot) {

        if(!snapshot.hasData || snapshot.connectionState != ConnectionState.active){
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        Map pedido = snapshot.data;
        
        return Scaffold(
          appBar: AppBar(
            title: Text('Pedido realizado'),
            elevation: 0,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => ScreenshotShareImage.takeScreenshotShareImage(),
            child: Icon(Icons.share),
            mini: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(13),
            children: <Widget>[
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.checkCircle,
                      size: 100,
                      color: green,
                    ),
                    SizedBox(height: 25),
                    Text(
                      '${pedido['cliente']['nome']}\nrecebemos seu pedido!',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Text(
                      dataHora(pedido['created']),
                      style: TextStyle(
                        color: Colors.grey
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      pedido['identificacao'],
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: green
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                  ),
                  child: Column(
                    children: <Widget>[
                      pedido['entrega']['tipo']['id'] == '1' ? RichText(
                        text: TextSpan(
                          text: 'Após aprovado seu pedido será entregue dentro de ',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Montserrat',
                            fontSize: 14
                          ),
                          children: [
                            TextSpan(
                              text: '${pedido['entrega']['prazo']}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold
                              )
                            ),
                            TextSpan(
                              text: '\n\n${getEndereco(pedido['entrega']['endereco'])}'
                            )
                          ]
                        ),
                        textAlign: TextAlign.center,
                      ) : Text(
                        'Você deve retirá-lo até dia ${data(pedido['disponibilidade']['data'])}\ndas ${hora(pedido['disponibilidade']['hora_ini'])} às ${hora(pedido['disponibilidade']['hora_fim'])}',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 15),
                      Text(
                        pedido['empresa']['empresa'],
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        getEndereco(pedido['empresa']),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        pedido['empresa']['telefone'],
                      ),
                    ],
                  )
              ),
              SizedBox(height: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Pagamento',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12
                          ),
                        ),
                        Text(
                          pedido['pagamento']['nome'],
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Status do pagamento',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12
                          ),
                        ),
                        Text(
                          pedido['status']['nome'],
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: pedido['itens'].map<Widget>((v){
                  return Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 9,
                            child: Text(
                              '${v['quantidade']}x ${v['nome']}',
                              textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            flex: 3,
                            child: Text(
                              maskValor(v['valor_parcial']),
                              textAlign: TextAlign.right,
                            ),
                          )
                        ],
                      )
                  );
                }).toList(),
              ),
              SizedBox(height: 15),
              Row(
                children: <Widget>[
                  double.tryParse(pedido['valor']['entrega']) == 0 ? Container() : Expanded(
                    flex: 4,
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Subtotal',
                          style: TextStyle(
                            color: Colors.grey
                          ),
                        ),
                        Text(
                          maskValor(pedido['valor']['subtotal']),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                  ),
                  double.tryParse(pedido['valor']['valor_cupom']) == 0 ? Container() : Expanded(
                    flex: 4,
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Cupom (-)',
                          style: TextStyle(
                            color: Colors.grey
                          ),
                        ),
                        Text(
                          maskValor(pedido['valor']['valor_cupom']),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                  ),
                  double.tryParse(pedido['valor']['entrega']) == 0 ? Container() : Expanded(
                    flex: 4,
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Entrega (+)',
                          style: TextStyle(
                            color: Colors.grey
                          ),
                        ),
                        Text(
                          maskValor(pedido['valor']['entrega']),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Pedido',
                          style: TextStyle(
                              color: Colors.grey
                          ),
                        ),
                        Text(
                          maskValor(pedido['valor']['total']),
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              pedido['observacoes'] == '' ? Container() : Column(
                children: <Widget>[
                  SizedBox(height: 15),
                  Center(
                      child: Text(pedido['observacoes'], textAlign: TextAlign.center,)
                  ),
                ],
              ),
              SizedBox(height: 25),
              Center(
                child: FlatButton(
                  child: Text('Ver detalhes do pedido'),
                  color: green,
                  textColor: Colors.white,
                  onPressed: (){
                    Navigator.pushReplacementNamed(context, '/pedidos');
                  },
                ),
              )
            ],
          ),
        );
      }
    );
  }
}
