import 'package:flutter/material.dart';
import '../api.dart';

class EstabelecimentoCategorias with ChangeNotifier {
  Map estabelecimentoCategorias;
  Api api;
  String categoriaSelecionada;

  EstabelecimentoCategorias(){
    api = Api();
  }

  Future<Null> get() async {
    //TODO ver com o jhonatan o endpoint e de onde tirar as informacoes
    Map res = await api.getData('/category/?order=posicao,asc');
    estabelecimentoCategorias = res;

    notifyListeners();
  }

  void selecionaCategoria(id){
    categoriaSelecionada = id;
    notifyListeners();
  }

  void emptyCategorias(){
    estabelecimentoCategorias = null;
    notifyListeners();
  }
}