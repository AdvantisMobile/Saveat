import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/acesso_provider.dart';
import 'package:saveat/provider/company_provider.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/cards/card_estabelecimento.dart';
import 'package:saveat/widgets/title-widget.dart';

class HomeEstabelecimentos extends StatefulWidget {
  @override
  _HomeEstabelecimentosState createState() => _HomeEstabelecimentosState();
}

class _HomeEstabelecimentosState extends State<HomeEstabelecimentos> {
  bool _loaded = false;

  @override
  void didChangeDependencies() async {
    if (!_loaded) {
      await Provider.of<AcessoProvider>(context, listen: false).getCidadeAtual(context);
      Provider.of<CompanyProvider>(context, listen: false).getAll();
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Column(
        children: <Widget>[
          TitleWidget(
            'Restaurantes',
            marginTop: 0,
            action: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/empresas');
              },
              child: Text(
                'Ver todos',
                style: TextStyle(
                  color: green,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          Consumer<CompanyProvider>(
            builder: (context, company, _) {
              _loaded = true;

              if (company.estabelecimentos == null) {
                return Container(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              List _empresas = company.estabelecimentos['data'];

              if (_empresas.length == 0) {
                return Container();
              }

              return Column(
                children: _empresas.map((v) {
                  return CardEstabelecimento(
                    empresa: v,
                    fotoBase: company.estabelecimentos['total']['foto_base'],
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
