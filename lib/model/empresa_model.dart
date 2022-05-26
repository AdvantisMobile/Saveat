import 'package:saveat/model/anuncio_empresa_model.dart';
import 'package:saveat/model/categoria_model.dart';
import 'package:saveat/model/nota_empresa_model.dart';
import 'package:saveat/model/produto_empresa_model.dart';
import 'package:saveat/model/tipos_consumo.dart';
import 'package:saveat/model/tipos_recebimento.dart';

class EmpresaModel {
  String id = '';
  String empresa = '';
  String latlng = '';
  String aberto = '';
  String foto = '';
  String logo = '';
  String endereco = '';
  String endnum = '';
  String complemento = '';
  String bairro = '';
  String cidade = '';
  String uf = '';
  String cep = '';
  String avaliacao = '';
  String fotoAnuncio = '';
  double entregaGratis = 0;
  String descricao = '';
  String fotoBase = '';
  String telefone = '';
  bool delivery = false;
  bool retirada = false;
  bool consumo = false;
  bool favoritado = false;
  double custoMinimo = 0;
  NotaEmpresaModel nota;
  List<CategoriaModel> categorias = List();
  List<AnuncioEmpresaModel> anuncios = List();
  TiposConsumo tiposConsumo;
  TiposRecebimento tiposRecebimento;
  String deliveryCustoMinimo;
  String deliveryFreteGratis;

  EmpresaModel({
    this.id,
    this.empresa,
    this.latlng,
    this.aberto,
    this.foto,
    this.logo,
    this.endereco,
    this.endnum,
    this.complemento,
    this.bairro,
    this.cidade,
    this.uf,
    this.cep,
    this.avaliacao,
    this.fotoAnuncio,
    this.entregaGratis,
    this.descricao,
    this.fotoBase,
    this.categorias,
    this.tiposConsumo,
    this.tiposRecebimento,
    this.deliveryCustoMinimo,
    this.deliveryFreteGratis,
  });

  EmpresaModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> jsonEmpresa = json['empresa'];
    List jsonCategorias = jsonEmpresa['categorias'];
    List jsonProdutos = jsonEmpresa['produtos'];
    List jsonAnuncios = jsonEmpresa['anuncios'];

    id = jsonEmpresa['id'];
    empresa = jsonEmpresa['empresa'];
    latlng = jsonEmpresa['latlng'];
    aberto = jsonEmpresa['aberto'];
    foto = jsonEmpresa['foto'];
    logo = jsonEmpresa['logo'];
    endereco = jsonEmpresa['endereco'];
    endnum = jsonEmpresa['endnum'];
    complemento = jsonEmpresa['complemento'];
    bairro = jsonEmpresa['bairro'];
    cidade = jsonEmpresa['cidade'];
    uf = jsonEmpresa['uf'];
    cep = jsonEmpresa['cep'];
    avaliacao = jsonEmpresa['avaliacao'];
    fotoAnuncio = jsonEmpresa['foto_anuncio'];
    entregaGratis = double.tryParse(jsonEmpresa['entrega_gratis'] ?? '') ?? 0;
    descricao = jsonEmpresa['descricao'];
    fotoBase = jsonEmpresa['foto_empresa'];
    deliveryFreteGratis = jsonEmpresa['delivery_frete_gratis'];
    deliveryCustoMinimo = jsonEmpresa['delivery_custo_minimo'];

    tiposRecebimento = jsonEmpresa['tipos_recebimento'] != null && jsonEmpresa['tipos_recebimento'] != ''
        ? new TiposRecebimento.fromJson(jsonEmpresa['tipos_recebimento'])
        : TiposRecebimento();

    tiposConsumo = jsonEmpresa['tipos_consumo'] != null && jsonEmpresa['tipos_consumo'] != ''
        ? new TiposConsumo.fromJson(jsonEmpresa['tipos_consumo'])
        : TiposConsumo();

    var _categoriaTodos = CategoriaModel(
      id: CategoriaModel.ID_CATEGORIA_TODOS,
      categoria: 'Todos',
    );

    categorias.add(_categoriaTodos);

    if (jsonCategorias != null) {
      for (Map<String, dynamic> categoria in jsonCategorias) {
        categorias.add(CategoriaModel.fromJson(categoria));
      }
    }

    if (jsonProdutos != null) {
      for (Map<String, dynamic> produtoMap in jsonProdutos) {
        ProdutoEmpresaModel produto = ProdutoEmpresaModel.fromJson(produtoMap);

        categorias.where((c) => c.id == produto.cid).forEach((c) => c.produtos.add(produto));

        if (categorias.length == 1) {
          _categoriaTodos.produtos.add(produto);
        }
      }
    }

    if (jsonAnuncios != null) {
      for (Map<String, dynamic> anuncio in jsonAnuncios) {
        anuncios.add(AnuncioEmpresaModel.fromJson(anuncio));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['empresa'] = this.empresa;
    data['latlng'] = this.latlng;
    data['aberto'] = this.aberto;
    data['foto'] = this.foto;
    data['logo'] = this.logo;
    data['endereco'] = this.endereco;
    data['endnum'] = this.endnum;
    data['complemento'] = this.complemento;
    data['bairro'] = this.bairro;
    data['cidade'] = this.cidade;
    data['uf'] = this.uf;
    data['cep'] = this.cep;
    data['avaliacao'] = this.avaliacao;
    data['foto_anuncio'] = this.fotoAnuncio;
    data['entrega_gratis'] = this.entregaGratis;
    data['descricao'] = this.descricao;
    data['foto_base'] = this.fotoBase;
    data['delivery_frete_gratis'] = this.deliveryFreteGratis;
    data['delivery_custo_minimo'] = this.deliveryCustoMinimo;

    if (this.tiposRecebimento != null) {
      data['tipos_recebimento'] = this.tiposRecebimento.toJson();
    }

    if (this.tiposConsumo != null) {
      data['tipos_consumo'] = this.tiposConsumo.toJson();
    }

    return data;
  }
}
