import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/acesso_provider.dart';

class CidadesPage extends StatefulWidget {
  @override
  _CidadesPageState createState() => _CidadesPageState();
}

class _CidadesPageState extends State<CidadesPage> {

  AcessoProvider cidadesProvider;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    cidadesProvider = Provider.of<AcessoProvider>(context);

    if(!_loaded){
      cidadesProvider.getCidades();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecione sua cidade'),
        elevation: 2,
      ),
      body: Consumer<AcessoProvider>(
        builder: (context, acesso, _){

          _loaded = true;

          if(acesso.cidades == null){
            return Container(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          List _cidades = acesso.cidades['data'];

          return ListView(
            padding: EdgeInsets.all(0),
            children: _cidades.map((v){
              return ListTile(
                leading: Icon(Icons.map),
                title: Text(v['cidade']),
                subtitle: Text(v['uf_nome']),
                onTap: () async {
                  bool res = await cidadesProvider.setCidadeAtual(context, v);
                  if(res){
                    if(Navigator.canPop(context))
                      Navigator.pop(context);

                    Navigator.pushReplacementNamed(context, '/');
                  }
                },
              );
            }).toList(),
          );

        },
      ),
    );
  }
}
