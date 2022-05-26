class EntregaCarrinho {

  static const String TIPO_ENTREGA_DELIVERY = 'delivery';
  static const String TIPO_ENTREGA_RETIRADA = 'retirada';
  static const String TIPO_ENTREGA_CONSUMO = 'consumo';

  String tipo;
  String valor;
  String enderecoId;

  EntregaCarrinho({this.tipo, this.valor, this.enderecoId});

  EntregaCarrinho.fromJson(Map<String, dynamic> json) {
    tipo = json['tipo'];
    valor = json['valor'];
    enderecoId = json['endereco_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tipo'] = this.tipo;
    data['valor'] = this.valor;
    data['endereco_id'] = this.enderecoId;
    return data;
  }
}
