import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';
import 'model/empresa_model.dart';

String slogan = 'Ajude a salvar o planeta!';

bool loadingIsShow = false;

const MaterialColor green = const MaterialColor(0xFF5F9A48, const <int, Color>{
  50: const Color(0xFF5F9A48),
  100: const Color(0xFF5F9A48),
  200: const Color(0xFF5F9A48),
  300: const Color(0xFF5F9A48),
  400: const Color(0xFF5F9A48),
  500: const Color(0xFF5F9A48),
  600: const Color(0xFF5F9A48),
  700: const Color(0xFF5F9A48),
  800: const Color(0xFF5F9A48),
  900: const Color(0xFF5F9A48),
});

String maskValor(v) {
  if (v == '' || v == null) return '';

  double valor = v.runtimeType != double ? double.parse(v) : v;
  var maskValor = new MoneyMaskedTextController(leftSymbol: 'R\$ ');
  maskValor.updateValue(valor);

  return maskValor.text;
}

double stringToValue(v){
  v = v.toString().replaceAll('.', '');
  v = v.replaceAll(',', '.');
  return double.tryParse(v);
}

String separa({@required dynamic string, dynamic separator, dynamic add}) {
  separator = separator ?? '';
  add = add ?? '';

  return string.toString().isNotEmpty ? '$separator$string$add' : '';
}

String hoje() {
  DateTime date = DateTime.now();
  return DateFormat('dd/MM/yyyy').format(date);
}

String agora() {
  DateTime date = DateTime.now();
  return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
}

String data(data, {retorno}) {
  if (data == '0000-00-00' || data == '') return retorno ?? '';
  DateTime date = DateTime.parse(data);
  return DateFormat('dd/MM/yyyy').format(date);
}

String dataHora(data) {
  DateTime date = DateTime.parse(data);
  return DateFormat('dd/MM/yyyy HH:mm').format(date);
}

String horario(data) {
  DateTime date = DateTime.parse(data);
  return DateFormat('HH:mm').format(date);
}

String hora(String hora) {
  var split = hora.split(':');
  return '${split[0]}:${split[1]}';
}

void showLoading(context, {String text: 'Carregando...'}) {

  loadingIsShow = true;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 15),
            Text(text, style: TextStyle(color: Colors.white),)
          ],
        ),
      );
    },
  );
}

void hideLoading(context) {
  if(loadingIsShow) {
    loadingIsShow = false;
    Navigator?.pop(context);
  }
}

Future<dynamic> showSimpleDialog({BuildContext context, String titulo, List<Widget> children, bool barrierDismissible}) {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible ?? true,
    builder: (BuildContext context) {
      return GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SimpleDialog(
          title: Stack(
            children: <Widget>[
              Text(titulo),
              Positioned(
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),
                right: -18,
                top: -12,
              )
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          titlePadding: EdgeInsets.symmetric(vertical: 13.0, horizontal: 20.0),
          contentPadding: EdgeInsets.only(top: 0.0, bottom: 20.0, right: 20, left: 20),
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            )
          ],
        ),
      );
    });
}

Future<dynamic> showAlertDialog({
  @required BuildContext context,
  @required dialog,
  bool barrierDismissible: true,
}) {
  return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: dialog,
        );
      });
}

Future<dynamic> showAlertDialog2({
  @required BuildContext context,
  @required dialog,
  bool barrierDismissible: true,
}) {
  return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: dialog,
              ),
            ),
          ),
        );
      });
}

Future<void> alert({BuildContext context, String message, String title}) async {
  await showAlertDialog(
    context: context,
    dialog: AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: Text(message)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('OK'),
        )
      ],
    ));
}

Future<void> confirm({@required BuildContext context, @required String title, @required String message, @required FlatButton confirm, @required FlatButton cancel}) async {
  await showAlertDialog(
    context: context,
    dialog: AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: Text(message)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      actions: <Widget>[
        cancel,
        confirm
      ],
    ));
}

