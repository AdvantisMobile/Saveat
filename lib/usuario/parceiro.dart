import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saveat/inputs.dart';
import 'package:saveat/provider/usuario_provider.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/image_source_sheet.dart';

class ParceiroPage extends StatefulWidget {
  @override
  _ParceiroPageState createState() => _ParceiroPageState();
}

class _ParceiroPageState extends State<ParceiroPage> {
  bool _loaded = false;
  UsuarioProvider usuarioProvider;
  TextEditingController _nomeUsuarioController;
  TextEditingController _emailController;
  TextEditingController _telefoneController;
  TextEditingController _nomeEmpresaController;
  TextEditingController _cidadeController;

  var _fbKey = GlobalKey<FormBuilderState>();

  @override
  void didChangeDependencies() {
    usuarioProvider = Provider.of<UsuarioProvider>(context);

    if (!_loaded) {
      _loaded = !_loaded;
      usuarioProvider.getDadosUsuario(context);
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seja um parceiro'),
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4),
        child: FormBuilder(
          key: _fbKey,
          child: Column(
            children: <Widget>[
              saveatTextInput(_nomeUsuarioController, 'Seu nome', 'nomeUsuario'),
              saveatTextInput(_emailController, 'email', 'email'),
              saveatTextInput(_telefoneController, 'telefone', 'telefone'),
              saveatTextInput(_nomeEmpresaController, 'Nome da empresa', 'nomeEmpresa'),
              saveatTextInput(_cidadeController, 'Cidade', 'cidade'),
              Container(
                margin: EdgeInsets.all(5),
                child: DropdownField(
                  attribute: 'uf',
                  label: 'Estado',
                  initialValue: 'AC',
                  indexValue: 'nome',
                  items: estadosLista,
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    labelStyle: TextStyle(color: green, fontSize: 16),
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        width: 1,
                        color: green,
                      ),
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                child: RaisedButton(
                  color: green,
                  onPressed: () async {
                    await usuarioProvider.enviarRequisicaoParceria(context, _fbKey);
                  },
                  textColor: Colors.white,
                  child: Center(
                    child: Text('Enviar solicitação'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget saveatTextInput(controller, label, attr) {
    return InputField(
      attribute: attr,
      controller: controller,
      decoration: InputDecoration(
        labelStyle: TextStyle(color: green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        labelText: label ?? '',
      ),
      margin: EdgeInsets.all(5),
      validators: [(value) {
        if (value.isEmpty) {
          return 'Campo obrigatório';
        }
        return null;
      }],
    );
  }
}
