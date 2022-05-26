class TiposConsumo {
  bool delivery = false;
  bool retirada = false;
  bool consumo = false;

  TiposConsumo({
    this.delivery = false,
    this.retirada = false,
    this.consumo = false,
  });

  TiposConsumo.fromJson(Map<String, dynamic> json) {
    delivery = json['delivery'] == '1';
    retirada = json['retirada'] == '1';
    consumo = json['consumo'] == '1';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['delivery'] = this.delivery ? '1' : '0';
    data['retirada'] = this.retirada ? '1' : '0';
    data['consumo'] = this.consumo ? '1' : '0';
    return data;
  }
}
