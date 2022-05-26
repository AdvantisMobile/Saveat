import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/usuario_provider.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/cartao_widget.dart';

class CartoesPage extends StatefulWidget {
  @override
  _CartoesPageState createState() => _CartoesPageState();
}

class _CartoesPageState extends State<CartoesPage> {

  UsuarioProvider usuarioProvider;
  bool _loaded = false;

  @override
  void didChangeDependencies() {

    usuarioProvider = Provider.of<UsuarioProvider>(context);

    if(!_loaded){
      _loaded = !_loaded;
      usuarioProvider.getCreditCards(context);
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seus Cartões de Crédito'),
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF5F5F5),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          openFormCartao();
        },
        child: Icon(FontAwesomeIcons.solidPlusSquare),
      ),
      body: Consumer<UsuarioProvider>(
        builder: (context, snapshot, _){

          if(snapshot.loadingCards){
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List cartoes = snapshot.usuarioCreditCards;

          if(cartoes.length == 0){
            return emptyMessage(
              color: Colors.grey,
              icon: FontAwesomeIcons.creditCard,
              title: 'nenhum cartão cadastrado no momento',
            );
          }

          print(cartoes);

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(4, 4, 4, 90),
            itemBuilder: (context, index){
              return cartaoWidget(cartoes[index]);
            },
            itemCount: cartoes.length,
          );

        },
      ),
    );
  }

  Widget cartaoWidget(Map cartao){

    List vencimento = cartao['vencimento'].split('-');

    return Card(
      margin: EdgeInsets.all(4),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  cartao['brand'],
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey
                  ),
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        cartao['mask'],
                        style: TextStyle(
                          fontSize: 40,
                          fontFamily: ''
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text('Válido até', style: TextStyle(fontSize: 12),),
                        Text(
                          '${vencimento[1]}/${vencimento[0]}',
                          style: TextStyle(
                            fontSize: 20
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
            Positioned(
              top: -15,
              right: -15,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.redAccent,),
                onPressed: () async {
                  await confirm(
                    context: context,
                    title: 'Excluir cartão',
                    message: 'Confirma a remoção deste cartão de crédito?\n\nEste procedimento não poderá ser desfeito.',
                    cancel: FlatButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      textColor: Colors.black54,
                      child: Text('Cancelar'),
                    ),
                    confirm: FlatButton(
                      onPressed: () async {
                        await usuarioProvider.deleteCreditCard(context, cartao['id']);
                      },
                      textColor: Colors.red,
                      child: Text('EXCLUIR'),
                    )
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void openFormCartao(){

    var _fbKey = GlobalKey<FormBuilderState>();

    showSimpleDialog(
      context: context,
      barrierDismissible: false,
      titulo: 'Novo cartão',
      children: [
        FormBuilder(
          key: _fbKey,
          child: Column(
            children: <Widget>[
              CartaoWidget(showCVV: false,),
              RaisedButton(
                onPressed: () async {
                  await usuarioProvider.saveCreditCards(context, _fbKey);
                },
                child: Text('SALVAR CARTÃO'),
                textColor: Colors.white,
                color: green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
                ),
              ),
            ],
          ),
        )
      ]
    );

  }
}
