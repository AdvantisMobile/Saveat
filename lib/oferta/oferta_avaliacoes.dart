import 'package:flutter/material.dart';
import 'package:saveat/provider/offer_provider.dart';
import 'package:saveat/widgets/comentarios.dart';

class OfertaAvaliacoesPage extends StatefulWidget {

  final String empresaId;

  OfertaAvaliacoesPage(this.empresaId);

  @override
  _OfertaAvaliacoesPageState createState() => _OfertaAvaliacoesPageState();
}

class _OfertaAvaliacoesPageState extends State<OfertaAvaliacoesPage> {

  double _nota;
  List _itens;
  bool _loading = true;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    Map res = await OfertasProvider().getAvaliacoesEmpresa(widget.empresaId);

    setState(() {
      _nota = double.tryParse(res['nota']);
      _itens = res['itens'];
      _loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Avaliações'),
        elevation: 2,
      ),
      body: _loading ? Center(
          child: CircularProgressIndicator(),
        ) : ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.star, size: 80, color: Colors.yellow[800],),
                  SizedBox(width: 15,),
                  Text(
                    _nota.toString(),
                    style: TextStyle(
                      fontSize: 80
                    ),
                  )
                ],
              ),
              Divider(height: 30),
              Column(
                children: _itens.map<Widget>((v){
                  return ComentariosWidget(v);
                }).toList(),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
