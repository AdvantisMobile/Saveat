class TiposRecebimento {
  bool saldo;
  bool credito;
  bool presencial;

  TiposRecebimento({
    this.saldo = false,
    this.credito = false,
    this.presencial = false,
  });

  TiposRecebimento.fromJson(Map<String, dynamic> json) {
    saldo = json['saldo'] == '1';
    credito = json['credito'] == '1';
    presencial = json['presencial'] == '1';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['saldo'] = this.saldo ? '1' : '0';
    data['credito'] = this.credito ? '1' : '0';
    data['presencial'] = this.presencial ? '1' : '0';
    return data;
  }
}
