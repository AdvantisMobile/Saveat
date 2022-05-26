import 'package:rxdart/rxdart.dart';
import 'package:saveat/model/anuncio_empresa_model.dart';
import 'package:saveat/model/carrinho/carrinho_model.dart';
import 'package:saveat/model/carrinho/entrega_carrinho.dart';
import 'package:saveat/model/carrinho/item_carrinho.dart';
import 'package:saveat/model/carrinho/pagamento_carrinho.dart';
import 'package:saveat/model/empresa_model.dart';
import 'package:saveat/model/produto_model.dart';

class CartBloc {
  List<CarrinhoModel> listCarrinhos = List<CarrinhoModel>();
  List compreJunto = List();
  double valorTotalCompra = 0;
  double valorTotalProdutos = 0;
  double valorEntrega = 0;
  Map enderecoSelecionado = Map();
  String observacaoPedido = '';
  Map cupomSelecionado = Map();
  Map cartaoSelecionado = Map();
  Map pagamentoTipo = Map();
  double pagamentoSaldo = 0;

  final BehaviorSubject<List> _carrinhoController = BehaviorSubject<List>();
  final BehaviorSubject<double> _valorCompra = BehaviorSubject<double>.seeded(0);
  final BehaviorSubject<List> _compreJuntoController = BehaviorSubject<List>();
  final BehaviorSubject<String> _consumoController = BehaviorSubject<String>();
  final BehaviorSubject<Map> _enderecoSelecionadoController = BehaviorSubject<Map>();
  final BehaviorSubject<String> _observacaoPedidoController = BehaviorSubject<String>();
  final BehaviorSubject<Map> _cupomDescontoController = BehaviorSubject<Map>();
  final BehaviorSubject<String> _pagamentoTipoController = BehaviorSubject<String>();
  final BehaviorSubject<Map> _cartaoSelecionadoController = BehaviorSubject<Map>();
  final BehaviorSubject<bool> _liberaPagamentoController = BehaviorSubject<bool>.seeded(false);

  Stream<List> get outCarrinho => _carrinhoController.stream;

  Stream<double> get outValorCompra => _valorCompra.stream;

  Stream<List> get outCompreJunto => _compreJuntoController.stream;

  Stream<String> get outConsumo => _consumoController.stream;

  Stream<Map> get outEnderecoSelecionado => _enderecoSelecionadoController.stream;

  Stream<String> get outObservacaoPedido => _observacaoPedidoController.stream;

  Stream<Map> get outCupomDesconto => _cupomDescontoController.stream;

  Stream<String> get outPagamentoTipo => _pagamentoTipoController.stream;

  Stream<Map> get outCartaoSelecionado => _cartaoSelecionadoController.stream;

  Stream<bool> get outLiberaPagamento => _liberaPagamentoController.stream;

  CarrinhoModel getCarrinhoDaEmpresa(String empresaId) {
    if (listCarrinhos == null) {
      return null;
    }

    int index = listCarrinhos.indexWhere((ce) => ce.empresa.id == empresaId);
    return index == -1 ? null : listCarrinhos[index];
  }

  void setItem(EmpresaModel empresa, ItemCarrinho item) {
    CarrinhoModel carrinho;

    final int index = listCarrinhos.indexWhere((ce) => ce.empresa.id == empresa.id);
    final bool novaAdicao = index == -1;

    if (novaAdicao) {
      carrinho = CarrinhoModel();
      carrinho.empresa = empresa;
    } else {
      carrinho = listCarrinhos[index];
    }

    switch (item.runtimeType) {
      case AnuncioEmpresaModel:
        _setAnuncioCarrinho(item, carrinho);
        break;
      case ProdutoModel:
        _setProdutoCarrinho(item, carrinho);
        break;
    }

    novaAdicao ? listCarrinhos.add(carrinho) : listCarrinhos[index] = carrinho;
    _carrinhoController.add(listCarrinhos);
  }

