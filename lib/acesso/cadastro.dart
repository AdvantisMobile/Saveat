import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/acesso_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../inputs.dart';
import '../util.dart';

class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {

  var _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastre-se'),
        elevation: 2,
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
          padding: EdgeInsets.all(16),
          children: <Widget>[
            FormBuilder(
              key: _fbKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: 'logo-saveat',
                    child: Container(
                      width: 280,
                      margin: EdgeInsets.only(top: 20),
                      child: Image.asset('assets/images/logo-saveat.png'),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(slogan),
                  SizedBox(height: 30),
                  Container(
                    width: 300,
                    //padding: EdgeInsets.all(16),

                    child: Column(
                      children: <Widget>[
                        InputField(
                          attribute: 'nome',
                          label: 'Nome',
                          autofocus: true,
                          showAsterisk: false,
                          required: true,
                          validators: [
                            FormBuilderValidators.required(errorText: 'Informe seu nome'),
                          ],
                        ),
                        InputField(
                          attribute: 'email',
                          label: 'E-mail',
                          keyboardType: TextInputType.emailAddress,
                          showAsterisk: false,
                          required: true,
                          validators: [
                            FormBuilderValidators.required(errorText: 'Informe seu e-mail'),
                            FormBuilderValidators.email(errorText: 'Informe um e-mail válido!'),
                          ],
                        ),
                        InputField(
                          attribute: 'senha',
                          label: 'Senha',
                          obscureText: true,
                          showAsterisk: false,
                          required: true,
                          validators: [
                            FormBuilderValidators.required(errorText: 'Informe sua senha'),
                            FormBuilderValidators.minLength(4, errorText: 'Sua senha deve ter no mínimo 4 caracteres'),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: ButtonTheme(
                                height: 45,
                                buttonColor: Color(0xFF5F9A48),
                                textTheme: ButtonTextTheme.primary,
                                child: RaisedButton(
                                  onPressed: () async {
                                    await Provider.of<AcessoProvider>(context).cadastrarUsuario(context, _fbKey);
                                  },
                                  child: Text(
                                    'CRIAR CONTA',
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Não se preocupe, a criação de sua conta\né gratuita',
                    textAlign: TextAlign.center,
                  ),
                  Divider(height: 20),
                  InkWell(
                    onTap: () async {
                      showLoading(context);
                      String url = 'https://www.saveat.com.br/arquivos/termos_responsabilidade_saveat.pdf';
                      if(await canLaunch(url)){
                        await launch(url);
                      }
                      hideLoading(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.black
                          ),
                          children: [
                            TextSpan(
                                text: 'Ao entrar você concorda com os',
                                children: [
                                  TextSpan(
                                    text: '\ntermos de uso SavEat',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline
                                    ),
                                  )
                                ]
                            )
                          ]
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
