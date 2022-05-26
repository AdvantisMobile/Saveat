import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/acesso_provider.dart';

import '../api.dart';
import '../util.dart';
import 'global_provider.dart';

class UsuarioProvider extends ChangeNotifier {

  Api api = Api();
  List usuarioEnderecos = List();
  List usuarioCreditCards = List();
  List usuarioBoletos = List();
  List usuarioHistoricoSaldo = List();
  List empresasFavoritas = List();
  Map usuarioDados = Map();

  Map _pedido = Map();
  List _pedidos = List();

  Map get pedido => _pedido;
  List get pedidos => _pedidos;

  bool loadingCards = false;
  bool isLoading = false;

  Map _getUsuarioLogado(BuildContext context){
    GlobalProvider globalProvider = GlobalProvider(context);

    if(globalProvider.acessoProvider.usuarioLogado == null){
      return null;
    }

    String _usuario = globalProvider.acessoProvider.usuarioLogado['id'] ?? '';
    String _chave = globalProvider.acessoProvider.usuarioLogado['chave'] ?? '';

    return {
      'usuario': _usuario,
      'chave': _chave,
    };
  }

  Future<Null> getDadosUsuario(BuildContext context) async {
    isLoading = true;
    Map usuario = _getUsuarioLogado(context);

    if(usuario == null){
      return;
    }

    String u = usuario['usuario'];
    String c = usuario['chave'];

    Map res = await api.getData('/user/?usuario=$u&chave=$c');

    usuarioDados = res['data'];
    isLoading = false;
    notifyListeners();
  }

  Future<Null> salvarDadosUsuario(BuildContext context, GlobalKey<FormBuilderState> formKey) async {
    var form = formKey.currentState;

    FocusScope.of(context).requestFocus(new FocusNode());

    if(form.validate()) {
      form.save();

      Map params = form.value;

      showLoading(context);

      GlobalProvider globalProvider = GlobalProvider(context);
      params['usuario'] = globalProvider.acessoProvider.usuarioLogado['id'];
      params['chave'] = globalProvider.acessoProvider.usuarioLogado['chave'] ?? '';

      Map res = await api.putData('/user/', params);

      hideLoading(context);

      if(res['code'] == '010'){
        await alert(
          context: context,
          title: 'Sucesso!',
          message: res['message'],
        );

        Navigator.pop(context);

        usuarioDados = res['data'];
        globalProvider.acessoProvider.usuarioLogado['nome'] = params['nome'];
        if(params['email'] != null)
          globalProvider.acessoProvider.usuarioLogado['email'] = params['email'];
        globalProvider.acessoProvider.setUsuarioLogado(globalProvider.acessoProvider.usuarioLogado, context: context);

        notifyListeners();
      }else{
        await alert(
          context: context,
          title: 'Ops',
          message: res['message'],
        );
      }
    }
  }

  Future<Null> atualizarSenhaDadosUsuario(BuildContext context, GlobalKey<FormBuilderState> formKey) async {
    var form = formKey.currentState;

    FocusScope.of(context).requestFocus(new FocusNode());

    if(form.validate()) {
      form.save();

      Map params = form.value;

      showLoading(context);

      Map usuario = _getUsuarioLogado(context);
      params['usuario'] = usuario['usuario'];
      params['chave'] = usuario['chave'];

      Map res = await api.putData('/user/', params);

      hideLoading(context);

      if(res['code'] == '010'){
        await alert(
          context: context,
          title: 'Sucesso!',
          message: res['message'],
        );

        Navigator.pop(context);

      }else{
        await alert(
          context: context,
          title: 'Ops',
          message: res['message'],
        );
      }

    }

  }

