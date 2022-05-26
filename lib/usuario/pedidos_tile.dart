import 'package:flutter/material.dart';
import 'package:saveat/usuario/pedidos_detalhes.dart';
import 'package:saveat/util.dart';

class PedidosTile extends StatelessWidget {

  final Map item;

  PedidosTile(this.item);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => PedidosDetalhesPage(item)));
        },
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      dataHora(item['created']),
                      style: TextStyle(
                        color: Colors.grey
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Text(
                    item['identificacao'],
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: ''
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${item['itens'][0]['quantidade']}x ${item['itens'][0]['nome']}',
                    ),
                  ),
                  item['itens'].length > 1 ? Text('+ ${item['itens'].length - 1}') : Container()
                ],
              ),
              SizedBox(height: 10),
              Text(
                item['empresa'] != '' ? item['empresa']['empresa'] : '',
                style: TextStyle(
                    fontWeight: FontWeight.w600
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      item['status']['nome'],
                    ),
                  ),
                  SizedBox(width: 15),
                  Text(
                    maskValor(item['valor']['total']),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: green
                    ),
                  ),
                ],
              ),
              item['avaliacao'] == '' || 1 == 1 ? Container() : Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Icon(Icons.star, color: Colors.yellow[800], size: 20,),
                      SizedBox(width: 5),
                      Text(double.tryParse(item['avaliacao']['media']).toString()),
                      SizedBox(width: 15),
                      item['avaliacao']['ativo'] == '1' ? Container() : Text('Avaliação aguardando auditoria', style: TextStyle(fontSize: 12, color: Colors.red[400]),)
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
