import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saveat/model/categoria_model.dart';
import 'package:saveat/provider/category_provider.dart';
import 'package:saveat/provider/offer_provider.dart';

class CardCategoria extends StatelessWidget {

  final CategoriaModel item;
  final double height;
  CardCategoria(this.item, this.height);

  @override
  Widget build(BuildContext context) {

    CategoriasProvider provider = Provider.of<CategoriasProvider>(context);

    return Container(
        alignment: Alignment.center,
        width: height * 2,
        height: height,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(item.imagem),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: InkWell(
          onTap: (){

            OfertasProvider _offer = Provider.of<OfertasProvider>(context, listen: false);
            _offer.categoria = item.id;
            _offer.clearOfertasHome();
            _offer.getHome(context);

            provider.selecionaCategoria(item.id);
          },
          child: Stack(
              children: <Widget>[
                AnimatedContainer(
                  height: 80,
                  duration: Duration(milliseconds: 100),
                  decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                          width: provider.categoriaSelecionada == item.id ? 5 : 0,
                          color: Color(0xFF5F9A48)
                      )
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    item.categoria,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                            blurRadius: 10,
                          )
                        ]
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              alignment: Alignment.center
          ),
        )
    );
  }
}