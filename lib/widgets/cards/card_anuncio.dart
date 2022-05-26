import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saveat/model/anuncio_empresa_model.dart';
import 'package:saveat/model/empresa_model.dart';
import 'package:saveat/util.dart';

class CardAnuncio extends StatelessWidget {
  const CardAnuncio({
    this.anuncio,
    this.empresa,
    this.fotoBase,
  });

  final AnuncioEmpresaModel anuncio;
  final EmpresaModel empresa;
  final String fotoBase;

  void onTapCard(context) {
    //renomear para produto
    Navigator.pushNamed(context, '/oferta', arguments: {
      'item': anuncio,
      'empresa': empresa,
    });
  }

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width * 0.45;

    return Opacity(
      opacity: anuncio.quantidadeRestante == 0 ? 0.7 : 1,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        width: _width,
        child: InkWell(
          onTap: () => onTapCard(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  overflow: Overflow.visible,
                  children: <Widget>[
                    Hero(
                      tag: 'tag-foto-${anuncio.hashCode}',
                      child: CachedNetworkImage(
                        imageUrl: fotoBase != null ? fotoBase + anuncio.foto : anuncio.foto,
                        imageBuilder: (context, imageProvider) => Container(
                          height: 150,
                          decoration: BoxDecoration(
                            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                        placeholder: (context, url) => Container(
                          height: 150,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 1,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                        child: Center(
                          child: Text(
                            '-${anuncio.desconto()}%',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.green,
                      ),
                      child: Center(
                        child: Text(
                          'Salve este produto!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      width: _width,
                      height: 40,
                      bottom: 0,
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black87,
                              blurRadius: 20,
                              spreadRadius: 10,
                              offset: Offset(
                                0,
                                30,
                              ),
                            )
                          ],
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${anuncio.quantidadeRestante} ${anuncio.quantidadeRestante > 1 ? 'restantes' : 'restante'}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 20),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Text(
                          anuncio.nome,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(text: 'de '),
                            TextSpan(
                              text: maskValor(anuncio.valorOriginal),
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                decorationThickness: 2,
                                fontSize: 12,
                              ),
                            ),
                            TextSpan(text: ' por '),
                            TextSpan(
                              text: maskValor(anuncio.valor),
                              style: TextStyle(
                                color: green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
