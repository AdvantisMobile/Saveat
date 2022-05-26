import 'package:saveat/model/carrinho/item_carrinho.dart';
import 'package:saveat/model/produto_tipo_variacao.dart';
import 'package:saveat/model/produto_variacao_model.dart';

class ProdutoModel extends ItemCarrinho {
  String id;
  String nome;
  String descricao;
  double valor;
  String foto;
  String cid;
  List<ProdutoVariacaoModel> produtoVariacao = List();
  List<ProdutoTipoVariacaoModel> produtoTipoVariacao = List();
  int quantidade;

  ProdutoModel({
    this.id,
    this.nome,
    this.descricao,
    this.valor,
    this.foto,
    this.cid,
    this.produtoVariacao,
    this.produtoTipoVariacao,
    this.quantidade,
  }) : super(
          id: id,
          nome: nome,
          quantidade: quantidade,
          foto: foto,
          valor: valor,
        );

  ProdutoModel.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    Map<String, dynamic> jsonProduto = json['produto'] == '' ? {} : json['produto'];
    List jsonProdutoVariacao = json['produto_variacao'];
    List jsonProdutoTipoVariacao = json['produto_tipo_variacao'];

    id = jsonProduto['id'];
    nome = jsonProduto['produto'];
    descricao = jsonProduto['descricao'];
    valor = double.tryParse(jsonProduto['valor'] ?? '0');
    foto = jsonProduto['foto'];
    cid = jsonProduto['cid'];

    for (Map<String, dynamic> variacao in jsonProdutoVariacao) {
      produtoVariacao.add(ProdutoVariacaoModel.fromJson(variacao));
    }

    for (Map<String, dynamic> tipoVariacao in jsonProdutoTipoVariacao) {
      produtoTipoVariacao.add(ProdutoTipoVariacaoModel.fromJson(tipoVariacao));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['produto'] = this.nome;
    data['descricao'] = this.descricao;
    data['valor'] = this.valor;
    data['foto'] = this.foto;
    data['cid'] = this.cid;
    data['quantidade'] = this.quantidade;

    if (this.produtoVariacao != null) {
      data['produto_variacao'] = this.produtoVariacao.map((v) => v.toJson()).toList();
    }

    if (this.produtoTipoVariacao != null) {
      data['produto_tipo_variacao'] = this.produtoTipoVariacao.map((v) => v.toJson()).toList();
    }

    return data;
  }
}
