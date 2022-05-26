import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saveat/acesso/login.dart';
import 'package:saveat/blocs/api_bloc.dart';
import 'package:saveat/blocs/cart_bloc.dart';
import 'package:saveat/cart/checkout_agradecimento.dart';
import 'package:saveat/cart/checkout_page.dart';
import 'package:saveat/company/company.dart';
import 'package:saveat/company/company_list.dart';
import 'package:saveat/home/home.dart';
import 'package:saveat/oferta/ofertas_todas.dart';
import 'package:saveat/products/product_page.dart';
import 'package:saveat/provider/acesso_provider.dart';
import 'package:saveat/provider/category_provider.dart';
import 'package:saveat/provider/checkout_provider.dart';
import 'package:saveat/provider/company_provider.dart';
import 'package:saveat/provider/offer_provider.dart';
import 'package:saveat/provider/usuario_provider.dart';
import 'package:saveat/usuario/pedidos.dart';
import 'package:saveat/usuario/saldo.dart';
import 'package:saveat/util.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> initPlatformState() async {
    if (!mounted) return;

    await OneSignal.shared.init("ee87faca-a93b-4c34-87d9-03ef19757891");

    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

    //OneSignal.shared.setLogLevel(OSLogLevel.debug, OSLogLevel.verbose);
    OneSignal.shared.setRequiresUserPrivacyConsent(true);

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      //print('notificação recebida: ' + notification.payload.jsonRepresentation());
    });

    OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      print("PERMISSION STATE CHANGED: ${changes.jsonRepresentation()}");
    });
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoriasProvider()),
        ChangeNotifierProvider(create: (_) => OfertasProvider()),
        ChangeNotifierProvider(create: (_) => AcessoProvider()),
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
        ChangeNotifierProvider(create: (_) => CompanyProvider()),
        Provider<CartBloc>(
          create: (_) => CartBloc(),
          dispose: (context, value) => value.dispose(),
        ),
        Provider<ApiBloc>(
          create: (_) => ApiBloc(),
          dispose: (context, value) => value.dispose(),
        )
      ],
      child: MaterialApp(
        title: 'SavEat',
        color: green,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', 'US'),
          const Locale('pt', 'BR'),
        ],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: green,
          primaryColorBrightness: Brightness.dark,
          fontFamily: 'Montserrat',
          hintColor: Colors.white70,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => HomePage(),
//          '/': (context) => CheckoutNewPage(),
          '/oferta': (context) {
            Map data = ModalRoute.of(context).settings.arguments as Map;
            return ProductPage(
              item: data['item'],
              empresa: data['empresa'],
            );
          },
          '/ofertas': (context) {
            Map data = ModalRoute.of(context).settings.arguments as Map;
            return OfertasTodasPage(data['provider']);
          },
          '/empresa': (context) {
            Map data = ModalRoute.of(context).settings.arguments as Map;
            return CompanyPage(data['id']);
          },
          '/empresas': (context) => CompanyListPage(),
          '/carrinho': (context) {
            Map data = ModalRoute.of(context).settings.arguments as Map;
            return CheckoutPage(data['empresa']);
          },
          '/login': (context) => LoginPage(),
          '/agradecimento': (context) {
            Map data = ModalRoute.of(context).settings.arguments as Map;
            return CheckoutAgradecimento(data['pedidoId']);
          },
          '/pedidos': (context) => PedidosPage(),
          '/saldo': (context) => SaldoPage(),
        },
      ),
    );
  }
}