  void deleteItem(String empresaId, ItemCarrinho item) {
    CarrinhoModel carrinho = getCarrinhoDaEmpresa(empresaId);

    switch (item.runtimeType) {
      case AnuncioEmpresaModel:
        carrinho.anuncio.remove(item);
        break;
      case ProdutoModel:
        carrinho.produto.remove(item);
        break;
    }

    listCarrinhos[listCarrinhos.indexOf(carrinho)] = carrinho;
    _carrinhoController.add(listCarrinhos);

    this.processaCupomDesconto(empresaId, null);
    this.selecionaPagamentoTipo(_pagamentoTipoController.stream.value);
    this.selecionaConsumo(empresaId, _consumoController.stream.value);
    this.calculaValorTotal(empresaId);
  }

  void clearCarrinhos(String empresaId) {
    listCarrinhos = List();
    _carrinhoController.add(listCarrinhos);
  }

  void atualizarQuantidade(String empresaId, ItemCarrinho item, int quantidade) {
    CarrinhoModel carrinho = getCarrinhoDaEmpresa(empresaId);

    switch (item.runtimeType) {
      case AnuncioEmpresaModel:
        carrinho.anuncio.firstWhere((a) => a.id == item.id).quantidade = quantidade;
        break;
      case ProdutoModel:
        carrinho.produto.firstWhere((a) => a.id == item.id).quantidade = quantidade;
        break;
    }

    listCarrinhos[listCarrinhos.indexOf(carrinho)] = carrinho;
    _carrinhoController.add(listCarrinhos);

    this.processaCupomDesconto(empresaId, null);
    this.selecionaPagamentoTipo(_pagamentoTipoController.stream.value);
    this.selecionaConsumo(empresaId, _consumoController.stream.value);
    this.calculaValorTotal(empresaId);
  }

  void selecionaConsumo(String empresaId, String tipo) {
    if (empresaId != null) {
      CarrinhoModel carrinho = getCarrinhoDaEmpresa(empresaId);

      if (carrinho.entrega == null) {
        carrinho.entrega = EntregaCarrinho();
      }

      carrinho.entrega.tipo = tipo;

      listCarrinhos[listCarrinhos.indexOf(carrinho)] = carrinho;
      _carrinhoController.add(listCarrinhos);
    }

    _consumoController.add(tipo);
    this.processaCupomDesconto(empresaId, null);
  }

  void selecionaEndereco(Map endereco, String empresaId, {double custo}) {
    if (endereco != null) {
      endereco['custo_temp'] = endereco['custo_temp'] == null ? endereco['custo'] : endereco['custo_temp'];
      endereco['custo'] = custo != null ? custo : endereco['custo_temp'];
    }

    enderecoSelecionado = endereco;
    _enderecoSelecionadoController.add(enderecoSelecionado);

    this.selecionaPagamentoTipo(_pagamentoTipoController.stream.value);
    this.calculaValorTotal(empresaId);
  }

  void salvarObservacao(String texto) {
    observacaoPedido = texto;
    _observacaoPedidoController.add(observacaoPedido);
  }

  void processaCupomDesconto(String empresaId, Map cupom) {
    cupomSelecionado = cupom;
    _cupomDescontoController.add(cupomSelecionado);
    this.calculaValorTotal(empresaId);
  }

  void selecionaPagamentoTipo(String tipo, {int forma: 3, String troco: '0', double saldo: 0, String empresaId}) {
    pagamentoTipo = {
      'tipo': tipo,
      'forma': forma != null ? forma : pagamentoTipo['forma'],
      'troco': troco != '' ? troco : pagamentoTipo['troco'],
      'saldo': saldo,
    };

    _pagamentoTipoController.add(tipo);

    if (empresaId != null) {
      CarrinhoModel carrinho = getCarrinhoDaEmpresa(empresaId);

      if (carrinho.pagamento == null) {
        carrinho.pagamento = PagamentoCarrinho();
      }

      carrinho.pagamento.tipo = tipo;

      listCarrinhos[listCarrinhos.indexOf(carrinho)] = carrinho;
      _carrinhoController.add(listCarrinhos);
    }

    this.getLiberaPagamento();
  }

  void selecionaCartao(Map cartao) {
    cartaoSelecionado = cartao;
    _cartaoSelecionadoController.add(cartaoSelecionado);

    this.getLiberaPagamento();
  }

