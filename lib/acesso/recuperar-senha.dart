import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/acesso_provider.dart';

import '../api.dart';
import '../inputs.dart';
import '../util.dart';

class RecuperarSenha{

  final BuildContext context;
  String email;
  GlobalKey<FormBuilderState> _fbKey;
  Api api;
  String _id;
  String _chave;

  RecuperarSenha({this.context, this.email});

  _step1(){
    return Column(
      children: <Widget>[
        InputField(
          attribute: 'email',
          label: 'E-mail',
          initialValue: email,
          required: true,
          showAsterisk: false,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          validators: [
            FormBuilderValidators.required(errorText: 'Por favor informe um e-mail válido!'),
            FormBuilderValidators.email(errorText: 'Por favor informe um e-mail válido!'),
          ],
        ),
        RaisedButton(
          onPressed: () async {

            var form = _fbKey.currentState;

            if(form.validate()){
              form.save();

              Map params = form.value;
              params['step'] = '1';

              showLoading(context);
              Map res = await api.postData('/access/recover/', params);
              hideLoading(context);

              if(res['code'] == '010'){
                email = res['data']['email'];
                _changeStep(2);
              }else{
                alert(
                  context: context,
                  title: 'Ops',
                  message: res['message'],
                );
              }
            }

          },
          child: Text(
            'SOLICITAR CÓDIGO',
          ),
          color: green,
          textColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
          ),
        ),
        FlatButton(
          child: Text('Já tenho um código válido'),
          onPressed: (){
            _changeStep(2);
          },
        )
      ],
    );
  }

  _step2(){
    return Column(
      children: <Widget>[
        Text(
          'Digite o código que foi enviado para seu e-mail',
        ),
        SizedBox(height: 10),
        InputField(
          attribute: 'email',
          label: 'E-mail',
          initialValue: email,
          required: true,
          showAsterisk: false,
          keyboardType: TextInputType.emailAddress,
          validators: [
            FormBuilderValidators.required(errorText: 'Por favor informe um e-mail válido!'),
            FormBuilderValidators.email(errorText: 'Por favor informe um e-mail válido!'),
          ],
        ),
        InputField(
          attribute: 'codigo',
          label: 'Código',
          required: true,
          showAsterisk: false,
          keyboardType: TextInputType.number,
          validators: [
            FormBuilderValidators.required(errorText: 'Por favor informe o código!'),
          ],
        ),
        RaisedButton(
          onPressed: () async {

            var form = _fbKey.currentState;

            if(form.validate()){
              form.save();

              Map params = form.value;
              params['step'] = '2';

              showLoading(context);
              Map res = await api.postData('/access/recover/', params);
              hideLoading(context);

              if(res['code'] == '010'){
                _id = res['data']['id'];
                _chave = res['data']['chave'];
                _changeStep(3);
              }else{
                alert(
                  context: context,
                  title: 'Ops',
                  message: res['message'],
                );
              }
            }

          },
          child: Text(
            'VALIDAR CÓDIGO',
          ),
          color: green,
          textColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
          ),
        ),
        FlatButton(
          child: Text('Solicitar novo código'),
          onPressed: (){
            _changeStep(1);
          },
        )
      ],
    );
  }

  _step3(){
    return Column(
      children: <Widget>[
        Text(
          'Digite sua nova senha',
        ),
        SizedBox(height: 10),
        InputField(
          attribute: 'senha',
          label: 'Nova senha',
          required: true,
          showAsterisk: false,
          obscureText: true,
          autofocus: true,
          validators: [
            FormBuilderValidators.required(errorText: 'Informe sua nova senha!'),
          ],
        ),
        InputField(
          attribute: 'senha2',
          label: 'Repita a nova senha',
          required: true,
          showAsterisk: false,
          obscureText: true,
          validators: [
            FormBuilderValidators.required(errorText: 'Repita sua nova senha!'),
          ],
        ),
        RaisedButton(
          onPressed: () async {

            var form = _fbKey.currentState;

            if(form.validate()){
              form.save();

              Map params = form.value;
              params['step'] = '3';
              params['id'] = _id;
              params['chave'] = _chave;

              showLoading(context);
              Map res = await api.postData('/access/recover/', params);
              hideLoading(context);

              if(res['code'] == '010'){
                await Provider.of<AcessoProvider>(context, listen: false).setUsuarioLogado(res['data'], context: context);
                Navigator.pop(context);
                Navigator.pop(context);
              }else{
                alert(
                  context: context,
                  title: 'Ops',
                  message: res['message'],
                );
              }
            }

          },
          child: Text(
            'SALVAR SENHA',
          ),
          color: green,
          textColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
          ),
        ),
      ],
    );
  }

  _stepper(int step){
    if(step == 1) return _step1();
    if(step == 2) return _step2();
    if(step == 3) return _step3();
    else return Container();
  }

  _changeStep(int step){
    Navigator.pop(context);
    _fbKey = null;
    show(step);
  }

  show(int step){
    _fbKey = GlobalKey<FormBuilderState>();
    api = Api();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context){
        return GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            ),
            title: Row(
              children: <Widget>[
                Expanded(
                  child: Text('Recuperar a senha'),
                ),
                IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close),
                )
              ],
            ),
            titlePadding: EdgeInsets.fromLTRB(16, 0, 0, 0),
            content: SingleChildScrollView(
              child: Container(
                width: 300,
                child: FormBuilder(
                  key: _fbKey,
                  child: _stepper(step),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}