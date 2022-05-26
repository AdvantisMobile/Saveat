import 'package:flutter/material.dart';
import 'package:saveat/api.dart';
import 'package:saveat/model/empresa_model.dart';
import 'package:saveat/provider/global_provider.dart';

class CompanyProvider with ChangeNotifier {
  Api api;
  Map estabelecimentos;
  String cidade = '';
  String categoriaSelecionada = '';

  CompanyProvider() {
    api = Api();
  }

  Future<Null> get() async {
    if (estabelecimentos != null) {
      estabelecimentos = null;
      notifyListeners();
    }

    if (cidade == null || cidade.isEmpty) {
      estabelecimentos = null;
      return;
    }

    Map res = await api.getData('/company/home?cidade_id=$cidade&categoria_id=${categoriaSelecionada ?? ''}');
    estabelecimentos = res;

    notifyListeners();
  }

  Future<List> getAll() async {
    Map res = await api.getData('/company/home?cidade_id=$cidade');

    if (res == null) {
      return List();
    }

    return res['data'];
  }

  Future<EmpresaModel> getEmpresa(BuildContext context, String id) async {
    GlobalProvider globalProvider = GlobalProvider(context);
    String _usuario = '';

    if (globalProvider.acessoProvider.usuarioLogado != null) {
      _usuario = globalProvider.acessoProvider.usuarioLogado['id'];
    }

    Map res = await api.getData('/company/app-pagina?empresa_id=$id&usuario=$_usuario');

    if (res == null) {
      return null;
    }

    return EmpresaModel.fromJson(res['data']);
  }
}