  Future<Null> atualizarFotoUsuario(BuildContext context, File image) async {
    showLoading(context);

    Map params = Map();

    GlobalProvider globalProvider = GlobalProvider(context);
    params['usuario'] = globalProvider.acessoProvider.usuarioLogado['id'];
    params['chave'] = globalProvider.acessoProvider.usuarioLogado['chave'] ?? '';

    List<int> imageBytes = image.readAsBytesSync();
    String foto = 'data:image/jpeg;base64,' + base64Encode(imageBytes);

    params['foto'] = foto;
    params['foto_tipo'] = '2';

    Map res = await api.putData('/user/', params);

    hideLoading(context);

    if(res['code'] == '010'){

      await alert(
        context: context,
        title: 'Sucesso!',
        message: res['message'],
      );

      usuarioDados = res['data'];
      globalProvider.acessoProvider.usuarioLogado['foto'] = usuarioDados['foto'];
      globalProvider.acessoProvider.setUsuarioLogado(globalProvider.acessoProvider.usuarioLogado, context: context);

      Navigator.pop(context);

      notifyListeners();

    }else{
      await alert(
        context: context,
        title: 'Ops',
        message: res['message'],
      );
    }

  }

  Future<void> getEnderecos(BuildContext context, {String origin: '', bool loadingModal: false}) async {
    isLoading = true;

    if(loadingModal)
      showLoading(context);

    // usuario e chave de acesso
    GlobalProvider globalProvider = GlobalProvider(context);
    String _usuario = globalProvider.acessoProvider.usuarioLogado['id'];
    String _chave = globalProvider.acessoProvider.usuarioLogado['chave'] ?? '';
    //

    Map res = await api.getData('/user/address/?usuario=$_usuario&chave=$_chave&origin=$origin');

    if(loadingModal)
      hideLoading(context);

    usuarioEnderecos = res['data'];
    isLoading = false;
    notifyListeners();
  }

  Future<Null> postEnderecos(BuildContext context, GlobalKey<FormBuilderState> formKey, {String origin: ''}) async {
    var form = formKey.currentState;

    FocusScope.of(context).requestFocus(new FocusNode());

    if(form.validate()) {
      form.save();

      Map params = form.value;

      showLoading(context);

      // usuario e chave de acesso
      GlobalProvider globalProvider = GlobalProvider(context);
      params['usuario'] = globalProvider.acessoProvider.usuarioLogado['id'];
      params['chave'] = globalProvider.acessoProvider.usuarioLogado['chave'] ?? '';
      //

      Map res = await api.postData('/user/address/', params);
      hideLoading(context);

      if(res['code'] == '010'){
        await alert(
          context: context,
          title: 'Sucesso!',
          message: res['message'],
        );

        getEnderecos(context, origin: origin);

        Navigator.pop(context);
      }else{
        await alert(
          context: context,
          title: 'Ops',
          message: res['message'],
        );
      }
    }
  }

  Future<Null> getCreditCards(BuildContext context) async {
    loadingCards = true;

    // usuario e chave de acesso
    GlobalProvider globalProvider = GlobalProvider(context);
    String _usuario = globalProvider.acessoProvider.usuarioLogado['id'];
    String _chave = globalProvider.acessoProvider.usuarioLogado['chave'] ?? '';

    Map res = await api.getData('/user/cc/?usuario=$_usuario&chave=$_chave');

    usuarioCreditCards = res['data'];
    loadingCards = false;
    notifyListeners();
  }

  void setTempCard(Map card){
    /// adiciona o cartao na listagem de cartoes
    usuarioCreditCards.add(card);
    notifyListeners();
  }

  Future<Null> saveCreditCards(BuildContext context, GlobalKey<FormBuilderState> formKey) async {
    var form = formKey.currentState;

    FocusScope.of(context).requestFocus(new FocusNode());

    if(form.validate()) {
      form.save();

      Map params = Map();

      Map usuario = _getUsuarioLogado(context);
      params['usuario'] = usuario['usuario'];
      params['chave'] = usuario['chave'];
      params['cartao'] = form.value;

      showLoading(context);
      Map res = await api.postData('/user/cc/', params);
      hideLoading(context);

      if(res['code'] != '010'){
        await alert(
          context: context,
          title: 'Ops',
          message: res['message'],
        );
        return;
      }

      Navigator.pop(context);

      showLoading(context);
      await getCreditCards(context);
      hideLoading(context);
    }
  }

