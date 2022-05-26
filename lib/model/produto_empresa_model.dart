import 'package:saveat/model/item.dart';

class ProdutoEmpresaModel extends Item {
  String id;
  String produto;
  String descricao;
  String valor;
  String foto;
  String cid;

  ProdutoEmpresaModel({
    this.id,
    this.produto,
    this.descricao,
    this.valor,
    this.foto,
    this.cid,
  }) : super(
          id: id,
        );

  ProdutoEmpresaModel.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    id = json['id'];
    produto = json['produto'];
    descricao = json['descricao'];
    valor = json['valor'];
    foto = json['foto'];
    cid = json['cid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['produto'] = this.produto;
    data['descricao'] = this.descricao;
    data['valor'] = this.valor;
    data['foto'] = this.foto;
    data['cid'] = this.cid;
    return data;
  }
}
