import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/usuario_provider.dart';
import 'package:saveat/widgets/endereco_form.dart';

import '../util.dart';

class EnderecosFormPage extends StatefulWidget {

  final Map dados;
  final String origin;
  EnderecosFormPage({this.dados, this.origin = ''});

  @override
  _EnderecosFormPageState createState() => _EnderecosFormPageState();
}

class _EnderecosFormPageState extends State<EnderecosFormPage> {

  var _fbKey = GlobalKey<FormBuilderState>();
  UsuarioProvider usuarioProvider;

  @override
  void didChangeDependencies() {
    usuarioProvider = Provider.of<UsuarioProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo endereço'),
        elevation: 2,
      ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: FormBuilder(
          key: _fbKey,
          child: ListView(
            padding: EdgeInsets.all(16),
            children: <Widget>[
              EnderecoWidget(),
              Container(
                height: 40,
                child: RaisedButton(
                  child: Text('SALVAR ENDEREÇO'),
                  onPressed: () async {
                    await usuarioProvider.postEnderecos(context, _fbKey, origin: widget.origin);
                  },
                  color: green,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)
                  ),
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}
