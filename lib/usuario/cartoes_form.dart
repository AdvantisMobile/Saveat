import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/cartao_widget.dart';

class CartoesFormPage extends StatefulWidget {
  @override
  _CartoesFormPageState createState() => _CartoesFormPageState();
}

class _CartoesFormPageState extends State<CartoesFormPage> {

  var _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: FormBuilder(
        key: _fbKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Dados do cartão', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black)),
            SizedBox(height: 15),
            CartaoWidget(),
            FormBuilderCheckbox(
              attribute: 'salvar',
              initialValue: false,
              leadingInput: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(0),
                border: InputBorder.none,
              ),
              label: Text('Quero manter os dados deste cartão para os próximos salvamentos.'),
            ),
            Divider(height: 20),
            Center(
              child: Column(
                children: <Widget>[
                  RaisedButton(
                    onPressed: () async {

                      var form = _fbKey.currentState;

                      if(form.validate()){
                        form.save();

                        String _cartaoFinal = form.value['numero'].toString().substring(15);

                        Map _cartao = {
                          'id': '0',
                          'mask': form.value['numero'],
                          'brand': '',
                          'vencimento': form.value['vencimento'],
                          'final': _cartaoFinal,
                          'cvv': form.value['cvv'],
                          'temp': true,
                          'data': form.value,
                        };

                        Navigator.pop(context, _cartao);

                      }

                    },
                    child: Text('PROCESSAR DADOS'),
                    color: green,
                    textColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                    ),
                  ),
                  FlatButton(
                    child: Text('Fechar'),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}
