import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/acesso_provider.dart';
import 'package:saveat/provider/category_provider.dart';
import 'package:saveat/provider/offer_provider.dart';
import 'package:saveat/widgets/cards/card_categoria.dart';
import 'package:saveat/widgets/title-widget.dart';

class HomeCategorias extends StatefulWidget {
  @override
  _HomeCategoriasState createState() => _HomeCategoriasState();
}

class _HomeCategoriasState extends State<HomeCategorias> {

  CategoriasProvider provider;
  AcessoProvider acessoProvider;

  List _categorias;
  bool _loaded = false;
  double _height = 75;

  @override
  void didChangeDependencies() async {
    provider = Provider.of<CategoriasProvider>(context);

    AcessoProvider _acessoProvider = Provider.of<AcessoProvider>(context, listen: false);
    if(acessoProvider != _acessoProvider){
      acessoProvider = _acessoProvider;
      acessoProvider.getCidadeAtual(context).then((_) {
        if(provider.categorias.isEmpty){
          provider.getByCidade(acessoProvider.cidadeAtual['id']);
        }
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
          children: <Widget>[
            TitleWidget('Categorias'),
            Visibility(
              visible: provider.categoriaSelecionada != null,
              child: Positioned(
                top: 16,
                right: 8,
                child: InkWell(
                  onTap: (){
                    provider.categoriaSelecionada = null;

                    OfertasProvider providerOfertas = Provider.of<OfertasProvider>(context);
                    providerOfertas.categoria = '';
                    providerOfertas.clearOfertasHome();
                    providerOfertas.getHome(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Todas',
                      style: TextStyle(
                        color: Colors.grey
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        Consumer<CategoriasProvider>(
          builder: (context, item, child){
            _loaded = true;

            if(item.categorias.isEmpty){
              return Container(
                height: _height,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            _categorias = item.categorias;

            return Container(
              height: _height,
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, i){
                  return CardCategoria(_categorias[i], _height);
                },
                padding: EdgeInsets.symmetric(horizontal: 4),
                scrollDirection: Axis.horizontal,
                itemCount: _categorias?.length ?? 0,
              ),
            );
          },
        ),
      ],
    );
  }
}
