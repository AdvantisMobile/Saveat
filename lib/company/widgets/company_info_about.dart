import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saveat/model/empresa_model.dart';
import 'package:saveat/util.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyInfoAbout extends StatelessWidget {
  const CompanyInfoAbout(this.empresa);

  final EmpresaModel empresa;

  void onTapVerRota() async {
    String url = 'https://www.google.com/maps/search/?api=1&query=${empresa.latlng}';
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                empresa.empresa,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                getEndereco(empresa),
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 5),
              Text(empresa.telefone),
            ],
          ),
        ),
        SizedBox(width: 10),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: green,
          ),
          child: InkWell(
            onTap: onTapVerRota,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  FontAwesomeIcons.map,
                  size: 25,
                  color: Colors.white,
                ),
                SizedBox(height: 5),
                Text(
                  'ver rota',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          ),
        ),
        SizedBox(width: 10),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: green,
          ),
          child: InkWell(
            onTap: () async {
              String url = 'tel:${somenteNumeros(empresa.telefone)}';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Transform.rotate(
                  child: Icon(FontAwesomeIcons.phone, size: 25, color: Colors.white),
                  angle: 360,
                ),
                SizedBox(height: 5),
                Text(
                  'ligar',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
