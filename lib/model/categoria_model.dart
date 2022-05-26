import 'package:saveat/model/produto_empresa_model.dart';

class CategoriaModel {
  String id;
  String categoria;
  String imagem;
  List<ProdutoEmpresaModel> produtos = List();

  static const String ID_CATEGORIA_TODOS = '0';

  CategoriaModel({
    this.id,
    this.categoria,
    this.imagem,
  });

  CategoriaModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoria = json['categoria'];
    if (json['imagem'] != null) {
      imagem = 'https://sistema.saveat.com.br/arquivos/categorias/' + json['imagem'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['categoria'] = this.categoria;
    data['imagem'] = this.imagem;
    return data;
  }
}
