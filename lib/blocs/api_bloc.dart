import 'package:rxdart/rxdart.dart';
import 'package:saveat/api.dart';

class ApiBloc {

  Api api = Api();
  List cartaoUsuario = List();

  final BehaviorSubject<List> _compreJuntoController = BehaviorSubject<List>();
  Stream<List> get outCompreJunto => _compreJuntoController.stream;

  final BehaviorSubject<List> _enderecosClienteController = BehaviorSubject<List>();
  Stream<List> get outEnderecosCliente => _enderecosClienteController.stream;

  final BehaviorSubject<double> _saldoUsuarioController = BehaviorSubject<double>();
  Stream<double> get outSaldoUsuario => _saldoUsuarioController.stream;

  final BehaviorSubject<List> _cartaoCreditoUsuarioController = BehaviorSubject<List>();
  Stream<List> get outCartaoCreditoUsuario => _cartaoCreditoUsuarioController.stream;

  final BehaviorSubject<Map> _pedidoClienteController = BehaviorSubject<Map>();
  Stream<Map> get outPedidocliente => _pedidoClienteController.stream;

  final BehaviorSubject<List> _empresasFavoritasController = BehaviorSubject<List>();
  Stream<List> get outEmpresasFavoritas => _empresasFavoritasController.stream;

  void fetchCompreJunto(String empresaId) async {
    _compreJuntoController.add(null);
    Map res = await api.getData('/global/?search=buytogether&empresa=$empresaId');
    _compreJuntoController.add(res['data']);
  }

  void fetchEnderecosCliente(String empresaId) async {
    _enderecosClienteController.add(null);
    String _usuario = globalUsuarioLogado['id'];
    String _chave = globalUsuarioLogado['chave'];

    Map res = await api.getData('/user/address/?usuario=$_usuario&chave=$_chave&origin=$empresaId');
    _enderecosClienteController.add(res['data']);
  }

  Future<Map> postClientAddress(String empresaId, Map params) async {
    params['usuario'] = globalUsuarioLogado['id'];
    params['chave'] = globalUsuarioLogado['chave'];
    Map res = await api.postData('/user/address/', params);

    if(res['code'] == '010')
      this.fetchEnderecosCliente(empresaId);

    return res;
  }

  Future<Map> getCupomDesconto(String cupom, double valor) async {
    Map res = await api.getData('/global/?search=coupon&cupom=$cupom&valor=${valor.toString()}');
    return res;
  }

  void getSaldoUsuario() async {
    if(globalUsuarioLogado == null) return;

    String usuarioId = globalUsuarioLogado['id'];
    String chave = globalUsuarioLogado['chave'];
    Map res = await api.getData('/user/balance/?usuario=$usuarioId&chave=$chave');

    double saldo = 0;
    if(res['code'] == '010')
      saldo = double.tryParse(res['data']['saldo']);

    _saldoUsuarioController.add(saldo);
  }

  void getCartaoCreditoUsuario() async {
    _cartaoCreditoUsuarioController.add(null);

    String usuarioId = globalUsuarioLogado['id'];
    String chave = globalUsuarioLogado['chave'];
    Map res = await api.getData('/user/cc/?usuario=$usuarioId&chave=$chave');

    List out = List();
    if(res['code'] == '010')
      out = res['data'];

    cartaoUsuario = out;
    _cartaoCreditoUsuarioController.add(cartaoUsuario);
  }

  void addCartaoTemp(Map cartao){
    cartaoUsuario.add(cartao);
    _cartaoCreditoUsuarioController.add(cartaoUsuario);
  }

  Future<Map> postPedido(Map pedido) async {
    String usuarioId = globalUsuarioLogado['id'];
    String chave = globalUsuarioLogado['chave'];

    Map usuario = {
      'id': usuarioId,
      'chave': chave,
    };

    pedido['usuario'] = usuario;

    return await api.postData('/order/new/', pedido);
  }

  void getPedidoCliente(String pedidoId) async {
    String _usuario = globalUsuarioLogado['id'];
    String _chave = globalUsuarioLogado['chave'];

    _pedidoClienteController.add(null);
    Map res = await api.getData('/order/?usuario=$_usuario&chave=$_chave&id=$pedidoId');
    _pedidoClienteController.add(res['data'][0]);
  }

  Future<Map> getPendencias() async {
    String _usuario = globalUsuarioLogado['id'];
    String _chave = globalUsuarioLogado['chave'];

    Map res = await api.getData('/user/pendency/?usuario=$_usuario&chave=$_chave');
    return res['data'];
  }

  Future<Map> atualizaCPFTelefone(Map params) async {
    params['usuario'] = globalUsuarioLogado['id'];
    params['chave'] = globalUsuarioLogado['chave'];

    return await api.putData('/user/', params);
  }

  void getEmpresasFavoritas() async {
    _empresasFavoritasController.add(null);
    String _usuario = globalUsuarioLogado['id'];
    String _chave = globalUsuarioLogado['chave'];
    String _cidadeId = globalCidadeAtual['id'];

    Map res = await api.getData('/user/favoritecompany/?usuario=$_usuario&chave=$_chave&cidade=$_cidadeId');
    _empresasFavoritasController.add(res['data']);
  }

  Future<Map> getOferta(String id) async {
    Map res = await api.getData('/offer/?id=$id');
    return res['data'][0];
  }

  void dispose(){
    _compreJuntoController.close();
    _enderecosClienteController.close();
    _saldoUsuarioController.close();
    _cartaoCreditoUsuarioController.close();
    _pedidoClienteController.close();
    _empresasFavoritasController.close();
  }

}