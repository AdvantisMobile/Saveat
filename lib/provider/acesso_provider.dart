import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:saveat/acesso/cidades.dart';
import 'package:saveat/api.dart';
import 'package:saveat/model/empresa_model.dart';
import 'package:saveat/provider/category_provider.dart';
import 'package:saveat/provider/company_provider.dart';
import 'package:saveat/provider/usuario_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util.dart';
import 'offer_provider.dart';

class AcessoProvider with ChangeNotifier {

  Api api;
  Map cidades;
  Map cidadeAtual;
  Map usuarioLogado;
  Map redirect;

  final BehaviorSubject<bool> _userLoggedController = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get outUserLogged => _userLoggedController.stream;

  AcessoProvider(){
    api = Api();

    getUsuarioLogado();

  }

  Future<Null> getUsuarioLogado() async {
    await SharedPreferences.getInstance().then((prefs) async {
      String res = prefs.getString('usuarioLogado');

      if(res != null) {
        usuarioLogado = json.decode(res);
        _userLoggedController.add((usuarioLogado != null ? true : false));
        globalUsuarioLogado = usuarioLogado;
        await getSaldoUsuario();
        notifyListeners();
      }
    });
  }

  Future<bool> setUsuarioLogado(Map usuario, {BuildContext context}) async {
    return await SharedPreferences.getInstance().then((prefs) async {
      prefs.setString('usuarioLogado', json.encode(usuario));
      usuarioLogado = usuario;

      if(usuario != null){
        _userLoggedController.add((usuarioLogado != null ? true : false));
        globalUsuarioLogado = usuarioLogado;
        await getSaldoUsuario();
        if(context != null)
          Provider.of<OfertasProvider>(context, listen: false).get(context);
      }

      notifyListeners();
      return true;
    });
  }

  Future<Null> logout(String usuario, String chave) async {
    Map params = {
      'tipo': 'logout',
      'usuario': usuario,
      'chave': chave,
    };

    _userLoggedController.add(false);
    globalUsuarioLogado = null;
    await api.putData('/access/login/', params);
  }

  Future<Null> getCidades() async {
    Map res = await api.getData('/global/?search=city');
    cidades = res;
    notifyListeners();
  }

  Future<Null> getCidadeAtual(BuildContext context) async {

    cidadeAtual = null;
    globalCidadeAtual = null;

    await SharedPreferences.getInstance().then((prefs){
      String res = prefs.getString('cidadeAtual');
      if(res != null) {
        cidadeAtual = json.decode(res);
        globalCidadeAtual = cidadeAtual;

        OfertasProvider providerOfertas = Provider.of<OfertasProvider>(context, listen: false);
        providerOfertas.cidade = cidadeAtual['id'];
        providerOfertas.getHome(context);

        CategoriasProvider categoriasProvider = Provider.of<CategoriasProvider>(context, listen: false);

        CompanyProvider providerCompany = Provider.of<CompanyProvider>(context, listen: false);
        providerCompany.cidade = cidadeAtual['id'];
        providerCompany.categoriaSelecionada = categoriasProvider.categoriaSelecionada;
        providerCompany.get();

        notifyListeners();
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CidadesPage()));
      }
    });

  }

  Future<bool> setCidadeAtual(BuildContext context, Map cidade) async {
    return await SharedPreferences.getInstance().then((prefs){
      prefs.setString('cidadeAtual', json.encode(cidade));

      cidadeAtual = cidade;
      globalCidadeAtual = cidadeAtual;

      OfertasProvider providerOfertas = Provider.of<OfertasProvider>(context, listen: false);
      providerOfertas.cidade = cidadeAtual['id'];
      providerOfertas.getHome(context);

      notifyListeners();

      return true;
    });
  }

  Future<Null> cadastrarUsuario(BuildContext context, GlobalKey<FormBuilderState> formKey) async {

    var form = formKey.currentState;

    FocusScope.of(context).requestFocus(new FocusNode());

    if(form.validate()) {
      form.save();

      Map params = form.value;

      showLoading(context);
      Map res = await api.postData('/access/login/', params);
      hideLoading(context);

      if(res['code'] == '010'){
        await setUsuarioLogado(res['data'], context: context);
        _redireciona(context);
      }else{
        alert(
          context: context,
          title: 'Ops',
          message: res['message'],
        );
      }

    }
  }

  Future<Null> logarEmail(BuildContext context, GlobalKey<FormBuilderState> formKey) async {

    var form = formKey.currentState;

    FocusScope.of(context).requestFocus(new FocusNode());

    if(form.validate()) {

      try{
        form.save();

        Map params = form.value;

        params['tipo'] = 'login';

        showLoading(context);
        Map res = await api.postData('/access/login/', params);
        hideLoading(context);

        if(res['code'] == '010'){
          await setUsuarioLogado(res['data'], context: context);
          _redireciona(context);
        }else{
          alert(
            context: context,
            title: 'Ops',
            message: res['message'],
          );
        }
      } catch (e){
        hideLoading(context);
        alert(
          context: context,
          title: 'Ops',
          message: e.toString(),
        );
      }
    }
  }

  Future<Null> logarSocial(BuildContext context, Map params) async {
    showLoading(context);
    Map res = await api.postData('/access/login/', params);
    hideLoading(context);

    if(res['code'] == '010'){
      await setUsuarioLogado(res['data'], context: context);
      _redireciona(context);
    }else{
      alert(
        context: context,
        title: 'Ops',
        message: res['message'],
      );
    }
  }

  void _redireciona(BuildContext context) async {
    Navigator.pop(context);

    Provider.of<UsuarioProvider>(context, listen: false).getCreditCards(context);

    if(redirect != null){
      if(redirect['page'] == 'cart'){
        CompanyProvider companyProvider = Provider.of<CompanyProvider>(context);
        EmpresaModel empresa = await companyProvider.getEmpresa(context, redirect['empresaId']);
        Navigator.pushNamed(context, '/carrinho', arguments: {
          'empresa': empresa,
        });
      }
    }
  }
  
  Future<Null> getSaldoUsuario() async {
    if(usuarioLogado != null){
      Map res = await api.getData('/user/balance/?usuario=${usuarioLogado['id']}&chave=${usuarioLogado['chave']}');

      if(res['code'] == '010'){
        usuarioLogado['saldo'] = double.tryParse(res['data']['saldo'].toString());
      }else{
        _userLoggedController.add(false);
        globalUsuarioLogado = null;
        await setUsuarioLogado(null);
      }
    }
  }

  void saldoRefresh() async {
    await getSaldoUsuario();
    notifyListeners();
  }

  void disposes(){
    _userLoggedController.close();
  }

}