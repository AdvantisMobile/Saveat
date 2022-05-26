import 'package:saveat/model/anuncio_empresa_model.dart';
import 'package:saveat/model/carrinho/entrega_carrinho.dart';
import 'package:saveat/model/carrinho/pagamento_carrinho.dart';
import 'package:saveat/model/carrinho/pagamento_presencial_carrinho.dart';
import 'package:saveat/model/carrinho/usuario_carrinho.dart';
import 'package:saveat/model/empresa_model.dart';
import 'package:saveat/model/produto_model.dart';

class CarrinhoModel {
  UsuarioCarrinho usuario;
  EmpresaModel empresa;
  List<AnuncioEmpresaModel> anuncio = List();
  List<ProdutoModel> produto = List();
  EntregaCarrinho entrega;
  PagamentoCarrinho pagamento;
  PagamentoPresencialCarrinho pagamentoPresencial;

  CarrinhoModel({
    this.usuario,
    this.empresa,
    this.anuncio,
    this.produto,
    this.entrega,
    this.pagamento,
    this.pagamentoPresencial,
  });

  CarrinhoModel.fromJson(Map<String, dynamic> json) {
    usuario = json['usuario'] != null ? new UsuarioCarrinho.fromJson(json['usuario']) : null;
    empresa = json['empresa'] != null ? new EmpresaModel.fromJson(json['empresa']) : null;
    if (json['anuncio'] != null) {
      anuncio = new List<AnuncioEmpresaModel>();
      json['anuncio'].forEach((v) {
        anuncio.add(new AnuncioEmpresaModel.fromJson(v));
      });
    }

    if (json['produto'] != null) {
      produto = new List<ProdutoModel>();
      json['produto'].forEach((v) {
        produto.add(new ProdutoModel.fromJson(v));
      });
    }

    entrega = json['entrega'] != null ? new EntregaCarrinho.fromJson(json['entrega']) : null;
    pagamento = json['pagamento'] != null ? new PagamentoCarrinho.fromJson(json['pagamento']) : null;
    pagamentoPresencial = json['pagamentoPresencial'] != null ? new PagamentoPresencialCarrinho.fromJson(json['pagamentoPresencial']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.usuario != null) {
      data['usuario'] = this.usuario.toJson();
    }

    if (this.empresa != null) {
      data['empresa'] = this.empresa.toJson();
    }

    if (this.anuncio != null) {
      data['anuncio'] = this.anuncio.map((v) => v.toJson()).toList();
    }

    if (this.produto != null) {
      data['produto'] = this.produto.map((v) => v.toJson()).toList();
    }

    if (this.entrega != null) {
      data['entrega'] = this.entrega.toJson();
    }

    if (this.pagamento != null) {
      data['pagamento'] = this.pagamento.toJson();
    }

    if (this.pagamentoPresencial != null) {
      data['pagamentoPresencial'] = this.pagamentoPresencial.toJson();
    }

    return data;
  }

  bool hasitens() {
    return produto.isNotEmpty || anuncio.isNotEmpty;
  }

  Map<String, dynamic> toJsonEnvioServidor() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.usuario != null) {
      data['usuario'] = this.usuario.toJson();
    }

    if (this.empresa != null) {
      data['empresa'] = _converterEmpresaEnvioServidor(this.empresa);
    }

    if (this.anuncio != null) {
      List a = List();
      data['anuncio'] = this.anuncio.map((v) => _converterAnuncioEnvioServidor(v)).toList();
    }

    if (this.produto != null) {
      data['produto'] = this.produto.map((v) => _converterProdutoEnvioServidor(v)).toList();
    }

    if (this.entrega != null) {
      data['entrega'] = this.entrega.toJson();
    }

    if (this.pagamento != null) {
      data['pagamento'] = this.pagamento.toJson();
    }

    if (this.pagamentoPresencial != null) {
      data['pagamentoPresencial'] = this.pagamentoPresencial.toJson();
    }

    return data;
  }

  Map<String, dynamic> _converterProdutoEnvioServidor(ProdutoModel produtoModel) {
    final Map<String, dynamic> produtoMap = Map<String, dynamic>();

    produtoMap['id'] = produtoModel.id;
    produtoMap['quantidade'] = produtoModel.quantidade;
    produtoMap['variacao_id'] = produtoModel.produtoVariacao;

    return produtoMap;
  }

  Map<String, dynamic> _converterAnuncioEnvioServidor(AnuncioEmpresaModel anuncio) {
    final Map<String, dynamic> anuncioMap = Map<String, dynamic>();

    anuncioMap['id'] = anuncio.id;
    anuncioMap['valor'] = anuncio.valor;
    anuncioMap['quantidade'] = anuncio.quantidade;

    return anuncioMap;
  }

  Map<String, dynamic> _converterEmpresaEnvioServidor(EmpresaModel empresaModel) {
    final Map<String, dynamic> empresaMap = Map<String, dynamic>();

    empresaMap['id'] = empresaModel.id;

    return empresaMap;
  }
}
