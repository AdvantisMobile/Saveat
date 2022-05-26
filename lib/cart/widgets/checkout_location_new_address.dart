import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:saveat/blocs/api_bloc.dart';
import 'package:saveat/blocs/cart_bloc.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/endereco_form.dart';

class CheckoutLocationNewAddress extends StatefulWidget {

  const CheckoutLocationNewAddress(this.empresaId, this.bloc, this.apiBloc);

  final String empresaId;
  final CartBloc bloc;
  final ApiBloc apiBloc;

  @override
  _CheckoutLocationNewAddressState createState() => _CheckoutLocationNewAddressState();
}

class _CheckoutLocationNewAddressState extends State<CheckoutLocationNewAddress> {

  var _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo endereço'),
        elevation: 2,
      ),
      body: GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: FormBuilder(
            key: _fbKey,
            child: ListView(
              padding: EdgeInsets.all(16),
              children: <Widget>[
                EnderecoWidget(),
                Container(
                  height: 40,
                  child: RaisedButton(
                    child: Text('SALVAR ENDEREÇO'),
                    onPressed: () async {

                      var form = _fbKey.currentState;

                      FocusScope.of(context).requestFocus(new FocusNode());

                      if(form.validate()) {
                        form.save();

                        Map params = form.value;

                        showLoading(context);
                        Map res = await widget.apiBloc.postClientAddress(widget.empresaId, params);
                        hideLoading(context);

                        if(res['code'] == '010'){
                          Navigator.pop(context);
                        }else{
                          await alert(
                            context: context,
                            title: 'Ops',
                            message: res['message'],
                          );
                        }
                      }
                    },
                    color: green,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                    ),
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}
