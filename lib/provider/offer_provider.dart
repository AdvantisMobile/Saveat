import 'package:flutter/material.dart';
import 'package:saveat/api.dart';
import 'package:saveat/model/produto_empresa_model.dart';
import 'package:saveat/model/produto_model.dart';
import 'package:saveat/provider/global_provider.dart';
import 'package:saveat/provider/location_provider.dart';

class OfertasProvider with ChangeNotifier {
  Api api;
  Map ofertas;
  Map ofertasHome;

  String categoria = '';
  String query = '';
  String cidade = '';
  String horaInicio = '';
  String horaTermino = '';

  OfertasProvider() {
    api = Api();
  }

  Future<Null> get(
    BuildContext context, {
    String limitHome: '20',
  }) async {
    if (ofertas != null) {
      ofertas = null;
      notifyListeners();
    }

    if (cidade == null || cidade.isEmpty) {
      ofertas = null;
      return;
    }

    GlobalProvider globalProvider = GlobalProvider(context);
    String _usuario = globalProvider.acessoProvider.usuarioLogado != null ? globalProvider.acessoProvider.usuarioLogado['id'] : '';

    Map res = await api
        .getData('/offer/?app=1&ativo=1&categoria=$categoria&item=$query&cidade=$cidade&hora_ini=$horaInicio&hora_fim=$horaTermino&usuario=$_usuario&limit_home=$limitHome');
    ofertas = res;

    notifyListeners();
  }

  void clearOfertasHome() {
    if (ofertasHome != null) ofertasHome = null;

    notifyListeners();
  }

  Future<Null> getHome(BuildContext context, {String mostraIndisponivel: '0', String quantidade: '20'}) async {
    if (ofertasHome != null) ofertasHome = null;

    if (cidade == null) return;

    GlobalProvider globalProvider = GlobalProvider(context);
    String _usuario = globalProvider.acessoProvider?.usuarioLogado ?? '';

    Map res = await api.getData(
        '/offer/apphome/?app=1&ativo=1&categoria=$categoria&item=$query&cidade=$cidade&hora_ini=$horaInicio&hora_fim=$horaTermino&usuario=$_usuario&mostraIndisponivel=$mostraIndisponivel&quantidade=$quantidade');
    ofertasHome = res;

    notifyListeners();
  }

  Future<List> getHomeAll(BuildContext context, {String mostraIndisponivel: '0', String quantidade: '20'}) async {
    if (cidade == null) return List();

    GlobalProvider globalProvider = GlobalProvider(context);
    String _usuario = globalProvider.acessoProvider.usuarioLogado ?? '';

    Map res = await api.getData('/offer/apphome/?app=1&ativo=1&item=$query&cidade=$cidade&usuario=$_usuario&mostraIndisponivel=$mostraIndisponivel&quantidade=$quantidade');
    return res['data'];
  }

  Future<List> getAll(BuildContext context) async {
    if (cidade == null) return List();

    GlobalProvider globalProvider = GlobalProvider(context);
    String _usuario = globalProvider.acessoProvider.usuarioLogado ?? '';

    Map res = await api.getData('/offer/?app=1&ativo=1&cidade=$cidade&usuario=$_usuario');
    return res['data'];
  }

  Future<Map> getDistance(String empresa, String destination) async {
    Map res = await GetLocation().getDistanceEmpresa(empresa, destination);
    return res;
  }

  Future<Map> getAvaliacoesEmpresa(String empresa) async {
    Map res = await api.getData('/global/rating/?empresa=$empresa');
    return res['data'];
  }

  Future<ProdutoModel> getProduto(String produtoId) async {
    Map res = await api.getData('/product/product?product_id=$produtoId');
    return ProdutoModel.fromJson(res['data']);
  }
}
