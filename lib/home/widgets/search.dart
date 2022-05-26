import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saveat/api.dart';
import 'package:saveat/blocs/api_bloc.dart';
import 'package:saveat/util.dart';

class SearchPage extends SearchDelegate<String>{

  final String cidade;

  SearchPage({this.cidade});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: (){
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: (){
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    Future.delayed(Duration.zero).then((_) => close(context, query));
    return Container(
      child: InkWell(
        child: Text(query),
        onTap: (){
          close(context, query);
        },
      ),
    );
  }

  Future<List> suggestions(query) async {
    Api api = Api();

    Map res = await api.getData('/global/?search=search&q=$query&cidade=$cidade');

    if(res['code'] != '010')
      return [];

    return res['data'];
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if(query.isEmpty){
      return GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: emptyMessage(
          color: Colors.grey,
          icon: FontAwesomeIcons.utensils,
          title: 'o que você quer comer hoje?',
        ),
      );
    }else{
      return GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: FutureBuilder<List>(
          future: suggestions(query),
          builder: (context, snapshot){

            if(!snapshot.hasData){
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if(snapshot.data.length == 0){
              return SingleChildScrollView(
                child: emptyMessage(
                  color: Colors.grey,
                  icon: Icons.search,
                  title: 'nenhuma oferta encontrada para "$query"',
                  subtitle: 'tente um termo diferente'
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 5),
              itemBuilder: (context, index){

                Map item = snapshot.data[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(item['item']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item['empresa'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          '${maskValor(item['valor'])} - ${item['quantidade_restante']} restantes',
                          style: TextStyle(
                            fontSize: 18
                          ),
                        ),
                      ],
                    ),
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(item['foto']),
                      radius: 30,
                    ),
                    onTap: () async {

                      showLoading(context, text: 'Abrindo...');
                      Map res = await Provider.of<ApiBloc>(context, listen: false).getOferta(item['id']);
                      hideLoading(context);

                      Navigator.pushNamed(context, '/oferta', arguments: {
                        'item': res,
                      });

                    },
                  ),
                );
              },
              itemCount: snapshot.data.length,
            );
          },
        ),
      );
    }

    /*
    Size size = MediaQuery.of(context).size;
    double width = size.width / 2 - 16;

    List _lista = [
      {'nome': 'Sugestão 1'},
      {'nome': 'Sugestão 2'},
      {'nome': 'Sugestão 3'},
      {'nome': 'Sugestão 4'},
      {'nome': 'Sugestão 5'},
      {'nome': 'Sugestão 6'},
      {'nome': 'Sugestão 7'},
      {'nome': 'Sugestão 8'},
      {'nome': 'Sugestão 9'},
      {'nome': 'Sugestão 10'},
    ];

    InkWell(
      onTap: (){
        close(context, 'Sugestão 1');
      },
      child: Container(
        width: width,
        height: 100,
        child: Center(child: Text('Sugestão 1')),
      ),
    );

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          Wrap(
            children: _lista.map((v){
              return InkWell(
                onTap: (){
                  close(context, v['nome']);
                },
                child: Container(
                  width: width,
                  height: 100,
                  child: Center(
                    child: Text(
                      v['nome'],
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          OutlineButton(
            child: Text('Pesquisar $query'),
            onPressed: (){
              close(context, query);
            },
          )
        ],
      ),
    );
    */
  }

  @override
  ThemeData appBarTheme(BuildContext context) {

    final theme = Theme.of(context);
    return theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        title: theme.textTheme.title.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

}