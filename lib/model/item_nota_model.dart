class ItemNotaModel {
  String nota;
  String comentario;
  String data;
  String nome;
  String foto;

  ItemNotaModel({this.nota, this.comentario, this.data, this.nome, this.foto});

  ItemNotaModel.fromJson(Map<String, dynamic> json) {
    nota = json['nota'];
    comentario = json['comentario'];
    data = json['data'];
    nome = json['nome'];
    foto = json['foto'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nota'] = this.nota;
    data['comentario'] = this.comentario;
    data['data'] = this.data;
    data['nome'] = this.nome;
    data['foto'] = this.foto;
    return data;
  }
}