import 'package:flutter/material.dart';
import 'package:saveat/model/categoria_model.dart';

import '../api.dart';

class CategoriasProvider with ChangeNotifier {
  List<CategoriaModel> categorias = List();
  Api api;
  String categoriaSelecionada;

  CategoriasProvider() {
    api = Api();
  }

  Future<Null> get() async {
    Map res = await api.getData('/category/?order=posicao,asc');

    if (res['message'] == "success") {
      categorias.clear();
      for(Map<String, dynamic> categoria in res['data']){
        categorias.add(CategoriaModel.fromJson(categoria));
      }
    }

    notifyListeners();
  }

  Future<Null> getByCidade(cidadeId) async {
    Map res = await api.getData('/category/home?cidade_id=$cidadeId');

    if (res['message'] == "success") {
      categorias.clear();
      for(Map<String, dynamic> categoria in res['data']){
        categorias.add(CategoriaModel.fromJson(categoria));
      }
    }

    notifyListeners();
  }

  void selecionaCategoria(id) {
    categoriaSelecionada = id;
    notifyListeners();
  }

  void emptyCategorias() {
    categorias = null;
    notifyListeners();
  }
}
