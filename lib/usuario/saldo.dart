import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/acesso_provider.dart';
import 'package:saveat/usuario/saldo_historico.dart';
import 'package:saveat/usuario/saldo_recargas.dart';
import 'package:saveat/util.dart';

class SaldoPage extends StatefulWidget {
  @override
  _SaldoPageState createState() => _SaldoPageState();
}

class _SaldoPageState extends State<SaldoPage> {

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(116),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Saldo atual',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12
                        ),
                      ),
                      Consumer<AcessoProvider>(
                        builder: (context, snapshot, _) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              maskValor(snapshot?.usuarioLogado['saldo'].toString()),
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.white
                              ),
                            ),
                            IconButton(
                              onPressed: (){
                                snapshot.saldoRefresh();
                              },
                              icon: Icon(Icons.refresh, color: Colors.white70),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                TabBar(
                  isScrollable: false,
                  tabs: <Widget>[
                    Tab(text: 'Histórico'),
                    Tab(text: 'Recargas'),
                  ],
                )
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            SaldoHistoricoWidget(),
            SaldoRecargasWidget(),
          ],
        ),
      ),
    );

  }
}