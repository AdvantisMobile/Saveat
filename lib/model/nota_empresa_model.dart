import 'package:saveat/model/item_nota_model.dart';

class NotaEmpresaModel {
  String nota;
  String total;
  List<ItemNotaModel> itens;

  NotaEmpresaModel({this.nota, this.total, this.itens});

  NotaEmpresaModel.fromJson(Map<String, dynamic> json) {
    nota = json['nota'];
    total = json['total'];
    if (json['itens'] != null) {
      itens = List<ItemNotaModel>();
      json['itens'].forEach((v) {
        itens.add(ItemNotaModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['nota'] = this.nota;
    data['total'] = this.total;
    if (this.itens != null) {
      data['itens'] = this.itens.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
