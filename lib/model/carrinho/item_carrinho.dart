import 'package:saveat/model/item.dart';

abstract class ItemCarrinho extends Item {
  String id;
  int quantidade;
  double valor;
  String nome;
  String foto;
  String descricao;

  ItemCarrinho({
    this.id,
    this.quantidade,
    this.valor,
    this.nome,
    this.foto,
    this.descricao = '',
  }) : super(
          id: id,
        );

  ItemCarrinho.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    id = json['id'];
    quantidade = json['quantidade'];
    valor = double.tryParse(json['valor'] ?? '0');
    nome = json['nome'];
    foto = json['foto'];
    descricao = json['descricao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['quantidade'] = this.quantidade;
    data['valor'] = this.valor;
    data['nome'] = this.nome;
    data['foto'] = this.foto;
    data['descricao'] = this.descricao;
    return data;
  }
}
