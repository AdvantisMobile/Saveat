import 'package:flutter/material.dart';
import 'package:saveat/oferta/oferta_avaliacoes.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/comentarios.dart';

class CompanyAvaliacoesWidget extends StatelessWidget {

  const CompanyAvaliacoesWidget(this.id, this.total, this.itens);

  final String id;
  final String total;
  final List itens;

  @override
  Widget build(BuildContext context) {
    return total == '0' ? Container() : Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Avaliações do estabelecimento ($total)',
            style: TextStyle(
                color: Colors.yellow[800],
                fontSize: 15
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: itens.map<Widget>((v){
              return ComentariosWidget(v);
            }).toList()..add(
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: FlatButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => OfertaAvaliacoesPage(id)));
                    },
                    textColor: green,
                    child: Text('Ver todas avaliações do estabelecimento'),
                  ),
                )
            ),
          ),
        ],
      ),
    );
  }
}
