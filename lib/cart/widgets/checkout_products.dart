import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:saveat/blocs/cart_bloc.dart';
import 'package:saveat/cart/widgets/checkout_products_tile.dart';
import 'package:saveat/model/carrinho/carrinho_model.dart';

class CheckoutProductsWidget extends StatefulWidget {
  CheckoutProductsWidget(this.empresaId, this.bloc);

  final String empresaId;
  final CartBloc bloc;

  @override
  _CheckoutProductsWidgetState createState() => _CheckoutProductsWidgetState();
}

class _CheckoutProductsWidgetState extends State<CheckoutProductsWidget> with AutomaticKeepAliveClientMixin {
  String empresaId;
  CartBloc bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    empresaId = widget.empresaId;
    bloc = widget.bloc;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder(
      stream: bloc.outCarrinho,
      builder: (context, snapshot) {
        CarrinhoModel carrinhoEmpresa = bloc.getCarrinhoDaEmpresa(empresaId);

        if (!snapshot.hasData || carrinhoEmpresa == null) {
          return Container();
        }

        if (!carrinhoEmpresa.hasitens() && Navigator.canPop(context)) {
          SchedulerBinding.instance.addPostFrameCallback((_) => Navigator.pop(context));
        }

        List<Widget> listItens = List();

        if(carrinhoEmpresa.anuncio != null){
          listItens.addAll(carrinhoEmpresa.anuncio.map((item) {
            return CheckoutProductsTile(item, bloc, empresaId);
          }).toList());
        }

        if(carrinhoEmpresa.produto != null){
          listItens.addAll(carrinhoEmpresa.produto.map((item) {
            return CheckoutProductsTile(item, bloc, empresaId);
          }).toList());
        }

        return Column(
          children: listItens,
        );
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