Widget emptyMessage(
    {@required Color color,
    @required IconData icon,
    @required String title,
    String subtitle}) {
  return Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, size: 100, color: color),
        Visibility(
          visible: title == '' ? false : true,
          child: Column(
            children: <Widget>[
              //SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  title,
                  style: TextStyle(fontSize: 34, color: color),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            subtitle ?? '',
            style: TextStyle(fontSize: 20, color: Colors.black26),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}

String somenteNumeros(String string) {
  bool isNumber(String item) {
    return '0123456789'.split('').contains(item);
  }

  List<String> numbers = string.split('').toList();
  numbers.removeWhere((item) => !isNumber(item));

  String n = numbers.join();

  return n;
}

List estadosLista = [
  {"id": "0", "nome": ""},
  {"id": "AC", "nome": "Acre"},
  {"id": "AL", "nome": "Alagoas"},
  {"id": "AM", "nome": "Amazonas"},
  {"id": "AP", "nome": "Amap\u00e1"},
  {"id": "BA", "nome": "Bahia"},
  {"id": "CE", "nome": "Cear\u00e1"},
  {"id": "DF", "nome": "Distrito Federal"},
  {"id": "ES", "nome": "Esp\u00edrito Santo"},
  {"id": "GO", "nome": "Goi\u00e1s"},
  {"id": "MA", "nome": "Maranh\u00e3o"},
  {"id": "MT", "nome": "Mato Grosso"},
  {"id": "MS", "nome": "Mato Grosso do Sul"},
  {"id": "MG", "nome": "Minas Gerais"},
  {"id": "PA", "nome": "Par\u00e1"},
  {"id": "PB", "nome": "Para\u00edba"},
  {"id": "PR", "nome": "Paran\u00e1"},
  {"id": "PE", "nome": "Pernambuco"},
  {"id": "PI", "nome": "Piau\u00ed"},
  {"id": "RJ", "nome": "Rio de Janeiro"},
  {"id": "RN", "nome": "Rio Grande do Norte"},
  {"id": "RS", "nome": "Rio Grande do Sul"},
  {"id": "SC", "nome": "Santa Catarina"},
  {"id": "SP", "nome": "S\u00e3o Paulo"},
  {"id": "SE", "nome": "Sergipe"},
  {"id": "RO", "nome": "Rond\u00f4nia"},
  {"id": "RR", "nome": "Roraima"},
  {"id": "TO", "nome": "Tocantins"}
];

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    try {
      hexColor = hexColor.toUpperCase().replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF" + hexColor;
      }
      return int.parse(hexColor, radix: 16);
    } catch (e) {
      print(e);
      return 0;
    }
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

String getEndereco(EmpresaModel endereco) {
  if(endereco == null) return '';
  return '${endereco.endereco}, ${endereco.endnum}${separa(string: endereco.complemento, separator: ' ')}' +
      '\n${endereco.bairro} - ${endereco.cidade} - ${endereco.uf}';
}

String timeConvert(int num){
  double hours = num / 60;
  double minutes = num.toDouble() % 60;

  int _h = hours.toInt();
  int _m = minutes.toInt();

  String horas = _h.toString();
  String minutos = _m.toString();

  if(_h < 10) horas = '0$_h';
  if(_m < 10) minutos = '0$_m';

  return horas + ':' + minutos;
}

showFlushBarDanger(BuildContext context, String message){
  Flushbar(
    message: message,
    isDismissible: true,
    margin: EdgeInsets.all(8),
    borderRadius: 8,
    backgroundColor: Colors.red,
    icon: Icon(
      Icons.info_outline,
      size: 28.0,
      color: Colors.white,
    ),
    duration: Duration(seconds: 4),
    onTap: (v){
      Navigator.pop(context);
    },
    animationDuration: Duration(milliseconds: 300),
  )..show(context);
}