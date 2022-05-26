import 'package:saveat/model/carrinho/cartao_carrinho.dart';

class PagamentoCarrinho {
  static const String TIPO_PAGAMENTO_CREDITO = 'credito';
  static const String TIPO_PAGAMENTO_SALDO = 'saldo';
  static const String TIPO_PAGAMENTO_SALDO_CARTAO = 'saldo_cartao';
  static const String TIPO_PAGAMENTO_PRESENCIAL = 'presencial';

  String tipo;
  CartaoCarrinho cartao;

  PagamentoCarrinho({this.tipo, this.cartao});

  PagamentoCarrinho.fromJson(Map<String, dynamic> json) {
    tipo = json['tipo'];
    cartao = json['cartao'] != null ? new CartaoCarrinho.fromJson(json['cartao']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tipo'] = this.tipo;
    if (this.cartao != null) {
      data['cartao'] = this.cartao.toJson();
    }
    return data;
  }
}