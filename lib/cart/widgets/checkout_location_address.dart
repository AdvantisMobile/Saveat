import 'package:flutter/material.dart';
import 'package:saveat/blocs/cart_bloc.dart';
import 'package:saveat/util.dart';

class CheckoutLocationAddress extends StatelessWidget {

  const CheckoutLocationAddress(this.empresaId, this.item, this.bloc, {this.selected: false, this.disponivel: true, this.custo});

  final String empresaId;
  final Map item;
  final CartBloc bloc;
  final bool selected;
  final bool disponivel;
  final double custo;

  static String _custo;

  @override
  Widget build(BuildContext context) {

    _custo = custo == null ? (item['custo_temp'] != null ? item['custo_temp'].toString() : item['custo'].toString()) : custo.toString();

    return InkWell(
      onTap: !disponivel ? null : (){
        bloc.selecionaEndereco(item, empresaId, custo: custo);
      },
      child: Row(
        children: <Widget>[
          Container(
            width: 26,
            height: 26,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(
                color: disponivel ? Colors.grey : Colors.grey[400]
              )
            ),
            child: selected ? Container(
              color: Colors.green,
            ) : Container(),
          ),
          SizedBox(width: 15,),
          Expanded(
            child: Text(
//              getEndereco(item), TODO comentei isso pq o getEndereco agora espera um objeto de empresa, tenho que ver oq vou fazer com isso pra voltar a funfar
              '',
              style: TextStyle(
                fontSize: 12,
                color: disponivel ? Colors.black : Colors.grey
              ),
            ),
          ),
          SizedBox(width: 15,),
          Text(
            !disponivel ? 'Indisponível' : maskValor(_custo.toString()),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: disponivel ? 14 : 10,
              color: disponivel ? Colors.black : Colors.red,
            ),
          )
        ],
      ),
    );
  }
}
