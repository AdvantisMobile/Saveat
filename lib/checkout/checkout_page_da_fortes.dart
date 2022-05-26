//import 'package:flutter/gestures.dart';
//import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//import 'package:saveat/blocs/cart_bloc.dart';
//import 'package:saveat/model/produto_model.dart';
//import 'package:saveat/provider/acesso_provider.dart';
////TODO ver se essa tela vai mesmo ser utilizada ou se posso matar
//class CheckoutNewPage extends StatefulWidget {
//  CheckoutNewPage(this.empresaId);
//
//  final String empresaId;
//
//  @override
//  _CheckoutNewPageState createState() => _CheckoutNewPageState();
//}
//
//class _CheckoutNewPageState extends State<CheckoutNewPage> {
//  //--------------apagar-------------
//
//  int tam = 0;
//
//  int flavor = 0;
//  double total = 0.0;
//  List<int> qnt = [1, 1, 1, 1, 1, 1, 1];
//
//  List<String> flavors = ["Frango com catupiry", "Calabresa", "Mineira", "Quatro Queijos"];
//  List<String> flavorsSelected = [];
//
//  @override
//  void initState() {
//    super.initState();
//  }
//
//  AcessoProvider _acessoProvider;
//  CartBloc _cartBloc;
//
//  @override
//  void didChangeDependencies() {
//    super.didChangeDependencies();
//
//    AcessoProvider acessoProvider = Provider.of<AcessoProvider>(context);
//    if (acessoProvider != _acessoProvider) _acessoProvider = acessoProvider;
//
//    CartBloc cartBloc = Provider.of<CartBloc>(context, listen: false);
//    if (cartBloc != _cartBloc) {
//      _cartBloc = cartBloc;
//      _cartBloc.selecionaConsumo(widget.empresaId, '');
//      _cartBloc.processaCupomDesconto(widget.empresaId, null);
//      _cartBloc.selecionaPagamentoTipo(null);
//      _cartBloc.selecionaCartao(null);
//      _cartBloc.calculaValorTotal(widget.empresaId);
//    }
//  }
//
//  var _key = GlobalKey<ScaffoldState>();
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      key: _key,
//      backgroundColor: Colors.grey[200], //TODO tava white70
//      appBar: AppBar(
//        title: Text("Detalhes"),
//      ),
//      body: Stack(
//        children: [
//          Container(
//            child: ListView(
//              padding: EdgeInsets.only(
//                bottom: 100,
//              ),
//              shrinkWrap: true,
//              primary: false,
//              children: [
//                productUnity(id: 0),
//                productUnity(id: 1),
//                delivery(),
//                obs(),
//                cupom(),
//                payment(),
//              ],
//            ),
//          ),
//          footer()
//        ],
//      ),
//    );
//  }
//
//  Widget productUnity({id, ProdutoModel product}) {
//    return Card(
//      child: Container(
//        height: 120,
//        child: Row(
//          mainAxisAlignment: MainAxisAlignment.start,
//          crossAxisAlignment: CrossAxisAlignment.center,
//          children: [
//            Expanded(
//              flex: 2,
//              child: Padding(
//                padding: EdgeInsets.all(10),
//                child: CircleAvatar(radius: 40.0, backgroundImage: NetworkImage(product.foto)),
//              ),
//            ),
//            Expanded(
//              flex: 4,
//              child: Column(
//                mainAxisAlignment: MainAxisAlignment.spaceAround,
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: [
//                  SizedBox(
//                    height: 30,
//                  ),
//                  Expanded(
//                    flex: 1,
//                    child: Text(
//                      product.nome,
//                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                    ),
//                  ),
//                  Expanded(
//                    flex: 1,
//                    child: Text(product.descricao),
//                  ),
//                  Expanded(
//                    flex: 1,
//                    child: RichText(
//                      text: TextSpan(
//                        recognizer: TapGestureRecognizer()..onTap = () => print('Tap Here onTap'),
//                        children: <TextSpan>[
//                          TextSpan(
//                            text: 'R\$45,00',
//                            style: TextStyle(
//                              color: Colors.grey,
//                              decoration: TextDecoration.lineThrough,
//                              fontSize: 16,
//                            ),
//                          ),
//                          TextSpan(
//                            text: '  R\$40,00',
//                            style: TextStyle(
//                              color: Colors.black,
//                              fontSize: 16,
//                            ),
//                          )
//                        ],
//                      ),
//                    ),
//                  ),
//                ],
//              ),
//            ),
//            Expanded(
//              flex: 2,
//              child: Padding(
//                padding: const EdgeInsets.all(8.0),
//                child: Column(
//                  crossAxisAlignment: CrossAxisAlignment.end,
//                  children: [
//                    Expanded(
//                      flex: 1,
//                      child: Container(),
//                    ),
//                    Expanded(
//                      flex: 1,
//                      child: Icon(
//                        Icons.delete,
//                        color: Colors.red,
//                      ),
//                    ),
//                    Expanded(
//                      flex: 3,
//                      child: Row(
//                        children: [
//                          Expanded(
//                              flex: 1,
//                              child: GestureDetector(
//                                onTap: () {
//                                  ajustQnt(index: id, val: -1);
//                                },
//                                child: Text(
//                                  "-",
//                                  textAlign: TextAlign.center,
//                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
//                                ),
//                              )),
//                          Expanded(
//                            flex: 1,
//                            child: Text(
//                              "${qnt[id]}",
//                              textAlign: TextAlign.center,
//                              style: TextStyle(fontWeight: FontWeight.bold),
//                            ),
//                          ),
//                          Expanded(
//                            flex: 1,
//                            child: GestureDetector(
//                              onTap: () {
//                                ajustQnt(index: id, val: 1);
//                              },
//                              child: Text(
//                                "+",
//                                textAlign: TextAlign.center,
//                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
//                              ),
//                            ),
//                          ),
//                        ],
//                      ),
//                    )
//                  ],
//                ),
//              ),
//            )
//          ],
//        ),
//      ),
//    );
//  }
//
//  ajustQnt({index, val}) {
//    var aux = qnt[index] + val;
//    if (aux <= 0) {
//      aux = 0;
//    }
//    setState(() {
//      qnt[index] = aux;
//    });
//  }
//
//  Widget delivery() {
//    return Container(
//      height: 100,
//      child: Card(
//        color: Colors.white,
//        child: Padding(
//          padding: const EdgeInsets.all(8.0),
//          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: [
//              Expanded(
//                flex: 1,
//                child: Text(
//                  "Como vai ser o consumo dessa delícia?",
//                  textAlign: TextAlign.left,
//                  style: TextStyle(
//                    fontWeight: FontWeight.bold,
//                    fontSize: 16,
//                  ),
//                ),
//              ),
//              Expanded(
//                flex: 2,
//                child: Row(
//                  children: [
//                    Container(
//                      width: 80,
//                      height: 45,
//                      child: RaisedButton(
//                        onPressed: () {},
//                        child: Text(
//                          'Delivery',
//                          style: TextStyle(
//                            color: Colors.white,
//                            fontSize: 14,
//                          ),
//                        ),
//                        color: Theme.of(context).accentColor,
//                        padding: EdgeInsets.symmetric(horizontal: 10),
//                        shape: RoundedRectangleBorder(
//                          borderRadius: BorderRadius.circular(30),
//                        ),
//                      ),
//                    ),
//                    SizedBox(
//                      width: 10,
//                    ),
//                    Container(
//                      width: 80,
//                      height: 45,
//                      child: RaisedButton(
//                        onPressed: () {},
//                        child: Text(
//                          'Retirada',
//                          style: TextStyle(
//                            color: Colors.black,
//                            fontSize: 12,
//                          ),
//                        ),
//                        color: Colors.white60,
//                        padding: EdgeInsets.symmetric(horizontal: 10),
//                        shape: RoundedRectangleBorder(
//                          borderRadius: BorderRadius.circular(30),
//                        ),
//                      ),
//                    )
//                  ],
//                ),
//              ),
//            ],
//          ),
//        ),
//      ),
//    );
//  }
//
//  Widget obs() {
//    return Container(
//      height: 80,
//      child: Card(
//        color: Colors.white,
//        child: Padding(
//          padding: const EdgeInsets.all(8.0),
//          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: [
//              Expanded(
//                flex: 1,
//                child: Text(
//                  "Alguma observação para seu pedido?",
//                  textAlign: TextAlign.left,
//                  style: TextStyle(
//                    fontWeight: FontWeight.bold,
//                    fontSize: 16,
//                  ),
//                ),
//              ),
//              Expanded(
//                flex: 1,
//                child: Row(
//                  children: [
//                    Icon(
//                      Icons.edit,
//                      color: Theme.of(context).accentColor,
//                    ),
//                    Text(
//                      "quero adicionar uma observação",
//                      textAlign: TextAlign.left,
//                      style: TextStyle(
//                        fontSize: 14,
//                        color: Theme.of(context).accentColor,
//                      ),
//                    ),
//                  ],
//                ),
//              ),
//            ],
//          ),
//        ),
//      ),
//    );
//  }
//
//  Widget cupom() {
//    return Container(
//      height: 80,
//      child: Card(
//        color: Colors.white,
//        child: Padding(
//          padding: const EdgeInsets.all(8.0),
//          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: [
//              Expanded(
//                flex: 1,
//                child: Text(
//                  "Tem um cupom de desconto aí?",
//                  textAlign: TextAlign.left,
//                  style: TextStyle(
//                    fontWeight: FontWeight.bold,
//                    fontSize: 16,
//                  ),
//                ),
//              ),
//              Expanded(
//                flex: 1,
//                child: Row(
//                  children: [
//                    Icon(
//                      Icons.local_offer,
//                      color: Theme.of(context).accentColor,
//                    ),
//                    Text(
//                      "Tenho e vou informar agora",
//                      textAlign: TextAlign.left,
//                      style: TextStyle(
//                        fontSize: 14,
//                        color: Theme.of(context).accentColor,
//                      ),
//                    ),
//                  ],
//                ),
//              ),
//            ],
//          ),
//        ),
//      ),
//    );
//  }
//
//  Widget payment() {
//    return Container(
//      height: 80,
//      child: Card(
//        color: Colors.white,
//        child: Padding(
//          padding: const EdgeInsets.all(8.0),
//          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: [
//              Expanded(
//                flex: 1,
//                child: Text(
//                  "Pagamento?",
//                  textAlign: TextAlign.left,
//                  style: TextStyle(
//                    fontWeight: FontWeight.bold,
//                    fontSize: 16,
//                  ),
//                ),
//              ),
//            ],
//          ),
//        ),
//      ),
//    );
//  }
//
//  Widget footer() {
//    return Align(
//      alignment: Alignment.bottomCenter,
//      child: Container(
//        padding: EdgeInsets.only(
//          left: 20,
//          right: 20,
//        ),
//        height: 80,
//        color: Theme.of(context).accentColor,
//        child: Row(
//          children: [
//            Expanded(
//                flex: 1,
//                child: Padding(
//                  padding: const EdgeInsets.all(8.0),
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: [
//                      Text(
//                        "Total do pedido",
//                        style: TextStyle(
//                          color: Colors.black,
//                          fontSize: 14,
//                        ),
//                      ),
//                      Text(
//                        "R\$ ${total}",
//                        style: TextStyle(
//                          color: Colors.white,
//                          fontSize: 22,
//                          fontWeight: FontWeight.bold,
//                        ),
//                      ),
//                    ],
//                  ),
//                )),
//            Expanded(
//              flex: 1,
//              child: RaisedButton(
//                onPressed: () {},
//                child: Text(
//                  'Pedir',
//                  style: TextStyle(
//                    color: Theme.of(context).accentColor,
//                    fontSize: 18,
//                  ),
//                ),
//                color: Colors.white,
//                padding: EdgeInsets.symmetric(
//                  horizontal: 40,
//                ),
//                shape: RoundedRectangleBorder(
//                  borderRadius: BorderRadius.circular(30),
//                ),
//              ),
//            )
//          ],
//        ),
//      ),
//    );
//  }
//}
