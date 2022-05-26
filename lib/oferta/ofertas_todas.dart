import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/acesso_provider.dart';
import 'package:saveat/provider/offer_provider.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/cards/card_anuncio.dart';

class OfertasTodasPage extends StatefulWidget {

  OfertasTodasPage(this.provider);

  final OfertasProvider provider;

  @override
  _OfertasTodasPageState createState() => _OfertasTodasPageState();
}

class _OfertasTodasPageState extends State<OfertasTodasPage> {

  var _key = GlobalKey<ScaffoldState>();

  OfertasProvider providerOfertas;

  bool _isOfertas = false;
  Future<List> _ofertas;

  @override
  void didChangeDependencies() {
    getOfertas();

    super.didChangeDependencies();
  }

  getOfertas() {
    if(!_isOfertas) {
      _isOfertas = true;
      providerOfertas = widget.provider;
      _ofertas = providerOfertas.getHomeAll(context, mostraIndisponivel: '1', quantidade: '0');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            pinned: false,
            forceElevated: true,
            title: Consumer<AcessoProvider>(
              builder: (context, item, _) {
                if (item.cidadeAtual == null) {
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    ),
                  );
                }

                Map _cidade = item.cidadeAtual;

                return Text('Ofertas para ${_cidade['cidade']}, ${_cidade['uf']}');
              },
            ),
            elevation: 0,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.only(top: 5),
                  child: FutureBuilder<List>(
                    initialData: [],
                    future: _ofertas,
                    builder: (BuildContext context, AsyncSnapshot snapshot){

                      if(!snapshot.hasData){
                        return Container(
                          height: 100,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      List ofertas = snapshot.data;

                      if(ofertas.length == 0){
                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: emptyMessage(
                            title: '',
                            subtitle: 'Nenhuma oferta encontrada no momento',
                            icon: FontAwesomeIcons.piggyBank,
                            color: Colors.grey
                          ),
                        );
                      }

                      return Column(
                        children: ofertas.map((item){
                          return CardAnuncio(
                            anuncio: item,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ]),
          )
        ],
      ),
    );
  }

}
