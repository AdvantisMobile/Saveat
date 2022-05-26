import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/usuario_provider.dart';
import 'package:saveat/usuario/pedidos_avaliacao_form.dart';
import 'package:screenshot_share_image/screenshot_share_image.dart';
import 'package:saveat/util.dart';

class PedidosDetalhesPage extends StatelessWidget {

  PedidosDetalhesPage(this.pedido);

  final Map pedido;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do pedido'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ScreenshotShareImage.takeScreenshotShareImage(),
        child: Icon(Icons.share),
        mini: true,
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          Visibility(
            visible: pedido['status']['id'] == '7' ? true : false,
            child: pedido['avaliacao'] == '' ? FlatButton.icon(
              onPressed: (){
                showAlertDialog(context: context, dialog: PedidosAvaliacaoFormPage(pedido));
              },
              icon: Icon(Icons.star, color: Colors.yellow[800], size: 20,),
              label: Text('Avaliar estabelecimento'),
            ) : bloco(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _text('Sua avaliação sobre o estabalecimento', dataHora(pedido['avaliacao']['data']), alignment: CrossAxisAlignment.center),
                    SizedBox(height: 15),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _text('Comida', Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.star, color: Colors.yellow[800], size: 20,),
                              SizedBox(width: 5),
                              Text(double.tryParse(pedido['avaliacao']['comida']).toString())
                            ],
                          ), alignment: CrossAxisAlignment.center),
                        ),
                        Expanded(
                          child: _text('Atendimento', Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.star, color: Colors.yellow[800], size: 20,),
                              SizedBox(width: 5),
                              Text(double.tryParse(pedido['avaliacao']['atendimento']).toString())
                            ],
                          ), alignment: CrossAxisAlignment.center),
                        ),
                        Expanded(
                          child: _text('Média', Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.star, color: Colors.yellow[800], size: 20,),
                              SizedBox(width: 5),
                              Text(double.tryParse(pedido['avaliacao']['media']).toString())
                            ],
                          ), alignment: CrossAxisAlignment.center),
                        )
                      ],
                    ),
                    pedido['avaliacao']['comentario'] == '' ? Container() : Column(
                      children: <Widget>[
                        SizedBox(height: 15,),
                        Text(pedido['avaliacao']['comentario']),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: <Widget>[
                        FlatButton(
                          child: Text('Alterar', style: TextStyle(fontSize: 12),),
                          textColor: Colors.green,
                          onPressed: (){
                            showAlertDialog(context: context, dialog: PedidosAvaliacaoFormPage(pedido));
                          },
                        ),
                        FlatButton(
                          child: Text('Excluir', style: TextStyle(fontSize: 12),),
                          textColor: Colors.red,
                          onPressed: () async {
                            await showAlertDialog2(
                                context: context,
                                dialog: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text('Excluir avaliação',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Text('Confirma a remoção da avaliação?'),
                                    SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        FlatButton(
                                          child: Text('Manter'),
                                          onPressed: (){
                                            Navigator.pop(context);
                                          },
                                        ),
                                        FlatButton(
                                          child: Text('Excluir'),
                                          textColor: Colors.red,
                                          onPressed: (){
                                            Provider.of<UsuarioProvider>(context, listen: false).deletarAvaliacao(context, pedido['avaliacao']['id']);
                                          },
                                        )
                                      ],
                                    ),
                                  ],
                                )
                            );
                          },
                        ),
                        pedido['avaliacao']['ativo'] == '1' ? Container() : Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text('Aguard. auditoria', style: TextStyle(fontSize: 12, color: Colors.blue[800]),),
                        )
                      ],
                    )
                  ],
                )
            ),
          ),
          bloco(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _text('ID', pedido['identificacao'])
                    ),
                    Expanded(
                      child: _text('Data da compra', dataHora(pedido['created']), alignment: CrossAxisAlignment.end)
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _text('Status', pedido['status']['nome']),
                    ),
                    Expanded(
                      child: _text('Data do status', dataHora(pedido['status']['data']), alignment: CrossAxisAlignment.end),
                    )
                  ],
                )
              ],
            )
          ),
          bloco(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: _text('Consumo', pedido['entrega']['tipo']['nome']),
                    ),
                    Expanded(
                      flex: 2,
                      child: pedido['entrega']['tipo']['id'] == '1' ?
                        _text('Prazo', pedido['entrega']['prazo'], alignment: CrossAxisAlignment.end) :
                        _text('Período', '${data(pedido['disponibilidade']['data'])} das ${hora(pedido['disponibilidade']['hora_ini'])} às ${hora(pedido['disponibilidade']['hora_fim'])}', alignment: CrossAxisAlignment.end),
                    )
                  ],
                ),
                SizedBox(height: 10),
                pedido['entrega']['tipo']['id'] == '1' ? Column(
                  children: <Widget>[
                    Text(getEndereco(pedido['entrega']['endereco'])),
                    SizedBox(height: 10),
                  ],
                ) : Container(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      pedido['empresa']['empresa'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(getEndereco(pedido['empresa'])),
                    SizedBox(height: 5),
                    Text(pedido['empresa']['telefone'])
                  ],
                ),
              ],
            )
          ),
          pedido['observacoes'] == '' ? Container() : bloco(
            child: _text('Observações', pedido['observacoes'])
          ),
          _pedido(pedido),
          pedido['historico'].length == 0 ? Container() : bloco(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Histórico de status',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 5,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: pedido['historico'].map<Widget>((v){
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: Text(
                              dataHora(v['data']),
                              style: TextStyle(
                                fontSize: 11
                              ),
                            ),
                          ),
                          SizedBox(width: 15,),
                          Expanded(
                            flex: 8,
                            child: Text(v['status_nome']),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _text(String title, dynamic text, {CrossAxisAlignment alignment}){
  return Column(
    crossAxisAlignment: alignment ?? CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        title,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      SizedBox(height: 5,),
      text is String ? Text(
        text.toString()
      ) : text
    ],
  );
}

Widget bloco({Widget child}){

  return Card(
    margin: EdgeInsets.only(top: 4, bottom: 4),
    child: Padding(
      padding: EdgeInsets.all(15),
      child: child,
    ),
  );

}

Widget _pedido(Map pedido){
  return bloco(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Pedido',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 5,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: pedido['itens'].map<Widget>((v){
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
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
          Divider(height: 20,),
          Row(
            children: <Widget>[
              Expanded(
                flex: 9,
                child: Text(
                  'Subtotal',
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                flex: 3,
                child: Text(
                  maskValor(pedido['valor']['subtotal']),
                  textAlign: TextAlign.right,
                )
              )
            ],
          ),
          double.tryParse(pedido['valor']['valor_cupom']) <= 0 ? Container() : Column(
            children: <Widget>[
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 9,
                    child: Text(
                      'Cupom ${pedido['cupom_info']['codigo']} (-)',
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                      flex: 3,
                      child: Text(
                        maskValor(pedido['valor']['valor_cupom']),
                        textAlign: TextAlign.right,
                      )
                  )
                ],
              ),
            ],
          ),
          double.tryParse(pedido['valor']['entrega']) <= 0 ? Container() : Column(
            children: <Widget>[
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 9,
                    child: Text(
                      'Entrega (+)',
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                      flex: 3,
                      child: Text(
                        maskValor(pedido['valor']['entrega']),
                        textAlign: TextAlign.right,
                      )
                  )
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                flex: 9,
                child: Text(
                  'Total (=)',
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                flex: 3,
                child: Text(
                  maskValor(pedido['valor']['total']),
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.right,
                )
              )
            ],
          )
        ],
      )
  );
}