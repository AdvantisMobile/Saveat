class ProdutoVariacaoModel {
  String id;
  String tipoVariacao;
  String nome;
  String valor;

  ProdutoVariacaoModel({this.id, this.tipoVariacao, this.nome, this.valor});

  ProdutoVariacaoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tipoVariacao = json['tipo_variacao'];
    nome = json['nome'];
    valor = json['valor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['tipo_variacao'] = this.tipoVariacao;
    data['nome'] = this.nome;
    data['valor'] = this.valor;
    return data;
  }
}
