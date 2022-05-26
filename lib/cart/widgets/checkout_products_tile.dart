import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saveat/blocs/cart_bloc.dart';
import 'package:saveat/model/carrinho/item_carrinho.dart';
import 'package:saveat/util.dart';

class CheckoutProductsTile extends StatelessWidget {
  CheckoutProductsTile(this.item, this.bloc, this.empresaId);

  final ItemCarrinho item;
  final CartBloc bloc;
  final String empresaId;

  void removerProduto() {
    if (item.quantidade <= 1) {
      return;
    }

    bloc.atualizarQuantidade(empresaId, item, (item.quantidade - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 13,
      ),
      child: Stack(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              item.foto != null && item.foto.trim() != ''
                  ? CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        item.foto,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.green,
                      ),
                      height: 80,
                      width: 80,
                      child: Icon(
                        FontAwesomeIcons.leaf,
                        color: Colors.white,
                      ),
                    ),
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.nome,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              Text(
                                maskValor(item.valor),
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            InkWell(
                              onTap: removerProduto,
                              child: Container(
                                width: 30,
                                height: 30,
                                child: Center(
                                  child: Text(
                                    '-',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: item.quantidade <= 1 ? Colors.grey : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 30,
                              height: 30,
                              child: Center(
                                child: Text(
                                  item.quantidade.toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
          Positioned(
            top: -12,
            right: -12,
            child: IconButton(
              onPressed: () {
                confirm(
                  context: context,
                  title: 'Que pena!',
                  message: 'Confirma a remoção de ${item.nome}?',
                  confirm: FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      bloc.deleteItem(empresaId, item);
                    },
                    child: Text('Sim, remover'),
                    textColor: Colors.red,
                  ),
                  cancel: FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Manter'),
                  ),
                );
              },
              icon: Icon(
                FontAwesomeIcons.trash,
                size: 12,
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
    );
  }
}
