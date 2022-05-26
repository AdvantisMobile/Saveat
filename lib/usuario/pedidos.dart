import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/usuario_provider.dart';
import 'package:saveat/usuario/pedidos_tile.dart';
import 'package:saveat/util.dart';

class PedidosPage extends StatefulWidget {
  @override
  _PedidosPageState createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {

  UsuarioProvider usuarioProvider;
  bool _loaded = false;

  @override
  void didChangeDependencies() {

    usuarioProvider = Provider.of<UsuarioProvider>(context);

    if(!_loaded){
      _loaded = !_loaded;
      usuarioProvider.getPedidos(context);
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos'),
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: RefreshIndicator(
        onRefresh: (){
          return usuarioProvider.getPedidos(context);
        },
        child: Consumer<UsuarioProvider>(
          builder: (context, snapshot, _){

            List pedidos = snapshot.pedidos;

            if(snapshot.isLoading){
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            //pedidos = List();

            if(pedidos.length == 0){
              return emptyMessage(
                color: Colors.grey,
                icon: FontAwesomeIcons.utensils,
                title: 'nenhum pedido no momento',
                subtitle: 'que tal salvar alguma delicia agora?'
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(8),
              itemBuilder: (context, index){
                return PedidosTile(pedidos[index]);
              },
              itemCount: pedidos.length,
            );

          },
        ),
      ),
    );
  }
}
