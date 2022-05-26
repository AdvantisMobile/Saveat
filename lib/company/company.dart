import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saveat/blocs/api_bloc.dart';
import 'package:saveat/blocs/cart_bloc.dart';
import 'package:saveat/company/widgets/company_info_about.dart';
import 'package:saveat/model/carrinho/carrinho_model.dart';
import 'package:saveat/model/categoria_model.dart';
import 'package:saveat/model/empresa_model.dart';
import 'package:saveat/model/produto_empresa_model.dart';
import 'package:saveat/oferta/oferta_avaliacoes.dart';
import 'package:saveat/provider/acesso_provider.dart';
import 'package:saveat/provider/company_provider.dart';
import 'package:saveat/provider/location_provider.dart';
import 'package:saveat/provider/offer_provider.dart';
import 'package:saveat/provider/usuario_provider.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/cards/card_anuncio.dart';
import 'package:sliver_fab/sliver_fab.dart';

class CompanyPage extends StatefulWidget {
  CompanyPage(this.id);

  final String id;

  @override
  _CompanyPageState createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> with AutomaticKeepAliveClientMixin {
  String id;
  String _distance;
  String _idCategoriaSelecionada = CategoriaModel.ID_CATEGORIA_TODOS;
  bool _empresaPossuiSomenteUmaCategoriaAlemDeTodos = false;
  EmpresaModel empresa;

  AcessoProvider acessoProvider;
  CompanyProvider companyProvider;
  OfertasProvider providerOfertas;

  Future<EmpresaModel> _getEmpresa;

  CartBloc _cartBloc;

  List _tiposEntrega;

  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() async {
    print('didChangeDependencies');
    super.didChangeDependencies();

    id = widget.id;

    acessoProvider = Provider.of<AcessoProvider>(context);
    providerOfertas = Provider.of<OfertasProvider>(context);
    CompanyProvider _companyProvider = Provider.of<CompanyProvider>(context);

    CartBloc cartBloc = Provider.of<CartBloc>(context);
    if (cartBloc != _cartBloc) {
      _cartBloc = cartBloc;
    }

    if (_companyProvider != companyProvider) {
      companyProvider = _companyProvider;
      _getEmpresa = companyProvider.getEmpresa(context, id);
    }
  }

  Future<Null> getDistance(EmpresaModel empresa) async {
    // pega a localização do usuario e busca a distancia ate a empresa
    if (_distance == null) {
      Map res = await GetLocation().getDistanceEmpresa(id, empresa.latlng);

      if (res != null) {
        setState(() {
          _distance = res['distancia']['text'];
        });
      }
    }
  }

  void _buildSnackBar(context) {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    CarrinhoModel carrinhoEmpresa = _cartBloc.getCarrinhoDaEmpresa(id);

    if (carrinhoEmpresa == null) {
      return;
    }

    double valorTotal = _cartBloc.calcularValorItens(carrinhoEmpresa);

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: green,
      content: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/carrinho', arguments: {
            'empresa': empresa,
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(FontAwesomeIcons.shoppingBasket),
            Text('Finalizar compra'),
//            Text(maskValor(valorTotal.toString())),
            Text(maskValor(valorTotal.toString())),
          ],
        ),
      ),
      duration: Duration(days: 1),
    ));
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _buildSnackBar(context));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFF5F5F5),
      body: FutureBuilder<EmpresaModel>(
        initialData: null,
        future: _getEmpresa,
        builder: (context, snapshot) {
          print(snapshot);

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          empresa = snapshot.data;
          empresa.id = id;

          getDistance(empresa);

          _tiposEntrega = List();

          if (empresa.delivery) {
            _tiposEntrega.add(empresa.custoMinimo > 0 ? 'Delivery à partir de ${maskValor(empresa.custoMinimo.toString())}' : 'Delivery');
          }

          if (empresa.retirada) {
            _tiposEntrega.add('Retirada');
          }

          if (empresa.consumo) {
            _tiposEntrega.add('Consumo no local');
          }

          //eh menor que 2 por conta da existencia da categoria "todos" por padrao em todos os estabelecimentos
          _empresaPossuiSomenteUmaCategoriaAlemDeTodos = empresa.categorias.length <= 2;

          return SliverFab(
            floatingWidget: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                empresa.avaliacao == null || empresa.avaliacao == '0' || empresa.avaliacao.isEmpty
                    ? Container()
                    : Row(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => OfertaAvaliacoesPage(empresa.id)));
                            },
                            child: Container(
                              height: 30,
                              decoration: BoxDecoration(color: Colors.yellow[800], borderRadius: BorderRadius.circular(4)),
                              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 7),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    empresa.avaliacao,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                        ],
                      ),
                AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
                  opacity: _distance == null ? 0 : 1,
                  child: Visibility(
                    visible: _distance != null,
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: 30,
                          decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(4)),
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                          child: Row(
                            children: <Widget>[
                              Icon(FontAwesomeIcons.mapMarkerAlt, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                '$_distance',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 0)),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          child: CachedNetworkImage(
                            imageUrl: empresa.fotoBase + empresa.logo,
                            imageBuilder: (context, imageProvider) => Image(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            floatingPosition: const FloatingPosition(left: 8, top: -65, right: 16),
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 230,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.black38,
                iconTheme: IconThemeData(color: Colors.white),
                actions: <Widget>[
                  acessoProvider.usuarioLogado == null
                      ? Container()
                      : IconButton(
                          onPressed: () async {
                            UsuarioProvider usuarioProvider = Provider.of<UsuarioProvider>(context, listen: false);

                            Map res = empresa.favoritado ? await usuarioProvider.desfavoritarEmpresa(context, empresa.id) : await usuarioProvider.favoritarEmpresa(context, empresa.id);

                            Provider.of<ApiBloc>(context, listen: false).getEmpresasFavoritas();

                            _scaffoldKey.currentState.hideCurrentSnackBar();
                            _scaffoldKey.currentState.showSnackBar(
                              SnackBar(
                                content: Text(res['message']),
                                action: SnackBarAction(
                                  label: 'OK',
                                  onPressed: () {
                                    _scaffoldKey.currentState.hideCurrentSnackBar();
                                  },
                                ),
                              ),
                            );
                          },
                          icon: Icon(empresa.favoritado ? Icons.star : Icons.star_border, color: Colors.white),
                          tooltip: 'Favoritar empresa',
                        )
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl: empresa.fotoBase + empresa.foto,
                    imageBuilder: (context, imageProvider) => Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.only(top: 26, bottom: 60),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          empresa.entregaGratis == 0
                              ? Container()
                              : Container(
                                  margin: EdgeInsets.fromLTRB(8, 0, 8, 5),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.lightGreenAccent,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Text(
                                        'Entrega grátis para pedidos à partir de ${maskValor(empresa.entregaGratis.toString())}',
                                        style: TextStyle(fontSize: 14, color: Colors.black),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                          Column(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                alignment: _tiposEntrega.length < 3 ? Alignment.centerLeft : Alignment.center,
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 10,
                                  children: _tiposEntrega.map((tipoEntrega) {
                                    return Chip(
                                      label: Text(tipoEntrega),
                                      backgroundColor: Colors.green,
                                      labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                                    );
                                  }).toList(),
                                ),
                              ),
                              Divider(height: 10),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: CompanyInfoAbout(empresa),
                          ),
                          Divider(height: 10),
                          empresa.categorias.isEmpty || _empresaPossuiSomenteUmaCategoriaAlemDeTodos
                              ? Container()
                              : Container(
                                  height: 50,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: empresa.categorias.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        padding: EdgeInsets.all(10),
                                        child: InkWell(
                                          onTap: () => setState(() => _idCategoriaSelecionada = empresa.categorias[index].id),
                                          child: Row(
                                            children: <Widget>[
                                              AnimatedOpacity(
                                                child: Icon(
                                                  FontAwesomeIcons.leaf,
                                                  size: 16,
                                                  color: Colors.green,
                                                ),
                                                opacity: empresa.categorias[index].id == _idCategoriaSelecionada ? 1 : 0,
                                                duration: Duration(milliseconds: 500),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(left: 7),
                                                child: Text(
                                                  empresa.categorias[index].categoria,
                                                  style: TextStyle(fontSize: 18, color: Colors.green),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                          empresa.anuncios.isEmpty
                              ? Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: emptyMessage(
                                      title: '',
                                      subtitle: 'Nenhuma oferta encontrada no momento',
                                      icon: FontAwesomeIcons.piggyBank,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: empresa.anuncios.length,
                                  itemBuilder: (context, index) {
                                    if (index % 2 == 0) {
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          CardAnuncio(
                                            anuncio: empresa.anuncios[index],
                                            empresa: empresa,
                                            fotoBase: empresa.fotoAnuncio,
                                          ),
                                          index < empresa.anuncios.length - 1
                                              ? CardAnuncio(
                                                  anuncio: empresa.anuncios[index + 1],
                                                  empresa: empresa,
                                                  fotoBase: empresa.fotoAnuncio,
                                                )
                                              : Container(),
                                        ],
                                      );
                                    }

                                    return Container();
                                  },
                                ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: empresa.categorias.map((categoria) {
                              if (categoria.id != _idCategoriaSelecionada && _idCategoriaSelecionada != CategoriaModel.ID_CATEGORIA_TODOS) {
                                return Container();
                              }

                              if (categoria.id == CategoriaModel.ID_CATEGORIA_TODOS && categoria.produtos.isEmpty) {
                                return Container();
                              }

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _empresaPossuiSomenteUmaCategoriaAlemDeTodos
                                      ? Container()
                                      : Container(
                                          margin: EdgeInsets.only(
                                            left: 25,
                                          ),
                                          child: Text(
                                            categoria.categoria,
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: categoria.produtos.length,
                                    itemBuilder: (context, index) {
                                      ProdutoEmpresaModel produto = categoria.produtos[index];

                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                              width: 1,
                                              color: Colors.grey[300],
                                            ),
                                          ),
                                        ),
                                        child: ListTile(
                                          onTap: () async {
                                            await Navigator.pushNamed(context, '/oferta', arguments: {
                                              'item': produto,
                                              'empresa': empresa,
                                            });
                                            _buildSnackBar(context);
                                          },
                                          isThreeLine: true,
                                          title: Text(produto.produto),
                                          subtitle: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(produto.descricao),
                                              Text(maskValor(produto.valor)),
                                            ],
                                          ),
                                          leading: Container(
                                            height: 50,
                                            width: 50,
                                            child: CachedNetworkImage(
                                              imageUrl: empresa.fotoBase + produto.foto,
                                              imageBuilder: (context, imageProvider) => Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) => Icon(
                                                FontAwesomeIcons.leaf,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                ],
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
