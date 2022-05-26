class PagamentoPresencialCarrinho {
  String forma;
  String troco;

  PagamentoPresencialCarrinho({
    this.forma,
    this.troco,
  });

  PagamentoPresencialCarrinho.fromJson(Map<String, dynamic> json) {
    forma = json['forma'];
    troco = json['troco'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['forma'] = this.forma;
    data['troco'] = this.troco;

    return data;
  }
}
