import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/offer_provider.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/cards/card_anuncio.dart';
import 'package:saveat/widgets/title-widget.dart';

class HomeOfertas extends StatefulWidget {

  HomeOfertas(this.provider, {this.limitHome: '20', this.marginTop: 0});

  final OfertasProvider provider;
  final String limitHome;
  final double marginTop;

  @override
  _HomeOfertasState createState() => _HomeOfertasState();
}

class _HomeOfertasState extends State<HomeOfertas> {

  bool _loaded = false;
  OfertasProvider provider;

  @override
  void didChangeDependencies() {
    provider = widget.provider;

    if(!_loaded){
      provider.ofertasHome = null;
      provider.getHome(context);
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TitleWidget(
          'Ofertas para você salvar',
          marginTop: widget.marginTop,
          action: InkWell(
            onTap: (){
              Navigator.pushNamed(context, '/ofertas', arguments: {
                'provider': provider,
              });
            },
            child: Text(
              'Ver todas',
              style: TextStyle(
                color: green,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        Consumer<OfertasProvider>(
          builder: (context, item, _){
            _loaded = true;

            if(item.ofertasHome == null){
              return Container(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            List ofertas = item.ofertasHome['data'];

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
              children: ofertas.map((v){
                return CardAnuncio(
                  anuncio: v,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}