  Future<Null> deleteCreditCard(BuildContext context, String cartaoId) async {
    showLoading(context);

    Map usuario = _getUsuarioLogado(context);
    String _usuario = usuario['usuario'];
    String _chave = usuario['chave'];

    Map res = await api.deleteData('/user/cc/?usuario=$_usuario&chave=$_chave&id=$cartaoId');
    hideLoading(context);

    if(res['code'] != '010'){
      await alert(
        context: context,
        title: 'Ops',
        message: res['message'],
      );
      return;
    }

    Navigator.pop(context);

    showLoading(context);
    await getCreditCards(context);
    hideLoading(context);
  }

  Future<Null> getPedidos(BuildContext context) async {
    isLoading = true;

    GlobalProvider globalProvider = GlobalProvider(context);
    String _usuario = globalProvider.acessoProvider.usuarioLogado['id'];
    String _chave = globalProvider.acessoProvider.usuarioLogado['chave'] ?? '';

    Map res = await api.getData('/order/?usuario=$_usuario&chave=$_chave');

    if(res['code'] == '010') {
      _pedidos = res['data'];
    }

    isLoading = false;
    notifyListeners();

  }

  Future<Null> getPedido(BuildContext context, String pedidoId) async {
    isLoading = true;

    GlobalProvider globalProvider = GlobalProvider(context);
    String _usuario = globalProvider.acessoProvider.usuarioLogado['id'];
    String _chave = globalProvider.acessoProvider.usuarioLogado['chave'] ?? '';

    Map res = await api.getData('/order/?usuario=$_usuario&chave=$_chave&id=$pedidoId');

    if(res['code'] == '010') {
      _pedido = res['data'][0];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<Map> getPendencias(BuildContext context) async {
    Map usuario = _getUsuarioLogado(context);
    String _usuario = usuario['usuario'];
    String _chave = usuario['chave'];

    showLoading(context);
    Map res = await api.getData('/user/pendency/?usuario=$_usuario&chave=$_chave');
    hideLoading(context);

    return res['data'];

  }

  Future<bool> atualizaCPFTelefone(BuildContext context, GlobalKey<FormBuilderState> formKey) async {
    var form = formKey.currentState;

    FocusScope.of(context).requestFocus(new FocusNode());

    if(form.validate()) {
      form.save();

      Map params = form.value;

      Map usuario = _getUsuarioLogado(context);
      params['usuario'] = usuario['usuario'];
      params['chave'] = usuario['chave'];

      showLoading(context);
      Map res = await api.putData('/user/', params);
      hideLoading(context);

      if(res['code'] == '010'){
        usuarioDados = res['data'];

        GlobalProvider globalProvider = GlobalProvider(context);
        globalProvider.acessoProvider.usuarioLogado['nome'] = usuarioDados['nome'];
        globalProvider.acessoProvider.setUsuarioLogado(globalProvider.acessoProvider.usuarioLogado, context: context);

        return true;
      }

      await alert(
        context: context,
        title: 'Ops',
        message: res['message'],
      );
    }

    return false;

  }

  Future<bool> cadastrarNovoEndereco(BuildContext context, GlobalKey<FormBuilderState> formKey) async {
    var form = formKey.currentState;

    FocusScope.of(context).requestFocus(new FocusNode());

    if(form.validate()) {
      form.save();

      Map params = form.value;

      Map usuario = _getUsuarioLogado(context);
      params['usuario'] = usuario['usuario'];
      params['chave'] = usuario['chave'];

      showLoading(context);
      Map res = await api.postData('/user/address/', params);
      hideLoading(context);

      if(res['code'] == '010'){
        return true;
      }

      await alert(
        context: context,
        title: 'Ops',
        message: res['message'],
      );
    }

    return false;
  }

  Future<bool> alterarEndereco(BuildContext context, String enderecoId, GlobalKey<FormBuilderState> formKey) async {
    var form = formKey.currentState;

    FocusScope.of(context).requestFocus(new FocusNode());

    if(form.validate()) {
      form.save();

      Map params = form.value;

      Map usuario = _getUsuarioLogado(context);
      params['id'] = enderecoId;
      params['usuario'] = usuario['usuario'];
      params['chave'] = usuario['chave'];

      showLoading(context);
      Map res = await api.putData('/user/address/', params);
      hideLoading(context);

      if(res['code'] == '010'){
        return true;
      }

      await alert(
        context: context,
        title: 'Ops',
        message: res['message'],
      );
    }

    return false;
  }

  Future<Null> deletarEndereco(BuildContext context, String enderecoId) async {
    showLoading(context);

    Map usuario = _getUsuarioLogado(context);
    String _usuario = usuario['usuario'];
    String _chave = usuario['chave'];

    Map res = await api.deleteData('/user/address/?usuario=$_usuario&chave=$_chave&id=$enderecoId');

    hideLoading(context);

    if(res['code'] != '010'){
      await alert(
        context: context,
        title: 'Ops',
        message: res['message']
      );

      return;
    }

    this.getEnderecos(context);
  }

  /// saldo do usuário
  Future<Null> getSaldoUsuario(BuildContext context) async {
    isLoading = true;

    Map usuario = _getUsuarioLogado(context);
    String _usuario = usuario['usuario'];
    String _chave = usuario['chave'];

    Map res = await api.getData('/user/balance/?usuario=$_usuario&chave=$_chave');

    if(res['code'] == '010'){
      Provider.of<AcessoProvider>(context, listen: false).usuarioLogado['saldo'] = double.tryParse(res['data']['saldo'].toString());
      notifyListeners();
    }
  }


  Future<Null> saldoGerarBoleto(BuildContext context, String valor) async {
    if(valor == '')
      return;

    showLoading(context, text: 'Gerando seu boleto...');

    Map params = {
      'valor': valor,
    };

    Map usuario = _getUsuarioLogado(context);
    params['usuario'] = usuario['usuario'];
    params['chave'] = usuario['chave'];

    Map res = await api.postData('/user/balance/', params);
    hideLoading(context);

    if(res['code'] == '010'){
      Provider.of<AcessoProvider>(context, listen: false).getSaldoUsuario();
      await getBoletosSaldo(context);

      Navigator.pop(context);

    }else{
      alert(
        context: context,
        title: 'Ops',
        message: res['message'],
      );
    }

  }

  Future<Null> getHistoricoSaldo(BuildContext context) async {
    isLoading = true;

    Map usuario = _getUsuarioLogado(context);
    String _usuario = usuario['usuario'];
    String _chave = usuario['chave'];

    Map res = await api.getData('/user/balance/?usuario=$_usuario&chave=$_chave&type=hystoric');

    if(res['code'] == '010'){
      isLoading = false;
      usuarioHistoricoSaldo = res['data'];
      notifyListeners();
    }
  }

  Future<Null> getBoletosSaldo(BuildContext context) async {
    isLoading = true;

    Map usuario = _getUsuarioLogado(context);
    String _usuario = usuario['usuario'];
    String _chave = usuario['chave'];

    print('/user/balance/?usuario=$_usuario&chave=$_chave&type=billet');

    Map res = await api.getData('/user/balance/?usuario=$_usuario&chave=$_chave&type=billet');

    if(res['code'] == '010'){
      isLoading = false;
      usuarioBoletos = res['data'];
      notifyListeners();
    }
  }

  Future<Null> salvarAvaliacao(BuildContext context, Map voto, String comentario, String empresaId, String avaliacaoId, String acao) async {
    Map usuario = _getUsuarioLogado(context);
    String _usuario = usuario['usuario'];
    String _chave = usuario['chave'];

    Map params = {
      'usuario': _usuario,
      'chave': _chave,
      'nota_comida': voto['comida'],
      'nota_atendimento': voto['atendimento'],
      'comentario': comentario
    };

    Map res;

    showLoading(context, text: 'Processando dados...');

    if(empresaId != '' && acao == 'post'){
      params['empresa_id'] = empresaId;

      res = await api.postData('/global/rating/', params);
    }

    if(avaliacaoId != '' && acao == 'put'){
      params['id'] = avaliacaoId;

      res = await api.putData('/global/rating/', params);
    }

    hideLoading(context);

    if(res['code'] != '010'){
      await alert(
        context: context,
        title: 'Ops',
        message: res['message']
      );

      return;
    }

    await alert(
      context: context,
      title: 'Sucesso!',
      message: res['message']
    );

    Navigator.pop(context);
    Navigator.pop(context);

    this.getPedidos(context);
  }

  Future<Null> deletarAvaliacao(BuildContext context, String avaliacaoId) async {
    Map usuario = _getUsuarioLogado(context);
    String _usuario = usuario['usuario'];
    String _chave = usuario['chave'];

    showLoading(context);
    Map res = await api.deleteData('/global/rating/?id=$avaliacaoId&usuario=$_usuario&chave=$_chave');
    hideLoading(context);

    if(res['code'] != '010'){
      alert(
        context: context,
        title: 'Ops',
        message: res['message']
      );

      return;
    }

    await alert(
      context: context,
      title: 'Sucesso!',
      message: res['message']
    );

    Navigator.pop(context);
    Navigator.pop(context);

    this.getPedidos(context);
  }

  Future<Null> getEmpresasFavoritas(BuildContext context) async {
    isLoading = true;

    Map usuario = _getUsuarioLogado(context);
    String _usuario = usuario['usuario'];
    String _chave = usuario['chave'];

    Map res = await api.getData('/user/favorite/?usuario=$_usuario&chave=$_chave');

    if(res['code'] != '010') return;

    empresasFavoritas = res['data'];
    isLoading = false;
    notifyListeners();
  }

  Future<Map> favoritarEmpresa(BuildContext context, String empresa) async {
    Map usuario = _getUsuarioLogado(context);
    String _usuario = usuario['usuario'];
    String _chave = usuario['chave'];

    Map params = {
      'usuario': _usuario,
      'chave': _chave,
      'empresa': empresa,
    };

    showLoading(context);
    Map res = await api.postData('/user/favorite/', params);
    hideLoading(context);

    return res;
  }

  Future<Map> desfavoritarEmpresa(BuildContext context, String empresa) async {
    Map usuario = _getUsuarioLogado(context);
    String _usuario = usuario['usuario'];
    String _chave = usuario['chave'];

    showLoading(context);
    Map res = await api.deleteData('/user/favorite/?usuario=$_usuario&chave=$_chave&empresa=$empresa');
    hideLoading(context);

    return res;
  }

  Future<Null> enviarRequisicaoParceria(BuildContext context, GlobalKey<FormBuilderState> formKey) async {
    var form = formKey.currentState;

    FocusScope.of(context).requestFocus(FocusNode());

    if(!form.validate()) {
      return;
    }

    form.save();
    print(form.value);

    Map dadosForm = form.value;
    print(dadosForm);

    showLoading(context);

    Map res = await api.getData('/contact?nome=${dadosForm['nomeUsuario']}&email=${dadosForm['email']}&telefone=${dadosForm['telefone']}&assunto=Seja um parceiro - ${dadosForm['nomeEmpresa']}&mensagem=${dadosForm['nomeEmpresa']} de ${dadosForm['cidade']}/${dadosForm['uf']}');

    hideLoading(context);

    if(res != null && res['code'] == '010'){
      await alert(
        context: context,
        title: 'Sucesso!',
        message: res['message'],
      );

      Navigator.pop(context);
      return;
    }

    await alert(
      context: context,
      title: 'Ops',
      message: res != null ? res['message'] : 'Não conseguimos receber sua solicitação :( \ntente novamente ou entre em contato conosco através de nosso site ;)',
    );
  }
}