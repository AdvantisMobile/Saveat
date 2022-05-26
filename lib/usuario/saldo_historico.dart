import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/usuario_provider.dart';
import 'package:saveat/util.dart';

class SaldoHistoricoWidget extends StatefulWidget {
  @override
  _SaldoHistoricoWidgetState createState() => _SaldoHistoricoWidgetState();
}

class _SaldoHistoricoWidgetState extends State<SaldoHistoricoWidget> with AutomaticKeepAliveClientMixin {

  UsuarioProvider usuarioProvider;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    usuarioProvider = Provider.of<UsuarioProvider>(context);

    if(!_loaded){
      _loaded = !_loaded;
      usuarioProvider.getHistoricoSaldo(context);
    }

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: (){
        return usuarioProvider.getHistoricoSaldo(context);
      },
      child: Consumer<UsuarioProvider>(
        builder: (context, snapshot, _){

          if(snapshot.isLoading){
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if(snapshot.usuarioHistoricoSaldo.length == 0){
            return emptyMessage(
              color: Colors.grey,
              icon: FontAwesomeIcons.wallet,
              title: 'nenhuma movimentação',
              subtitle: 'efetue uma recarga de saldo para fazer movimentações'
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Data',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 6,
                        child: Text(
                          'Movimentação',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Valor',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: snapshot.usuarioHistoricoSaldo.map<Widget>((v){
                      return Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Text(
                                dataHora(v['created']),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              flex: 6,
                              child: Text(
                                v['info'],
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: Text(
                                v['tipo'] == '1' ? '+ ${maskValor(v['valor'])}' : '- ${maskValor(v['valor'])}',
                                style: TextStyle(
                                  color: v['tipo'] == '1' ? Colors.lightGreen : Colors.redAccent
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                ],
              )
            ],
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
