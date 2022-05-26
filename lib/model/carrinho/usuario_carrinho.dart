class UsuarioCarrinho {
  String id;
  String chave;

  UsuarioCarrinho({this.id, this.chave});

  UsuarioCarrinho.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chave = json['chave'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['chave'] = this.chave;
    return data;
  }
}