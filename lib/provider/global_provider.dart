import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:saveat/provider/acesso_provider.dart';
import 'package:saveat/provider/usuario_provider.dart';

import 'location_provider.dart';
import 'offer_provider.dart';

class GlobalProvider {

  BuildContext context;
  AcessoProvider acessoProvider;
  UsuarioProvider usuarioProvider;
  OfertasProvider ofertasProvider;
  GetLocation getLocation;
  Position currentLocation;

  GlobalProvider(BuildContext context){
    init(context);
  }

  void init(BuildContext context) async {
    this.context = context;
    ofertasProvider = Provider.of<OfertasProvider>(context, listen: false);
    acessoProvider = Provider.of<AcessoProvider>(context, listen: false);
    usuarioProvider = Provider.of<UsuarioProvider>(context, listen: false);
    currentLocation = await GetLocation().get();
  }

}