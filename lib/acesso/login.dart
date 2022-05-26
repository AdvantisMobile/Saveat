import 'dart:convert';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:saveat/acesso/recuperar-senha.dart';
import 'package:saveat/provider/acesso_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../util.dart';
import 'cadastro.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _fbKey = GlobalKey<FormBuilderState>();
  GoogleSignInAccount _currentUser;

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      GoogleSignInAccount res = await _googleSignIn.signIn();
      _currentUser = res;

      if (_currentUser != null) {
        Map usuario = {
          'nome': _currentUser.displayName,
          'email': _currentUser.email,
          'foto': _currentUser.photoUrl,
          'ggid': _currentUser.id,
        };

        await Provider.of<AcessoProvider>(context).logarSocial(context, usuario);
      }
    } catch (error) {
      print('DEU NAO: $error');

//      alert(
//        context: context,
//        title: 'Ops',
//        message: 'Houve um erro com seu Login, por favor tente novamente ou com uma outra opção. $error',
//      );
    }
  }

  Future<void> _fbSignIn(BuildContext context) async {
    final facebookLogin = FacebookLogin();
    facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
        final profile = json.decode(graphResponse.body);

        if (profile != null) {
          Map usuario = {
            'nome': profile['name'],
            'email': profile['email'],
            'fbid': profile['id'],
          };

          await Provider.of<AcessoProvider>(context, listen: false).logarSocial(context, usuario);
        }

        break;
      case FacebookLoginStatus.cancelledByUser:
        break;
      case FacebookLoginStatus.error:
        alert(context: context, title: 'Ops', message: result.errorMessage.toString());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                // colors: [const Color(0xFFFFFFFF), const Color(0xFFCCCCCC)],
          )),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor: Colors.transparent,
                pinned: true,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.black),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Hero(
                          tag: 'logo-saveat',
                          child: Container(
                            width: 280,
                            child: Image.asset('assets/images/logo-saveat.png'),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(slogan),
                        SizedBox(height: 30),
                        Container(
                          width: 300,
                          child: Column(
                            children: <Widget>[
                              FormBuilder(
                                key: _fbKey,
                                child: Column(
                                  children: <Widget>[
                                    FormBuilderTextField(
                                      attribute: 'email',
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                          labelText: 'E-mail',
                                          labelStyle: TextStyle(color: Color(0xFF5F9A48)),
                                          isDense: false,
                                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF5F9A48), width: 1)),
                                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF5F9A48), width: 3))),
                                      validators: [
                                        FormBuilderValidators.required(errorText: 'Informe seu e-mail'),
                                        FormBuilderValidators.email(errorText: 'Informe um e-mail válido'),
                                      ],
                                    ),
                                    FormBuilderTextField(
                                      attribute: 'senha',
                                      obscureText: true,
                                      maxLines: 1,
                                      decoration: InputDecoration(
                                        labelText: 'Senha',
                                        labelStyle: TextStyle(
                                          color: Color(0xFF5F9A48),
                                        ),
                                        isDense: false,
                                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF5F9A48), width: 1)),
                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF5F9A48), width: 3)),
                                      ),
                                      validators: [
                                        FormBuilderValidators.required(errorText: 'Informe sua senha'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              ButtonTheme(
                                minWidth: 300,
                                height: 45,
                                buttonColor: Colors.white,
                                child: RaisedButton(
                                  onPressed: () async {
                                    await Provider.of<AcessoProvider>(context).logarEmail(context, _fbKey);
                                  },
                                  child: Text(
                                    'ENTRAR',
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              FlatButton(
                                onPressed: () {
                                  RecuperarSenha(
                                    context: context,
                                    //email: 'fernando@premiumart.com.br'
                                  ).show(1);
                                },
                                child: Text('Esqueceu a senha?'),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              SizedBox(height: 10),
                              ButtonTheme(
                                minWidth: 300,
                                height: 45,
                                buttonColor: Color(0xFF5F9A48),
                                textTheme: ButtonTextTheme.primary,
                                child: RaisedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => CadastroPage()),
                                    );
                                  },
                                  child: Text(
                                    'CADASTRE-SE',
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'OU CONECTE-SE COM',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF5F9A48),
                                ),
                              ),
                              SizedBox(height: 15),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: RaisedButton.icon(
                                      onPressed: () async {
                                        await _fbSignIn(context);
                                      },
                                      icon: Icon(
                                        FontAwesomeIcons.facebookF,
                                        size: 20,
                                      ),
                                      color: Color(0xFF2B4A8D),
                                      textColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      label: Text('FACEBOOK'),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: RaisedButton.icon(
                                      onPressed: () {
                                        _handleSignIn(context);
                                      },
                                      icon: Icon(
                                        FontAwesomeIcons.google,
                                        size: 20,
                                      ),
                                      color: Color(0xFFD93C29),
                                      textColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      label: Text('GOOGLE'),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 25),
                              InkWell(
                                onTap: () async {
                                  showLoading(context);
                                  String url = 'https://www.saveat.com.br/arquivos/termos_responsabilidade_saveat.pdf';
                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  }
                                  hideLoading(context);
                                },
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(style: TextStyle(color: Colors.black), children: [
                                    TextSpan(text: 'Ao entrar você concorda com os', children: [
                                      TextSpan(
                                        text: '\ntermos de uso SavEat',
                                        style: TextStyle(decoration: TextDecoration.underline),
                                      )
                                    ])
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