  void calculaValorTotal(String empresaId) {
    double valorTotalCompra = 0;
    _valorCompra.add(valorTotalCompra);

    CarrinhoModel _carrinho = getCarrinhoDaEmpresa(empresaId);
    if (_carrinho == null) {
      return;
    }

    valorTotalCompra = calcularValorItens(_carrinho);
    valorTotalCompra += _calcularValorEntrega();

    if (cupomSelecionado != null) {
      valorTotalProdutos -= calcularDescontoCupom(_carrinho);
    }

    _valorCompra.add(valorTotalCompra);

    this.getLiberaPagamento();
  }

  double calcularValorItens(CarrinhoModel carrinho) {
    double valorTotalProdutos = 0;

    if (carrinho.anuncio != null) {
      carrinho.anuncio.forEach((a) => valorTotalProdutos += a.quantidade * a.valor);
    }

    if (carrinho.produto != null) {
      carrinho.produto.forEach((p) => valorTotalProdutos += p.quantidade * p.valor);
    }

    return valorTotalProdutos;
  }

  double calcularDescontoCupom(CarrinhoModel carrinho) {
    String _cupomTipo = cupomSelecionado['tipo'];
    double valorTotalProdutos = 0;
    double valorEntrega = 0;
    double desconto = 0;

    if (_cupomTipo == '1') {
      valorTotalProdutos = calcularValorItens(carrinho);
      desconto = (valorTotalProdutos * double.tryParse(cupomSelecionado['valor'])) / 100;
      return desconto;
    }

    if (_cupomTipo == '2') {
      valorTotalProdutos = calcularValorItens(carrinho);
      desconto = double.tryParse(cupomSelecionado['valor']);

      if (desconto > valorTotalProdutos) {
        desconto = valorTotalProdutos;
      }

      return desconto;
    }

    if (_cupomTipo == '3') {
      valorEntrega = _calcularValorEntrega();
      desconto = (valorEntrega * double.tryParse(cupomSelecionado['valor'])) / 100;
      return desconto;
    }

    return desconto;
  }

  void getLiberaPagamento() {
    bool libera = true;

    if (_consumoController.value == '') {
      libera = false;
    }

    if (_consumoController.value == 'delivery' && _enderecoSelecionadoController.value['id'] == null) {
      libera = false;
    }

    if (_pagamentoTipoController.value == null) {
      libera = false;
    }

    if ((_pagamentoTipoController.value == 'credito' || _pagamentoTipoController.value == 'saldo_cartao') && _cartaoSelecionadoController.value == null) {
      libera = false;
    }

    _liberaPagamentoController.add(libera);
  }

  double _calcularValorEntrega() {
    return enderecoSelecionado != null && enderecoSelecionado['custo'] != null && double.tryParse(enderecoSelecionado['custo'].toString()) > 0 ? double.tryParse(enderecoSelecionado['custo'].toString()) : 0;
  }

  void _setAnuncioCarrinho(AnuncioEmpresaModel anuncioCarrinho, CarrinhoModel carrinho) {
    if (carrinho.anuncio == null) {
      carrinho.anuncio = List();
    }

    if (carrinho.anuncio.contains(anuncioCarrinho)) {
      carrinho.anuncio.firstWhere((p) => p.id == anuncioCarrinho.id).quantidade++;
      return;
    }

    carrinho.anuncio.add(anuncioCarrinho);
  }

  void _setProdutoCarrinho(ProdutoModel produto, CarrinhoModel carrinho) {
    if (carrinho.produto == null) {
      carrinho.produto = List();
    }

    if (produto.quantidade == null) {
      produto.quantidade = 1;
    }

    if (carrinho.produto.contains(produto)) {
      carrinho.produto.firstWhere((p) => p.id == produto.id).quantidade++;
      return;
    }

    carrinho.produto.add(produto);
  }

  void dispose() {
    _carrinhoController.close();
    _valorCompra.close();
    _compreJuntoController.close();
    _consumoController.close();
    _enderecoSelecionadoController.close();
    _observacaoPedidoController.close();
    _cupomDescontoController.close();
    _pagamentoTipoController.close();
    _cartaoSelecionadoController.close();
    _liberaPagamentoController.close();
  }
}
