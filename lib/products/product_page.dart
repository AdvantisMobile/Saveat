import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:provider/provider.dart';
import 'package:saveat/blocs/cart_bloc.dart';
import 'package:saveat/model/carrinho/item_carrinho.dart';
import 'package:saveat/model/empresa_model.dart';
import 'package:saveat/model/item.dart';
import 'package:saveat/model/produto_empresa_model.dart';
import 'package:saveat/model/produto_model.dart';
import 'package:saveat/model/produto_tipo_variacao.dart';
import 'package:saveat/model/produto_variacao_model.dart';
import 'package:saveat/provider/acesso_provider.dart';
import 'package:saveat/provider/offer_provider.dart';
import 'package:saveat/util.dart';
import 'package:sliver_fab/sliver_fab.dart';

class ProductPage extends StatefulWidget {
  ProductPage({
    this.item,
    this.empresa,
  });

  final Item item;
  final EmpresaModel empresa;

  @override
  _ProductPageState createState() => _ProductPageState(item, empresa);
}

class _ProductPageState extends State<ProductPage> {
  List<Widget> list;
  List<ProductVal> prodv;

  EmpresaModel empresa;
  double _freteGratisMinimo = 0;
  Item item;

  OfertasProvider ofertasProvider;
  AcessoProvider acessoProvider;

  CartBloc _cartBloc;

  var _scaffoldKey = GlobalKey<ScaffoldState>();

  _ProductPageState(
    this.item,
    this.empresa,
  );

  @override
  void didChangeDependencies() async {
    OfertasProvider _ofertasProvider = Provider.of<OfertasProvider>(context);
    if (ofertasProvider != _ofertasProvider) ofertasProvider = _ofertasProvider;

    AcessoProvider _acessoProvider = Provider.of<AcessoProvider>(context);
    if (acessoProvider != _acessoProvider) acessoProvider = _acessoProvider;

    final CartBloc cartBloc = Provider.of<CartBloc>(context);
    if (cartBloc != _cartBloc) _cartBloc = cartBloc;

    super.didChangeDependencies();
  }

  int tam = 0;

  int flavor = 0;
  bool isLoadedList = false;

  List<String> flavorsSelected = [];

  double totalValue = 0.0;
  List<double> valuePertipe = List();

  var _key = GlobalKey<ScaffoldState>();

  Widget attributes(ProdutoModel produtoModel) {
    if (!isLoadedList) {
      isLoadedList = true;
      prodv = List();
      valuePertipe = List();
      list = List();

      for (var i = 0; i < produtoModel.produtoTipoVariacao.length; i++) {
        ProductVal aux = ProductVal();
        aux.tipo = produtoModel.produtoTipoVariacao[i];
        for (var j = 0; j < produtoModel.produtoVariacao.length; j++) {
          if (produtoModel.produtoTipoVariacao[i].id == produtoModel.produtoVariacao[j].tipoVariacao) {
            aux.list.add(produtoModel.produtoVariacao[j]);
          }
        }

        if (aux.list.length > 0) {
          prodv.add(aux);
          valuePertipe.add(0.0);
          if (produtoModel.produtoTipoVariacao[i].multi == "0") {
            List<String> s = List();

            for (var w = 0; w < aux.list.length; w++) {
              s.add(aux.list[w].nome);
            }

            list.add(
              listRadio(
                  title: aux.tipo.nome,
                  labels: s,
                  callback: (String v) {
                    setState(() {
                      // flavor = quantidadeDeSabores.indexOf(v);
                    });
                  },
                  index: (prodv.length - 1)),
            );
          } else {
            List<String> s = List();

            for (var w = 0; w < aux.list.length; w++) {
              s.add(aux.list[w].nome);
            }

            list.add(listCheck(title: aux.tipo.nome, labels: s, index: (prodv.length - 1)));
          }
        }
      }
    }

    return list.length > 0
        ? Padding(
            padding: EdgeInsets.symmetric(
              vertical: 20,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (_, index) {
                return list[index];
              },
            ),
          )
        : Container();
  }

