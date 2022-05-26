import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EstabelecimentoStar extends StatelessWidget {

  EstabelecimentoStar(this.numero);

  final String numero;

  @override
  Widget build(BuildContext context) {
    return numero == '0' ? Container() : Row(
      children: <Widget>[
        Icon(FontAwesomeIcons.solidStar, color: Color(0xfff8a81d), size: 12,),
        SizedBox(width: 5,),
        Text(
          double.tryParse(numero).toString(),
          style: TextStyle(
            color: Color(0xfff8a81d),
          ),
        )
      ],
    );
  }
}
