class CartaoCarrinho {
  String id;
  String numero;
  String vencimento;
  String cvv;
  String titular;

  CartaoCarrinho({this.id, this.numero, this.vencimento, this.cvv, this.titular});

  CartaoCarrinho.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    numero = json['numero'];
    vencimento = json['vencimento'];
    cvv = json['cvv'];
    titular = json['titular'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['numero'] = this.numero;
    data['vencimento'] = this.vencimento;
    data['cvv'] = this.cvv;
    data['titular'] = this.titular;
    return data;
  }
}