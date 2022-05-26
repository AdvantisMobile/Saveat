class ProdutoTipoVariacaoModel {
  String id;
  String nome;
  String multi;

  ProdutoTipoVariacaoModel({this.id, this.nome, this.multi});

  ProdutoTipoVariacaoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    multi = json['multi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nome'] = this.nome;
    data['multi'] = this.multi;
    return data;
  }
}