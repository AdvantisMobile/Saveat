import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/checkout_provider.dart';

import '../util.dart';

class CartCompreJunto extends StatelessWidget {

  final Map item;

  CartCompreJunto(this.item);

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckoutProvider>(
      builder: (context, snapshot, _){

        List<Widget> _children = List();

        if(snapshot.compreJunto.length == 0){
          _children.add(Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'Nenhum produto disponível',
              style: TextStyle(
                color: Colors.red
              ),
              textAlign: TextAlign.center,
            ),
          ));
        }else{
          _children = snapshot.compreJunto.map((v){

            int _index = snapshot.checkout['compreJunto'].indexWhere((item) => item['id'] == v['id']);
            int _quantidade = 0;

            if(_index > -1){
              _quantidade = snapshot.checkout['compreJunto'][_index]['quantidade'];
            }

            return Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 16, right: 10),
              child: Row(
                children: <Widget>[
                  Opacity(
                    opacity: _quantidade == 0 ? 0.4 : 1,
                    child: InkWell(
                      onTap: _quantidade == 0 ? null : (){
                        snapshot.atualizaQuantidadeCompreJunto(2, v);
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
                      _quantidade.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Opacity(
                    opacity: 1,
                    child: InkWell(
                      onTap: (){
                        snapshot.atualizaQuantidadeCompreJunto(1, v);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        child: Icon(Icons.add, size: 14,)
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 6,
                    child: Text(v['produto']),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      maskValor(v['valor'].toString()),
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.right,
                    ),
                  )
                ],
              ),
            );
          }).toList();
        }

        return ListTileTheme(
          contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              title: Text(
                'COMPRE JUNTO',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18
                ),
                textAlign: TextAlign.left,
              ),
              onExpansionChanged: (b) async {
                if(b && snapshot.compreJunto.length == 0){
                  showLoading(context);
                  await snapshot.getProdutosCompreJunto(item['empresa']['id']);
                  hideLoading(context);
                }
              },
              children: _children.toList(),
            ),
          ),
        );
      },
    );
  }
}
