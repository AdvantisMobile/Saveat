import 'package:flutter/material.dart';
import 'package:saveat/blocs/cart_bloc.dart';
import 'package:saveat/util.dart';

class CheckoutBuyTogetherTile extends StatelessWidget {

  const CheckoutBuyTogetherTile(this.empresaId, this.item, this.bloc);

  final String empresaId;
  final Map item;
  final CartBloc bloc;

  @override
  Widget build(BuildContext context) {

    item['quantidade'] = item['quantidade'] == null ? 0 : item['quantidade'];

    return Padding(
      padding: const EdgeInsets.only(left: 0, bottom: 16, right: 0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Text(item['produto']),
          ),
          Expanded(
            flex: 3,
            child: Text(
              maskValor(item['valor'].toString()),
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: 10),
          Opacity(
            opacity: item['quantidade'] == 0 ? 0.4 : 1,
            child: InkWell(
              onTap: item['quantidade'] == 0 ? null : (){
//                bloc.setCompreJunto(empresaId, item, (item['quantidade'] - 1));
              },
              child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  child: Icon(Icons.remove, size: 14,)
              ),
            ),
          ),
          Container(
            width: 30,
            child: Text(
              item['quantidade'].toString(),
              textAlign: TextAlign.center,
            ),
          ),
          Opacity(
            opacity: 1,
            child: InkWell(
              onTap: (){
//                bloc.setCompreJunto(empresaId, item, (item['quantidade'] + 1));
              },
              child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  child: Icon(Icons.add, size: 14,)
              ),
            ),
          ),
        ],
      ),
    );
  }
}
