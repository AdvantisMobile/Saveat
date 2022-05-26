import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saveat/blocs/api_bloc.dart';
import 'package:saveat/blocs/cart_bloc.dart';
import 'package:saveat/cart/widgets/checkout_buytogether_tile.dart';
import 'package:saveat/widgets/title-widget.dart';

class CheckoutBuyTogether extends StatefulWidget {

  const CheckoutBuyTogether(this.empresaId, this.bloc);

  final String empresaId;
  final CartBloc bloc;

  @override
  _CheckoutBuyTogetherState createState() => _CheckoutBuyTogetherState();
}

class _CheckoutBuyTogetherState extends State<CheckoutBuyTogether> with AutomaticKeepAliveClientMixin {

  ApiBloc _apiBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    ApiBloc apiBloc = Provider.of<ApiBloc>(context, listen: false);
    if(apiBloc != _apiBloc) {
      _apiBloc = apiBloc;
      _apiBloc.fetchCompreJunto(widget.empresaId);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Column(
        children: <Widget>[
          TitleWidget('Compre junto e deixe mais gostoso ainda', marginTop: 7, marginLeft: 0, marginBottom: 20,),
          StreamBuilder<List>(
            stream: _apiBloc.outCompreJunto,
            builder: (context, snapshot){
              if(!snapshot.hasData)
                return CircularProgressIndicator();

              List _itens = snapshot.data;

              if(_itens.length == 0)
                return Container(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(
                    'Nenhum produto adicional disponível no momento, desculpe ;(',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                );

              return StreamBuilder<List>(
                stream: widget.bloc.outCompreJunto,
                builder: (context, snapshot){
                  return Column(
                    children: _itens.map((item){
                      return CheckoutBuyTogetherTile(widget.empresaId, item, widget.bloc);
                    }).toList(),
                  );
                }
              );
            },
          )
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
