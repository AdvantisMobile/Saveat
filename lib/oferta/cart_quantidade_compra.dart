import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/checkout_provider.dart';

import '../util.dart';

class CartQuantidadeCompra extends StatelessWidget {

  final Map item;
  CartQuantidadeCompra(this.item);

  @override
  Widget build(BuildContext context) {

    return Consumer<CheckoutProvider>(
      builder: (context, snapshot, _){

        Map checkout = snapshot.checkout;

        return Row(
          children: <Widget>[
            Opacity(
              opacity: checkout['quantidade'].toString() == '1' ? 0.4 : 1,
              child: InkWell(
                onTap: checkout['quantidade'].toString() == '1' ? null : (){
                  snapshot.atualizaQuantidade(2, double.tryParse(item['valor']));
                },
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Icon(Icons.remove)
                ),
              ),
            ),
            Container(
              width: 50,
              child: Text(
                checkout['quantidade'].toString(),
                textAlign: TextAlign.center,
              ),
            ),
            Opacity(
              opacity: checkout['quantidade'].toString() == item['quantidade_restante'].toString() ? 0.4 : 1,
              child: InkWell(
                onTap: checkout['quantidade'].toString() == item['quantidade_restante'].toString() ? null : (){
                  snapshot.atualizaQuantidade(1, double.tryParse(item['valor']));
                },
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Icon(Icons.add)
                ),
              ),
            ),
            Expanded(
              child: Text(
                maskValor(checkout['valor_produto'].toString()),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.right,
              ),
            )
          ],
        );
      },
    );
  }
}

