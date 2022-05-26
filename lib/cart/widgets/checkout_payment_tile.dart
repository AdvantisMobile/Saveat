import 'package:flutter/material.dart';

class CheckoutPaymentTile extends StatelessWidget {

  const CheckoutPaymentTile(this.tipo, this.nome, this.onPressed, {this.selected: false});

  final String tipo;
  final String nome;
  final Function onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressed,
      child: Text(nome),
      color: selected ? Colors.green : Colors.grey[300],
      textColor: selected ? Colors.white : Colors.black,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }
}
