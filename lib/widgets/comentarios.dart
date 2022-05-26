import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:saveat/util.dart';

class ComentariosWidget extends StatelessWidget {

  final Map item;
  ComentariosWidget(this.item);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            backgroundImage: item['foto'] == '' ? null : CachedNetworkImageProvider(item['foto']),
            child: item['foto'] != '' ? null : Text(item['nome'].split('')[0]),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(Icons.star, color: Colors.yellow[800], size: 20,),
                        SizedBox(width: 5),
                        Text(double.tryParse(item['nota']).toString()),
                      ],
                    ),
                    Text(
                      data(item['data']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey
                      ),
                    )
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  item['nome'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey
                  ),
                ),
                item['comentario'] == '' ? Container() : Column(
                  children: <Widget>[
                    SizedBox(height: 5),
                    Text(
                      item['comentario'],
                      style: TextStyle(
                        color: Colors.black87
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
