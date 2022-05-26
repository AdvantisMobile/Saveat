import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saveat/home/widgets/layout-divisor.dart';
import 'package:saveat/provider/acesso_provider.dart';
import 'package:saveat/provider/category_provider.dart';
import 'package:saveat/provider/company_provider.dart';
import 'package:saveat/provider/offer_provider.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/drawer.dart';
import 'package:saveat/widgets/home_filtro_horario.dart';

import 'widgets/home-categorias.dart';
import 'widgets/home-estabelecimentos.dart';
import 'widgets/home-ofertas.dart';
import 'widgets/search.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _key = GlobalKey<ScaffoldState>();
  String _result = '';

  AcessoProvider acessoProvider;
  OfertasProvider providerOfertas;
  CompanyProvider providerEstabelecimento;

  @override
  void didChangeDependencies() {
    AcessoProvider _acessoProvider = Provider.of<AcessoProvider>(context, listen: false);
    if(acessoProvider != _acessoProvider){
      acessoProvider = _acessoProvider;
      acessoProvider.getCidadeAtual(context);
    }

    OfertasProvider _providerOfertas = Provider.of<OfertasProvider>(context, listen: false);
    if(providerOfertas != _providerOfertas)
      providerOfertas = _providerOfertas;

    CompanyProvider _providerEstabelecimento = Provider.of<CompanyProvider>(context, listen: false);
    if(providerEstabelecimento != providerEstabelecimento)
      providerEstabelecimento = _providerEstabelecimento;

    // administra as notificações que chegam do onesignal
    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      Map notify = result.notification.payload.additionalData;

      String page = notify['page'] ?? '';

      if (acessoProvider.usuarioLogado != null) {
        if (page == 'order') {
          Navigator.pushNamed(context, '/pedidos');
        } else if (page == 'balance') {
          Navigator.pushNamed(context, '/saldo');
        }
      }
    });

    super.didChangeDependencies();
  }

  Future<bool> _onBackPressed(){

    if(_key?.currentState?.isDrawerOpen == true){
      Navigator.pop(context);
      return null;
    }

    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Deseja fechar o SavEat?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Agora não'),
              onPressed: () => Navigator.pop(context, false),
              textColor: Colors.black,
            ),
            FlatButton(
              child: Text('SIM'),
              onPressed: () => Navigator.pop(context, true),
              textColor: Colors.red,
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: _key,
        drawer: DrawerWidget(),
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: () async {
            await Provider.of<AcessoProvider>(context, listen: false).getCidadeAtual(context);
            await Provider.of<OfertasProvider>(context, listen: false).getHome(context);
            return await Provider.of<CompanyProvider>(context, listen: false).getAll();
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                floating: true,
                pinned: false,
                forceElevated: true,
                title: Consumer<AcessoProvider>(
                  builder: (context, acesso, _) {
                    if (acesso.cidadeAtual == null) {
                      return Container(
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white)),
                        ),
                      );
                    }

                    Map _cidade = acesso.cidadeAtual;

                    return Text('${_cidade['cidade']}, ${_cidade['uf']}');
                  },
                ),
                actions: <Widget>[
                  IconButton(
                    onPressed: () async {
                      String result = await showSearch(
                        context: context,
                        delegate: SearchPage(cidade: acessoProvider.cidadeAtual['id']),
                        query: _result,
                      );

                      if (result != null) {
                        _result = result;

                        Provider.of<CategoriasProvider>(context, listen: false).categoriaSelecionada = null;

                        providerOfertas.categoria = '';
                        providerOfertas.query = _result;
                        providerOfertas.getHome(context);
                      }
                    },
                    icon: Icon(Icons.search),
                  )
                ],
                elevation: 0,
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  SafeArea(
                    top: false,
                    child: Column(
                      children: <Widget>[
                        Visibility(
                          visible: _result == '' ? false : true,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 16, left: 16, right: 16, bottom: 0
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'Resultados para ',
                                      children: [
                                        TextSpan(
                                          text: _result,
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: green,
                                            decoration: TextDecoration.underline
                                          ),
                                        )
                                      ]
                                    )
                                  ),
                                ),
                                SizedBox(width: 10),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _result = '';
                                    });

                                    providerOfertas.query = '';
                                    providerOfertas.getHome(context);
                                  },
                                  child: Text(
                                    'Limpar',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        HomeCategorias(),
                        LayoutDivisor(margin: EdgeInsets.only(bottom: 15),),
                        HomeEstabelecimentos(),
                      ],
                    ),
                  ),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