  Widget listRadio({String title, List<String> labels, Function callback, index = -1}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          shrinkWrap: true,
          primary: false,
          children: [
            Text(
              "$title",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).accentColor),
            ),
            RadioButtonGroup(labels: labels, onSelected: callback),
          ],
        ),
      ),
    );
  }

  Widget listCheck({String title, List<String> labels, index = -1}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          shrinkWrap: true,
          primary: false,
          children: [
            Text(
              "$title",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).accentColor,
              ),
            ),
            CheckboxGroup(
              labels: labels,
              //  disabled:  (flavor + 1) == flavorsSelected.length
              //    ?labels.where((element) => !flavorsSelected.contains(element)).toList()
              //    :null,
              onSelected: (List<String> checked) {
                prodv[index].list.forEach(
                  (element) {
                    if (checked.contains(element.nome)) {
                      valuePertipe[index] += double.parse(element.valor);
                    }

                    return false;
                  },
                );
                double auxValue = 0.0;
                for (var i = 0; i < valuePertipe.length; i++) {
                  auxValue += valuePertipe[i];
                }

                setState(
                  () {
                    totalValue = auxValue;
                    flavorsSelected = checked;
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future _getItem() {
    if (item.runtimeType == ProdutoEmpresaModel) {
      return ofertasProvider.getProduto(item.id);
    }

    return Future.value(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      backgroundColor: Colors.grey[200],
      body: FutureBuilder(
        future: _getItem(),
        builder: (context, snapshot) {
          print(snapshot);

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          ItemCarrinho itemCarrinho = snapshot.data;

          totalValue = itemCarrinho.valor;

          return Column(
            children: [
              Expanded(
                child: SliverFab(
                  floatingWidget: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[],
                  ),
                  floatingPosition: FloatingPosition(
                    left: 8,
                    top: -65,
                    right: 16,
                  ),
                  slivers: <Widget>[
                    SliverAppBar(
                      expandedHeight: 230,
                      floating: false,
                      pinned: true,
                      elevation: 0,
                      backgroundColor: Colors.grey[350],
                      iconTheme: IconThemeData(color: Colors.white),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Hero(
                          tag: 'tag-foto-${itemCarrinho.id}',
                          child: itemCarrinho.foto != null && itemCarrinho.foto.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: empresa.fotoAnuncio + itemCarrinho.foto,
                                  imageBuilder: (context, imageProvider) => Image(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  FontAwesomeIcons.leaf,
                                  color: Colors.green,
                                  size: 100,
                                ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              _freteGratisMinimo == 0
                                  ? Container()
                                  : Container(
                                      margin: EdgeInsets.only(bottom: 15),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.lightGreenAccent,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        'Entrega grátis para pedidos à partir de ${maskValor(_freteGratisMinimo.toString())}',
                                        style: TextStyle(fontSize: 14, color: Colors.black),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                              Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Text(
                                        'O QUE ESTOU SALVANDO?',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        itemCarrinho.nome ?? '',
                                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                      itemCarrinho.descricao == '' || itemCarrinho.descricao == null
                                          ? Container()
                                          : Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SizedBox(height: 10),
                                                Text(
                                                  itemCarrinho.descricao,
                                                  style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w100),
                                                ),
                                              ],
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                              itemCarrinho.runtimeType == ProdutoModel ? attributes(itemCarrinho) : Container(), //TODO verificar como retirar da function
                            ],
                          ),
                        )
                      ]),
                    ),
                  ],
                ),
              ),
              Container(
                height: 80,
                color: Theme.of(context).accentColor,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${maskValor(totalValue)}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      RaisedButton(
                        onPressed: () {
                          //TODO montar carrinho
                          try {
                            _cartBloc.setItem(empresa, itemCarrinho);
                            Navigator.pop(context);
                          } catch (e) {
                            showAlertDialog(
                              context: context,
                              dialog: AlertDialog(
                                title: Text("Ops"),
                                content: Text("Ocorreu um erro ao adicionar este produto ao seu pedido, desculpe pelo transtorno ^^\""),
                                actions: [
                                  FlatButton(
                                    onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/empresa')),
                                    child: Text("Voltar"),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Adicionar',
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 18,
                          ),
                        ),
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProductVal {
  ProdutoTipoVariacaoModel tipo;
  List<ProdutoVariacaoModel> list = List();
}
