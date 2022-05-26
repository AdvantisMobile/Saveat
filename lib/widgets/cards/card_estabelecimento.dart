import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saveat/provider/location_provider.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/estabelecimento-star.dart';
import 'package:saveat/widgets/layout-divisor-ball.dart';

class CardEstabelecimento extends StatefulWidget {
  CardEstabelecimento({
    this.empresa,
    this.fotoBase = '',
  });

  final Map empresa;
  final String fotoBase;

  @override
  _CardEstabelecimentoState createState() => _CardEstabelecimentoState();
}

class _CardEstabelecimentoState extends State<CardEstabelecimento> {
  Map item;
  GetLocation location;

  @override
  void didChangeDependencies() {
    item = widget.empresa;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 10,
      ),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            color: Colors.black26,
          )
        ],
      ),
      child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/empresa',
                arguments: {
                  'id': item['id'],
                },
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: widget.fotoBase + item['logo'],
                  height: 50,
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    backgroundImage: imageProvider,
                    radius: 40,
                  ),
                  placeholder: (context, url) => Container(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              item['empresa'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              item['avaliacao'] != null && item['avaliacao'] != '' ? EstabelecimentoStar(item['avaliacao']) : Container(),
                              item['avaliacao'] != null && item['avaliacao'] != '' && item['avaliacao'] != "0" ? LayoutDivisorBall() : Container(),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Container(
                  width: 45,
                  height: 45,
                  margin: EdgeInsets.only(top: 20),
                  child: FlatButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/empresa',
                        arguments: {
                          'id': item['id'],
                        },
                      );
                    },
                    color: item['aberto'] == "0" ? Colors.grey[700] : green,
                    child: Center(
                      child: Icon(
                        FontAwesomeIcons.chevronRight,
                        color: Colors.white,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                )
              ],
            ),
          ),
          item['empresa_nova'] != "1"
              ? Container()
              : Positioned(
                  top: 0,
                  right: 0,
                  child: Text(
                    'Novo!',
                    style: TextStyle(
                      color: Color(0xfff8a81d),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          item['aberto'] == "1"
              ? Container()
              : Positioned(
                  left: -10,
                  top: -10,
                  width: MediaQuery.of(context).size.width - 20,
                  height: 85,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/empresa',
                        arguments: {
                          'id': item['id'],
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          'Fechado',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
