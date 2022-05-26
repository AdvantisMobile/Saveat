import 'package:saveat/model/carrinho/item_carrinho.dart';

class AnuncioEmpresaModel extends ItemCarrinho {
  String id;
  String nome;
  String foto;
  int quantidadeRestante;
  double valorOriginal;
  double valor;
  int quantidade;

  AnuncioEmpresaModel({
    this.nome,
    this.foto,
    this.quantidadeRestante,
    this.valorOriginal,
    this.id,
    this.valor,
    this.quantidade,
  }) : super(
          id: id,
          nome: nome,
          quantidade: quantidade,
          foto: foto,
          valor: valor,
        );

  AnuncioEmpresaModel.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    id = json['id'];
    nome = json['item'];
    foto = json['foto'];
    quantidadeRestante = int.tryParse(json['quantidade_restante']) ?? 0;
    valorOriginal = double.tryParse(json['valor_original']) ?? 0;
    valor = double.tryParse(json['valor']) ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['item'] = this.nome;
    data['foto'] = this.foto;
    data['quantidade_restante'] = this.quantidadeRestante;
    data['valor_original'] = this.valorOriginal;
    data['valor'] = this.valor;
    return data;
  }

  double desconto() {
    return (this.valor * 100) / this.valorOriginal;
  }
}
