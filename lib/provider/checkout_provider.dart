import 'package:flutter/material.dart';
import 'package:saveat/oferta/cart_agradecimento.dart';

import '../api.dart';
import '../util.dart';
import 'global_provider.dart';

class CheckoutProvider extends ChangeNotifier{

  Api api;

  Map checkout = Map();
  List compreJunto = List();

  CheckoutProvider(){
    api = Api();
  }

  void atualizaQuantidade(int acao, double valor){
    if(acao == 1){
      checkout['quantidade']++;
    }else if(acao == 2){
      if(checkout['quantidade'] == 1) return;
      checkout['quantidade']--;
    }

    _atualizaValorCompra();
    notifyListeners();
  }

  Future<Null> getProdutosCompreJunto(String empresa) async {
    Map res = await api.getData('/global/?search=buytogether&empresa=$empresa');
    compreJunto = res['data'];
    notifyListeners();
  }

  void atualizaQuantidadeCompreJunto(int acao, Map item){

    int _index = checkout['compreJunto'].indexWhere((v) => v['id'] == item['id']);

    if(_index == -1){
      item['quantidade'] = 0;
      checkout['compreJunto'].add(item);
      _index = checkout['compreJunto'].indexWhere((v) => v['id'] == item['id']);
    }

    if(acao == 1){
      checkout['compreJunto'][_index]['quantidade']++;
    }else if(acao == 2){
      checkout['compreJunto'][_index]['quantidade']--;

      // remove do array caso não tenha quantidade
      if(checkout['compreJunto'][_index]['quantidade'] == 0){
        checkout['compreJunto'].removeAt(_index);
      }
    }

    checkout['entrega_endereco'] = null;
    checkout['entrega_custo'] = 0;

    _atualizaValorCompra();
    notifyListeners();
  }

  void atualizaEntrega(String tipo){
    checkout['entrega_tipo'] = tipo;

    if(tipo == '2' || tipo == null) {
      checkout['entrega_endereco'] = null;
      checkout['entrega_custo'] = 0;
      _atualizaValorCompra();
    }

    notifyListeners();
  }

  void atualizaEntregaEndereco(Map endereco, double custo){
    checkout['entrega_endereco'] = endereco;
    checkout['entrega_custo'] = custo;

    _atualizaValorCompra();
    notifyListeners();
  }

  void atualizaPagamentoTipo(int tipo){
    checkout['pagamento_tipo'] = tipo;

    if(tipo != 1) {
      checkout['cartao'] = {};
    }

    if(tipo == 3){
      checkout['pagamento_forma'] = 3;
      checkout['pagamento_troco'] = 0;
    }

    notifyListeners();
  }

  void atualizaPagamentoForma(int tipo){
    checkout['pagamento_forma'] = tipo;
    notifyListeners();
  }

  void atualizaCartaoCredito(Map cartao){
    checkout['cartao'] = cartao;
    notifyListeners();
  }

  void atualizaPagamentoSaldoParcial(double saldo){
    checkout['pagamento_saldo'] = saldo;
    notifyListeners();
  }

  void _atualizaValorCompra(){

    List compreJunto = checkout['compreJunto'];
    double total = 0;

    total += checkout['quantidade'] * checkout['valor_produto'];

    compreJunto.forEach((v){
      total += v['quantidade'] * double.tryParse(v['valor']);
    });

    total += checkout['entrega_custo'];

    checkout['valor_compra'] = double.tryParse(total.toStringAsFixed(2));
    checkout['pagamento_tipo'] = 0;
    checkout['pagamento_saldo'] = 0;

    if(checkout['entrega_tipo'] == '1' && checkout['custo_minimo_delivery'] > 0 && (checkout['valor_compra'] - checkout['entrega_custo']) < checkout['custo_minimo_delivery'])
      atualizaEntrega(null);

  }

  Future<Null> enviarPedido(BuildContext context, Map item) async {

    if(checkout['entrega_tipo'] == '' || checkout['entrega_tipo'] == null){
      return await alert(
        context: context,
        title: 'Ops',
        message: 'Por favor selecione o método de Consumo!',
      );
    }

    if(checkout['entrega_tipo'] == '1' && checkout['entrega_endereco'] == null){
      return await alert(
        context: context,
        title: 'Ops',
        message: 'Em qual endereço você quer receber o pedido?',
      );
    }

    if(checkout['pagamento_tipo'] == 0){
      return await alert(
        context: context,
        title: 'Ops',
        message: 'Selecione uma forma de pagamento',
      );
    }

    if((checkout['pagamento_tipo'] == 1 || checkout['pagamento_tipo'] == 4) && (checkout['cartao'] == null || checkout['cartao']['id'] == '' || checkout['cartao']['id'] == null)){
      return await alert(
        context: context,
        title: 'Ops',
        message: 'Gostaria de Salvar este alimento com qual cartão de crédito?',
      );
    }

    // usuario e chave de acesso
    GlobalProvider globalProvider = GlobalProvider(context);
    String _usuario = globalProvider.acessoProvider.usuarioLogado['id'];
    String _chave = globalProvider.acessoProvider.usuarioLogado['chave'] ?? '';
    //

    List _adicionais = List();

    checkout['compreJunto'].forEach((v){
      _adicionais.add({
        'id': v['id'],
        'quantidade': v['quantidade'],
      });
    });

    Map _cartao;

    if(checkout['cartao']['id'] == '0'){
      checkout['cartao']['data']['cvv'] = checkout['cartao']['cvv'];
      _cartao = checkout['cartao']['data'];
    }else if(checkout['cartao']['id'] != null){
      _cartao = {
        'id': checkout['cartao']['id'],
        'cvv': checkout['cartao']['cvv'],
      };
    }

    Map params = {
      'usuario': {
        'id': _usuario,
        'chave': _chave,
      },
      'item': {
        'id': item['id'],
        'empresa': item['empresa']['id'],
        'quantidade': checkout['quantidade'],
      },
      'entrega': {
        'tipo': checkout['entrega_tipo'],
        'valor': checkout['entrega_custo'],
        'endereco_id': checkout['entrega_endereco'] != null ? checkout['entrega_endereco']['id'] : '',
      },
      'pagamento': {
        'tipo': checkout['pagamento_tipo'],
        'forma': checkout['pagamento_forma'],
        'troco': checkout['pagamento_troco'] ?? '0',
        'cartao': _cartao,
        'saldo': checkout['pagamento_saldo'],
      },
      'adicionais': _adicionais,
      'observacoes': checkout['observacoes']
    };

    if(checkout['pagamento_tipo'] == 4){
      print(params);
      //return;
    }

    try {
      showLoading(context, text: 'Processando seu pagamento...');
      Map res = await api.postData('/order/', params);
      hideLoading(context);

      if(res['code'] == '011'){
        await alert(
          context: context,
          title: 'Pedido não realizado',
          message: res['message'],
        );

        showLoading(context);
        await globalProvider.ofertasProvider.get(context);
        hideLoading(context);

        Navigator.pop(context);
        Navigator.pop(context);

        return;
      }

      if(res['code'] != '010'){
        return await alert(
          context: context,
          title: 'Ops',
          message: res['message'],
        );
      }

      globalProvider.ofertasProvider.get(context);
      globalProvider.usuarioProvider.getCreditCards(context);
      globalProvider.acessoProvider.saldoRefresh();

      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CartAgradecimentoPage(res['itens']['pedidoId'].toString())));

    } catch (er){
      await alert(
        context: context,
        title: 'Algo deu errado :(',
        message: 'Tente novamente por favor.',
      );
    }

  }

}