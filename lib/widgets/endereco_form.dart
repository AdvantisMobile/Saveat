import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:provider/provider.dart';
import 'package:saveat/inputs.dart';
import 'package:saveat/provider/usuario_provider.dart';
import 'package:saveat/util.dart';

class EnderecoWidget extends StatefulWidget {

  final String botaoPreenchimento;
  final Map endereco;

  EnderecoWidget({this.endereco, this.botaoPreenchimento: 'Preencher endereço'});

  @override
  _EnderecoWidgetState createState() => _EnderecoWidgetState();
}

class _EnderecoWidgetState extends State<EnderecoWidget> {

  MaskedTextController _controllerCEP;
  FocusNode endnumFocus;
  UsuarioProvider usuarioProvider;

  bool _loadEndereco = false;
  Map _endereco;

  Map endereco;

  @override
  void didChangeDependencies() {

    endereco = widget.endereco;
    _controllerCEP = MaskedTextController(mask: '00000-000', text: endereco != null ? endereco['cep'] : '');
    endnumFocus = FocusNode();
    usuarioProvider = Provider.of<UsuarioProvider>(context);


    _endereco = {
      'cep': endereco != null ? endereco['cep'] : '',
      'endereco': endereco != null ? endereco['endereco'] : '',
      'endnum': endereco != null ? endereco['endnum'] : '',
      'complemento': endereco != null ? endereco['complemento'] : '',
      'bairro': endereco != null ? endereco['bairro'] : '',
      'cidade': endereco != null ? endereco['cidade'] : '',
      'uf': endereco != null ? endereco['uf'] : null,
    };

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 120,
              child: InputField(
                attribute: 'cep',
                label: 'CEP',
                keyboardType: TextInputType.number,
                controller: _controllerCEP,
                initialValue: _endereco['cep'],
                autofocus: _endereco['cep'] == '' ? true : false,
                required: true,
                validators: [
                  FormBuilderValidators.required(errorText: 'Obrigatório'),
                  FormBuilderValidators.minLength(9, errorText: 'CEP inválido'),
                ],
              ),
            ),
            SizedBox(width: 16),
            Container(
              height: 53,
              child: FlatButton(
                onPressed: () async {

                  if(_controllerCEP.text == '') return;

                  try{

                    setState(() {
                      _loadEndereco = true;
                    });

                    Map res = await usuarioProvider.api.getURL('wconfig/buscaEndereco.php?cep=${_controllerCEP.text}');

                    setState(() {
                      _endereco = {
                        'endereco': res['logradouro'] != null ? res['logradouro'] : '',
                        'bairro': res['bairro'] != null ? res['bairro'] : '',
                        'cidade': res['cidade'] != null ? res['cidade'] : '',
                        'uf': res['estado'] != null ? res['estado'] : '',
                      };

                      _loadEndereco = false;

                    });

                    await Future.delayed(Duration(milliseconds: 100));
                    FocusScope.of(context).requestFocus(endnumFocus);

                  } catch (e){
                    print(e);
                    setState(() {
                      _loadEndereco = false;
                    });
                  }

                },
                child: Text(widget.botaoPreenchimento, style: TextStyle(fontSize: 12),),
              ),
            ),
          ],
        ),
        _loadEndereco ? Container(
          height: 276,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ) : Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 8,
                  child: InputField(
                    attribute: 'endereco',
                    label: 'Endereço',
                    required: true,
                    initialValue: _endereco['endereco'],
                    validators: [
                      FormBuilderValidators.required(errorText: 'Obrigatório')
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: InputField(
                    attribute: 'endnum',
                    label: 'Número',
                    required: true,
                    initialValue: _endereco['endnum'],
                    keyboardType: TextInputType.number,
                    focusNode: endnumFocus,
                    validators: [
                      FormBuilderValidators.required(errorText: 'Obrigatório')
                    ],
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: InputField(
                    attribute: 'complemento',
                    label: 'Complemento',
                    initialValue: _endereco['complemento'],
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 7,
                  child: InputField(
                    attribute: 'bairro',
                    label: 'Bairro',
                    initialValue: _endereco['bairro'],
                    required: true,
                    validators: [
                      FormBuilderValidators.required(errorText: 'Obrigatório')
                    ],
                  ),
                ),
              ],
            ),
            InputField(
              attribute: 'cidade',
              label: 'Cidade',
              initialValue: _endereco['cidade'],
              required: true,
              validators: [
                FormBuilderValidators.required(errorText: 'Obrigatório')
              ],
            ),
            DropdownField(
              attribute: 'uf',
              label: 'Estado',
              initialValue: _endereco['uf'],
              required: true,
              indexValue: 'nome',
              items: estadosLista,
            ),
          ],
        ),
      ],
    );
  }
}
