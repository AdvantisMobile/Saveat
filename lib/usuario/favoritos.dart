import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saveat/blocs/api_bloc.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/cards/card_estabelecimento.dart';

class FavoritosPage extends StatefulWidget {
  @override
  _FavoritosPageState createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  ApiBloc _apiBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    ApiBloc apiBloc = Provider.of<ApiBloc>(context, listen: false);
    if (apiBloc != _apiBloc) {
      _apiBloc = apiBloc;
      _apiBloc.getEmpresasFavoritas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Empresas favoritas'),
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: StreamBuilder<List>(
        stream: _apiBloc.outEmpresasFavoritas,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.connectionState != ConnectionState.active)
            return Center(
              child: CircularProgressIndicator(),
            );

          if (snapshot.data.length == 0) {
            return emptyMessage(
              color: Colors.grey,
              icon: Icons.star_border,
              title: 'nenhum favorito\npara mostrar',
              subtitle: 'seus estabelecimentos favoritos aparecerão sempre aqui',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _apiBloc.getEmpresasFavoritas();
              return Future.delayed(Duration.zero);
            },
            child: SafeArea(
              top: false,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                itemBuilder: (context, index) {
                  return CardEstabelecimento(
                    empresa: snapshot.data[index],
                  );
                },
                itemCount: snapshot.data.length,
              ),
            ),
          );
        },
      ),
    );
  }
}
