import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saveat/blocs/cart_bloc.dart';
import 'package:saveat/inputs.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/title-widget.dart';

class CheckoutObservation extends StatelessWidget {
  const CheckoutObservation(this.bloc);

  final CartBloc bloc;
  static TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TitleWidget(
            'Alguma observação para o seu pedido?',
            marginLeft: 0,
            marginTop: 0,
            marginBottom: 7,
          ),
          StreamBuilder<String>(
            initialData: '',
            stream: bloc.outObservacaoPedido,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }

              return InkWell(
                onTap: () {
                  _controller = TextEditingController(text: snapshot.data);

                  showAlertDialog(
                    context: context,
                    barrierDismissible: false,
                    dialog: Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            InputField(
                              attribute: 'observacoes',
                              label: 'Observações',
                              autofocus: true,
                              controller: _controller,
                              initialValue: null,
                              maxLines: null,
                              textInputAction: TextInputAction.newline,
                              keyboardType: TextInputType.multiline,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                FlatButton(
                                  child: Text('Fechar'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text('Salvar'),
                                  textColor: Colors.green,
                                  onPressed: () {
                                    bloc.salvarObservacao(_controller.text);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: snapshot.data != ''
                      ? Text(snapshot.data)
                      : Row(
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.pencilAlt,
                              size: 14,
                              color: Colors.green,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Quero adicionar uma observação',
                              style: TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
