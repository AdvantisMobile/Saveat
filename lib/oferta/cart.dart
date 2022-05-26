import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:saveat/inputs.dart';
import 'package:saveat/provider/checkout_provider.dart';
import 'package:saveat/provider/usuario_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:saveat/widgets/endereco_form.dart';
import '../util.dart';
import 'cart_compre_junto.dart';
import 'cart_entrega.dart';
import 'cart_observacoes.dart';
import 'cart_payment.dart';
import 'cart_quantidade_compra.dart';

class CartPage extends StatefulWidget {

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  Map item;
  CheckoutProvider provider;
  ScrollController _scrollController;
  bool _loaded = false;
  bool _usuarioLiberado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    item = Map();

    if(!_loaded){
      provider = Provider.of<CheckoutProvider>(context, listen: false);
      provider.checkout = {
        'quantidade': 1,
        'valor_produto': double.tryParse(item['valor']),
        'valor_compra': double.tryParse(item['valor']),
        'custo_minimo_delivery': double.tryParse(item['empresa']['delivery']['custo_minimo']),
        'compreJunto': [],
        'entrega_tipo': '',
        'entrega_endereco': null,
        'entrega_custo': 0,
        'pagamento_tipo': 0,
        'pagamento_saldo': 0.0,
        'cartao_id': '',
        'cartao_cvv': '',
        'cartao': null,
        'observacoes': '',
      };

      provider.compreJunto = List();

      Provider.of<UsuarioProvider>(context, listen: false).usuarioEnderecos = List();
      _loaded = true;
    }

  }

  @override
  Widget build(BuildContext context) {

    _scrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        elevation: 2,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              controller: _scrollController,
              children: <Widget>[
                Card(
                  margin: EdgeInsets.all(4),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: CachedNetworkImageProvider(item['foto']),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    item['item'],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(
                                    '${item['quantidade_restante']} restantes'
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        CartQuantidadeCompra(item),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.all(4),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'VÁLIDO PARA',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${data(item['disp_data'])} das ${hora(item['disp_hora_ini'])} às ${hora(item['disp_hora_fim'])}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.all(4),
                  child: CartCompreJunto(item),
                ),
                Card(
                  margin: EdgeInsets.all(4),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: CartEntrega(item, _scrollController),
                  ),
                ),
                Card(
                  margin: EdgeInsets.all(4),
                  child: CartObservacoes(),
                ),
                Card(
                  margin: EdgeInsets.all(4),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: CartPayment(item, _scrollController),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: green,
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 5
                )
              ]
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Total do pedido'),
                        SizedBox(height: 5,),
                        Consumer<CheckoutProvider>(
                          builder: (context, snapshot, _){
                            return Text(
                              maskValor(snapshot.checkout['valor_compra'].toString()),
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 50,
                      child: RaisedButton(
                        onPressed: () {
                          _processarPagamento(context, item);
                        },
                        color: Colors.white,
                        child: Text('SALVAR AGORA'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _processarPagamento(BuildContext context, Map item) async {

    if(!_usuarioLiberado){
      Map pendencias = await UsuarioProvider().getPendencias(context);

      if(!pendencias['liberado']){
        return _regularizarPendencias(context, pendencias, item);
      }

      _usuarioLiberado = true;
    }

    await Provider.of<CheckoutProvider>(context, listen: false).enviarPedido(context, item);
  }

  void _regularizarPendencias(BuildContext context, Map pendencias, Map item) async {

    var _fbKey;
    double width = MediaQuery.of(context).size.width;

    if(pendencias['endereco'] == false) {

      _fbKey = GlobalKey<FormBuilderState>();

      showSimpleDialog(
          context: context,
          titulo: 'Qual o seu endereço?',
          barrierDismissible: false,
          children: [
            Container(
              width: width,
              child: FormBuilder(
                key: _fbKey,
                child: Column(
                  children: <Widget>[
                    EnderecoWidget(botaoPreenchimento: 'Preencher'),
                    Container(
                      width: width,
                      height: 40,
                      child: RaisedButton(
                        onPressed: () async {
                          bool res = await UsuarioProvider().cadastrarNovoEndereco(context, _fbKey);

                          if (res) {
                            Navigator.pop(context);
                            _processarPagamento(context, item);
                          }
                        },
                        color: green,
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)
                        ),
                        child: Text('SALVAR DADOS'),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      width: width,
                      child: FlatButton(
                        child: Text('Cancelar'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ]
      );

      return;

    }

    if(pendencias['cpf_telefone'] == false) {

      _fbKey = GlobalKey<FormBuilderState>();

      showSimpleDialog(
          context: context,
          barrierDismissible: false,
          titulo: 'Atualize seus dados',
          children: [
            Container(
              width: width,
              child: FormBuilder(
                key: _fbKey,
                child: Column(
                  children: <Widget>[
                    InputField(
                      attribute: 'nome',
                      label: 'Nome completo',
                      required: true,
                      showAsterisk: false,
                      initialValue: pendencias['dados']['nome'],
                    ),
                    InputCPF(
                      attribute: 'cpf',
                      label: 'CPF',
                      required: true,
                      showAsterisk: false,
                      initialValue: pendencias['dados']['cpf'],
                    ),
                    InputTelefone(
                      attribute: 'telefone',
                      label: 'Telefone',
                      required: true,
                      showAsterisk: false,
                      initialValue: pendencias['dados']['telefone'],
                    ),
                    Container(
                      width: width,
                      height: 40,
                      child: RaisedButton(
                        onPressed: () async {
                          bool res = await UsuarioProvider()
                              .atualizaCPFTelefone(context, _fbKey);

                          if (res) {
                            Navigator.pop(context);
                            _usuarioLiberado = true;
                            _processarPagamento(context, item);
                          }
                        },
                        color: green,
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)
                        ),
                        child: Text('SALVAR DADOS'),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      width: width,
                      child: FlatButton(
                        child: Text('Cancelar'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ]
      );

    }

  }
}
