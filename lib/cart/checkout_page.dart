import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:saveat/blocs/cart_bloc.dart';
import 'package:saveat/cart/widgets/checkout_buytogether.dart';
import 'package:saveat/cart/widgets/checkout_coupon.dart';
import 'package:saveat/cart/widgets/checkout_footer.dart';
import 'package:saveat/cart/widgets/checkout_location.dart';
import 'package:saveat/cart/widgets/checkout_observation.dart';
import 'package:saveat/cart/widgets/checkout_payment.dart';
import 'package:saveat/cart/widgets/checkout_products.dart';
import 'package:saveat/home/widgets/layout-divisor.dart';
import 'package:saveat/model/empresa_model.dart';
import 'package:saveat/provider/acesso_provider.dart';

class CheckoutPage extends StatefulWidget {
  CheckoutPage(this.empresa);

  final EmpresaModel empresa;

  @override
  _CheckoutPageState createState() => _CheckoutPageState(empresa: empresa);
}

class _CheckoutPageState extends State<CheckoutPage> {
  AcessoProvider _acessoProvider;
  CartBloc _cartBloc;
  bool _openLogin = false;
  EmpresaModel empresa;

  _CheckoutPageState({
    this.empresa,
  });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    AcessoProvider acessoProvider = Provider.of<AcessoProvider>(context);
    if (acessoProvider != _acessoProvider) _acessoProvider = acessoProvider;

    CartBloc cartBloc = Provider.of<CartBloc>(context, listen: false);
    if (cartBloc != _cartBloc) {
      _cartBloc = cartBloc;
      _cartBloc.selecionaConsumo(empresa.id, '');
      _cartBloc.processaCupomDesconto(empresa.id, null);
      _cartBloc.selecionaPagamentoTipo(null);
      _cartBloc.selecionaCartao(null);
      _cartBloc.calculaValorTotal(empresa.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      initialData: false,
      stream: _acessoProvider.outUserLogged,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.data && !_openLogin) {
          _acessoProvider.redirect = {
            'page': 'cart',
            'empresaId': empresa.id,
          };

          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });

          _openLogin = true;
          return Container();
        }

        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Meu Pedido'),
            elevation: 0,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    CheckoutProductsWidget(empresa.id, _cartBloc),
                    LayoutDivisor(
                      margin: EdgeInsets.only(
                        bottom: 10,
                      ),
                    ),
                    CheckoutLocation(empresa, _cartBloc),
                    LayoutDivisor(
                      margin: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                    ),
                    CheckoutObservation(_cartBloc),
                    LayoutDivisor(
                      margin: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                    ),
                    CheckoutCoupon(empresa.id, _cartBloc),
                    LayoutDivisor(
                      margin: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                    ),
                    CheckoutPayment(empresa.id, _cartBloc),
                  ],
                ),
              ),
              CheckoutFooter(empresa.id, _cartBloc),
            ],
          ),
        );
      },
    );
  }
}
