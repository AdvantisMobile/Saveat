class CategoriaEmpresaModel {
  String id;
  String categoria;

  CategoriaEmpresaModel({this.id, this.categoria});

  CategoriaEmpresaModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoria = json['categoria'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['categoria'] = this.categoria;
    return data;
  }
}
