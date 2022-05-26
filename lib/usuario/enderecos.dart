import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/usuario_provider.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/endereco_form.dart';

class EnderecosPage extends StatefulWidget {
  @override
  _EnderecosPageState createState() => _EnderecosPageState();
}

class _EnderecosPageState extends State<EnderecosPage> {

  bool _loaded = false;
  UsuarioProvider usuarioProvider;
  double width;
  var _fbKey = GlobalKey<FormBuilderState>();

  @override
  void didChangeDependencies() {

    width = MediaQuery.of(context).size.width;
    usuarioProvider = Provider.of<UsuarioProvider>(context);

    if(!_loaded){
      _loaded = !_loaded;
      usuarioProvider.getEnderecos(context, loadingModal: false);
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seus endereços'),
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF5F5F5),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          openFormAddress();
        },
        tooltip: 'Adicionar endereço',
        child: Icon(Icons.add_location),
      ),
      body: Consumer<UsuarioProvider>(
        builder: (context, snapshot, _){

          if(snapshot.isLoading){
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if(snapshot.usuarioEnderecos.length == 0){
            return emptyMessage(
                color: Colors.grey,
                icon: FontAwesomeIcons.mapSigns,
                title: 'nenhum endereço cadastrado no momento',
            );
          }

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(4, 4, 4, 90),
            itemBuilder: (context, index){
              return Card(
                margin: EdgeInsets.all(4),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 25),
                        child: Column(
                          children: <Widget>[
                            Text(
                              getEndereco(snapshot.usuarioEnderecos[index])
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        top: -10,
                        right: -10,
                        child: PopupMenuButton(
                          itemBuilder: (context){
                            return [
                              PopupMenuItem(
                                value: 'editar',
                                child: Text('Editar'),
                              ),
                              PopupMenuItem(
                                value: 'excluir',
                                child: Text('Excluir'),
                              ),
                            ];
                          },
                          onSelected: (v) async {
                            if(v == 'editar'){
                              openFormAddress(title: 'Editar endereço', endereco: snapshot.usuarioEnderecos[index], acao: 2);
                              return;
                            }

                            if(v == 'excluir'){
                              await confirm(
                                context: context,
                                title: 'Excluir endereço',
                                message: 'Confirma a remoção deste endereço?',
                                confirm: FlatButton(
                                  onPressed: () async {
                                    await usuarioProvider.deletarEndereco(context, snapshot.usuarioEnderecos[index]['id']);
                                    Navigator.pop(context);
                                  },
                                  textColor: Colors.red,
                                  child: Text('EXCLUIR'),
                                ),
                                cancel: FlatButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  textColor: Colors.grey[800],
                                  child: Text('Cancelar'),
                                )
                              );
                              return;
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
            itemCount: snapshot.usuarioEnderecos.length,
          );
        },
      ),
    );
  }

  void openFormAddress({String title: 'Adicionar endereço', Map endereco, int acao: 1}){
    showSimpleDialog(
      context: context,
      titulo: title,
      barrierDismissible: false,
      children: [
        Container(
          width: width,
          child: FormBuilder(
            key: _fbKey,
            child: Column(
              children: <Widget>[
                EnderecoWidget(botaoPreenchimento: 'Preencher', endereco: endereco,),
                Container(
                  width: width,
                  height: 40,
                  child: RaisedButton(
                    onPressed: () async {
                      bool res = false;

                      if(acao == 1){
                        res = await UsuarioProvider().cadastrarNovoEndereco(context, _fbKey);
                      }else if(acao == 2){
                        res = await UsuarioProvider().alterarEndereco(context, endereco['id'], _fbKey);
                      }

                      if(res){

                        await alert(
                          title: 'Sucesso!',
                          message: acao == 1 ? 'Endereço cadastrado com sucesso!' : 'Endereço alterado com sucesso!',
                          context: context,
                        );

                        await usuarioProvider.getEnderecos(context);
                        Navigator.pop(context);
                      }
                    },
                    color: green,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: Text('SALVAR DADOS'),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  width: MediaQuery.of(context).size.width,
                  child: FlatButton(
                    child: Text('Cancelar'),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ]
    );
  }
}
