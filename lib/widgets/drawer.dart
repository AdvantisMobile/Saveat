import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saveat/acesso/cidades.dart';
import 'package:saveat/acesso/login.dart';
import 'package:saveat/api.dart';
import 'package:saveat/provider/acesso_provider.dart';
import 'package:saveat/provider/category_provider.dart';
import 'package:saveat/provider/offer_provider.dart';
import 'package:saveat/usuario/cartoes.dart';
import 'package:saveat/usuario/enderecos.dart';
import 'package:saveat/usuario/favoritos.dart';
import 'package:saveat/usuario/parceiro.dart';
import 'package:saveat/usuario/pedidos.dart';
import 'package:saveat/usuario/perfil.dart';
import 'package:saveat/usuario/saldo.dart';
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:pdf_viewer_jk/pdf_viewer_jk.dart';
import 'package:url_launcher/url_launcher.dart';

import '../util.dart';

class DrawerWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: Consumer<AcessoProvider>(
        builder: (context, acesso, _){

          Map _usuario = acesso.usuarioLogado;
          bool _logado = _usuario != null;
          String _abreviacao = '';

          if(_logado){
            var _nomeSplit = _usuario['nome'].split(' ');

            if(_nomeSplit.length > 1){
              _abreviacao = (_nomeSplit[0].split('')[0] + _nomeSplit[1].split('')[0]).toUpperCase();
            }else{
              _abreviacao = _usuario['nome'] != '' ? _usuario['nome'].split('')[0] : 'SE';
            }
          }

          return Container(
            color: Color(0xFF5F9A48),
            child: SafeArea(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Color(0xFF5F9A48),
                      child: Stack(
                        children: <Widget>[
                          !_logado ? UserAccountsDrawerHeader(
                            currentAccountPicture: CircleAvatar(
                              child: Text(
                                'SE',
                                style: TextStyle(
                                  fontSize: 25,
                                  letterSpacing: 5
                                ),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            accountName: Text('Bem-vindo(a)'),
                            accountEmail: Text(
                              slogan,
                              style: TextStyle(
                                color: Colors.white70
                              ),
                            ),
                            margin: EdgeInsets.all(0),
                          ) : UserAccountsDrawerHeader(
                            currentAccountPicture: _usuario['foto'] == '' ? CircleAvatar(
                                child: Text(
                                  _abreviacao,
                                  style: TextStyle(
                                    fontSize: 25,
                                    letterSpacing: 5
                                  ),
                                ),
                              ) : CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                  _usuario['foto'],
                                ),
                              ),
                            accountName: Text(_usuario['nome']),
                            accountEmail: Text(
                              _usuario['email'],
                              style: TextStyle(
                                color: Colors.white70
                              ),
                            ),
                            margin: EdgeInsets.all(0),
                          ),
                          Visibility(
                            visible: _logado ? true : false,
                            child: Positioned(
                              top: 0,
                              right: 5,
                              child: FlatButton(
                                onPressed: () async {
                                  await showSimpleDialog(
                                    context: context,
                                    titulo: 'Confirma o logout do app?',
                                    children: [
                                      Column(
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              RaisedButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(30)
                                                ),
                                                child: Text('FICAR'),
                                                color: Colors.green,
                                                textColor: Colors.white,
                                              ),
                                              SizedBox(width: 20),
                                              RaisedButton(
                                                onPressed: () async {
                                                  showLoading(context);
                                                  await acesso.logout(acesso.usuarioLogado['id'], acesso.usuarioLogado['chave']);
                                                  await acesso.setUsuarioLogado(null);
                                                  hideLoading(context);
                                                  Navigator.pop(context);
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(30)
                                                ),
                                                child: Text('SAIR'),
                                                color: Colors.red,
                                                textColor: Colors.white,
                                              ),
                                            ],
                                            mainAxisAlignment: MainAxisAlignment.center,
                                          ),
                                        ],
                                      )
                                    ]
                                  );
                                },
                                child: Text('Sair'),
                                textColor: Colors.white,
                                padding: EdgeInsets.all(0),
                                materialTapTargetSize: MaterialTapTargetSize.padded,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        children: <Widget>[
                          ListTile(
                              leading: Icon(FontAwesomeIcons.piggyBank),
                              title: Text('Ofertas'),
                              onTap: (){
                                CategoriasProvider providerCategoria = Provider.of<CategoriasProvider>(context);
                                OfertasProvider providerOfertas = Provider.of<OfertasProvider>(context);

                                providerCategoria.categoriaSelecionada = null;

                                providerOfertas.categoria = '';
                                providerOfertas.clearOfertasHome();
                                providerOfertas.getHome(context);

                                Navigator.pop(context);
                              }
                          ),
                          _logado ? Column(
                            children: <Widget>[
                              ListTile(
                                leading: Icon(FontAwesomeIcons.star),
                                title: Text('Empresas favoritas'),
                                onTap: (){
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => FavoritosPage()));
                                }
                              ),
                              ListTile(
                                leading: Icon(FontAwesomeIcons.utensils),
                                title: Text('Pedidos'),
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => PedidosPage()));
                                }
                              ),
                              ListTile(
                                leading: Icon(FontAwesomeIcons.mapSigns),
                                title: Text('Endereços'),
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => EnderecosPage()));
                                }
                              ),
                              ListTile(
                                leading: Icon(FontAwesomeIcons.creditCard),
                                title: Text('Cartões'),
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => CartoesPage()));
                                }
                              ),
                              ListTile(
                                leading: Icon(FontAwesomeIcons.wallet),
                                title: Text('Saldo'),
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => SaldoPage()));
                                }
                              ),
                              ListTile(
                                leading: Icon(FontAwesomeIcons.idBadge),
                                title: Text('Perfil'),
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => PerfilPage()));
                                }
                              ),
                            ],
                          ) : Column(
                            children: <Widget>[
                              ListTile(
                                leading: Icon(FontAwesomeIcons.signInAlt),
                                title: Text('Entrar / Cadastrar'),
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                                }
                              ),
                            ],
                          ),
                          ListTile(
                              leading: Icon(FontAwesomeIcons.rocket),
                              title: Text('Seja um parceiro'),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ParceiroPage()));
                              }
                          ),
                          ListTile(
                              leading: Icon(FontAwesomeIcons.lifeRing),
                              title: Text('Atendimento'),
                              onTap: () async {
                                String url = API + '/atendimento.php';
                                if(await canLaunch(url)){
                                  await launch(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              }
                          )
                        ],
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          color: Color(0xFF5F9A48),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: Image.asset('assets/images/logo-saveat-white.png', fit: BoxFit.contain),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            'Você está em',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                          Text(
                                            '${acesso.cidadeAtual['cidade']}, ${acesso.cidadeAtual['uf']}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        icon: Icon(Icons.swap_horiz),
                                        color: Colors.white,
                                        onPressed: (){
                                          Navigator.pop(context);
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => CidadesPage()));
                                        },
                                        padding: EdgeInsets.all(0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5),
                          color: Color(0xFF477A33),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              InkWell(
                                onTap: () async {
                                  showLoading(context);
                                  String url = 'https://www.saveat.com.br/arquivos/termos_responsabilidade_saveat.pdf';
                                  if(await canLaunch(url)){
                                    await launch(url);
                                  }
                                  hideLoading(context);
                                },
                                child: Text(
                                  'Termos de uso',
                                  style: TextStyle(
                                    color: Colors.white
                                  ),
                                ),
                              ),
                              Text(
                                'v $version',
                                style: TextStyle(
                                  color: Colors.white
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
