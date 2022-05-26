import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/acesso_provider.dart';
import 'package:saveat/provider/company_provider.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/cards/card_estabelecimento.dart';

class CompanyListPage extends StatefulWidget {
  @override
  _CompanyListPageState createState() => _CompanyListPageState();
}

class _CompanyListPageState extends State<CompanyListPage> {

  var _key = GlobalKey<ScaffoldState>();

  bool _isEmpresas = false;
  Future<List> _empresas;

  @override
  void didChangeDependencies() {
    getEmpresas();

    super.didChangeDependencies();
  }

  getEmpresas() {
    if(!_isEmpresas) {
      _isEmpresas = true;
      _empresas = Provider.of<CompanyProvider>(context).getAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      body: CustomScrollView(
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    ),
                  );
                }

                return Text('Empresas de ${acesso.cidadeAtual['cidade']}, ${acesso.cidadeAtual['uf']}');
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
                    future: _empresas,
                    builder: (BuildContext context, AsyncSnapshot snapshot){

                      if(!snapshot.hasData){
                        return Container(
                          height: 100,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      List empresas = snapshot.data;

                      if(empresas.length == 0){
                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: emptyMessage(
                            title: '',
                            subtitle: 'Nenhuma empresa encontrada no momento',
                            icon: FontAwesomeIcons.piggyBank,
                            color: Colors.grey
                          ),
                        );
                      }

                      return Column(
                        children: empresas.map((item){
                          return CardEstabelecimento(empresa: item, fotoBase: '',);
                        }).toList(),
                      );
                    },
                  ),
                ),
              )
            ]),
          )
        ],
      ),
    );
  }
}
