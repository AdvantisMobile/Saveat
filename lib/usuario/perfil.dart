import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saveat/inputs.dart';
import 'package:saveat/provider/usuario_provider.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/image_source_sheet.dart';

class PerfilPage extends StatefulWidget {
  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {

  bool _loaded = false;
  UsuarioProvider usuarioProvider;

  @override
  void didChangeDependencies() {

    usuarioProvider = Provider.of<UsuarioProvider>(context);

    if(!_loaded){
      _loaded = !_loaded;
      usuarioProvider.getDadosUsuario(context);
    }

    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: Consumer<UsuarioProvider>(
        builder: (context, snapshot, _){

          if(snapshot.isLoading){
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          Map usuario = snapshot.usuarioDados;

          return SingleChildScrollView(
            padding: EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Center(
                    child: Stack(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.white,
                          backgroundImage: usuario['foto'] == '' ? null : CachedNetworkImageProvider(usuario['foto']),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: FloatingActionButton(
                            onPressed: (){
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => ImageSourceSheet(
                                  onImageSelected: (image) async {
                                    if(image != null){
                                      await usuarioProvider.atualizarFotoUsuario(context, image);
                                    }
                                  },
                                )
                              );
                            },
                            mini: true,
                            backgroundColor: Colors.white,
                            highlightElevation: 0,
                            child: Icon(Icons.camera_alt, color: Colors.black54,),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.all(4),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _text('Nome', usuario['nome']),
                        _text('CPF', usuario['cpf']),
                        _text('Telefone', usuario['telefone']),
                        _text('E-mail', usuario['email']),
                      ],
                    ),
                  ),
                ),
                usuario['tipo_login'] != 'email' ? Container() : Card(
                  margin: EdgeInsets.all(4),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: FlatButton.icon(
                        onPressed: _alterarSenha,
                        textColor: Colors.redAccent,
                        icon: Icon(Icons.lock_outline),
                        label: Text('Alterar senha'),
                      ),
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.all(4),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: FlatButton.icon(
                        onPressed: (){
                          _alterarDados(usuario);
                        },
                        textColor: Colors.blue,
                        icon: Icon(FontAwesomeIcons.pencilAlt, size: 18,),
                        label: Text('Alterar dados'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );

        },
      ),
    );
  }

  Widget _text(String title, String text){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey
            ),
          ),
          Text(
            text == '' ? 'Não informado' : text,
            style: TextStyle(
              color: text == '' ? Colors.grey : Colors.black
            ),
          )
        ],
      ),
    );
  }

  void _alterarDados(Map usuario){

    var _fbKey = GlobalKey<FormBuilderState>();

    showSimpleDialog(
      context: context,
      titulo: 'Alterar dados',
      barrierDismissible: false,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: FormBuilder(
            key: _fbKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                InputField(
                  attribute: 'nome',
                  label: 'Nome completo',
                  initialValue: usuario['nome'],
                  required: true,
                  validators: [
                    FormBuilderValidators.required(errorText: 'Obrigatório'),
                  ],
                ),
                InputCPF(
                  attribute: 'cpf',
                  label: 'CPF',
                  initialValue: usuario['cpf'],
                  required: true,
                ),
                InputTelefone(
                  attribute: 'telefone',
                  label: 'Telefone',
                  initialValue: usuario['telefone'],
                  required: true,
                  showAsterisk: true,
                ),
                Visibility(
                  visible: usuario['tipo_login'] == 'email' ? true : false,
                  child: InputField(
                    attribute: 'email',
                    label: 'E-mail',
                    initialValue: usuario['email'],
                    required: true,
                    validators: [
                      FormBuilderValidators.required(errorText: 'Obrigatório'),
                      FormBuilderValidators.email(errorText: 'Informe um e-mail válido'),
                    ],
                  ),
                ),
                RaisedButton(
                  onPressed: (){
                    usuarioProvider.salvarDadosUsuario(context, _fbKey);
                  },
                  color: green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)
                  ),
                  textColor: Colors.white,
                  child: Text('SALVAR DADOS'),
                )
              ],
            ),
          ),
        )
      ]
    );

  }

  void _alterarSenha(){

    var _fbKey = GlobalKey<FormBuilderState>();

    showSimpleDialog(
        context: context,
        titulo: 'Alterar senha',
        barrierDismissible: false,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: FormBuilder(
              key: _fbKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  InputField(
                    attribute: 'senha_atual',
                    label: 'Senha atual',
                    obscureText: true,
                    required: true,
                    autofocus: true,
                    validators: [
                      FormBuilderValidators.required(errorText: 'Obrigatório')
                    ],
                  ),
                  InputField(
                    attribute: 'senha',
                    label: 'Nova senha',
                    obscureText: true,
                    required: true,
                    validators: [
                      FormBuilderValidators.required(errorText: 'Obrigatório'),
                      FormBuilderValidators.minLength(5, errorText: 'Defina no mínimo 5 caracteres'),
                    ],
                  ),
                  InputField(
                    attribute: 'senha_confirma',
                    label: 'Repita a nova senha',
                    obscureText: true,
                    required: true,
                    validators: [
                      FormBuilderValidators.required(errorText: 'Obrigatório'),
                      FormBuilderValidators.minLength(5, errorText: 'Defina no mínimo 5 caracteres'),
                    ],
                  ),
                  RaisedButton(
                    onPressed: (){
                      usuarioProvider.atualizarSenhaDadosUsuario(context, _fbKey);
                    },
                    color: green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                    ),
                    textColor: Colors.white,
                    child: Text('SALVAR NOVA SENHA'),
                  )
                ],
              ),
            ),
          )
        ]
    );

  }

}
