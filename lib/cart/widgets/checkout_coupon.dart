import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saveat/blocs/api_bloc.dart';
import 'package:saveat/blocs/cart_bloc.dart';
import 'package:saveat/inputs.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/title-widget.dart';

class CheckoutCoupon extends StatefulWidget {

  const CheckoutCoupon(this.empresaId, this.bloc);

  final String empresaId;
  final CartBloc bloc;

  @override
  _CheckoutCouponState createState() => _CheckoutCouponState();
}

class _CheckoutCouponState extends State<CheckoutCoupon> {

  ApiBloc _apiBloc;
  static TextEditingController _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    ApiBloc apiBloc = Provider.of<ApiBloc>(context);
    if(apiBloc != _apiBloc) {
      _apiBloc = apiBloc;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TitleWidget('Tem um cupom de desconto aí?', marginLeft: 0, marginTop: 0, marginBottom: 7,),
          StreamBuilder<Map>(
            stream: widget.bloc.outCupomDesconto,
            builder: (context, snapshot) {

              String _tipoCupom = '';

              if(snapshot.data != null){
                if(snapshot.data['tipo'] == '1'){
                  _tipoCupom = '${snapshot.data['valor']}% de desconto em produtos';
                }else if(snapshot.data['tipo'] == '2'){
                  _tipoCupom = '${maskValor(snapshot.data['valor'])} de desconto em produtos';
                }else if(snapshot.data['tipo'] == '3'){
                  _tipoCupom = '${snapshot.data['valor']}% de desconto na entrega';
                }
                print(_tipoCupom);
              }

              return Padding(
                padding: const EdgeInsets.all(5),
                child: snapshot.data != null && snapshot.data['codigo'] != '' ? Column(
                    children: <Widget>[
                      Text('Cupom ativo'),
                      SizedBox(height: 5,),
                      Text(
                        snapshot.data['codigo'],
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.green
                        ),
                      ),
                      SizedBox(height: 5,),
                      Text(_tipoCupom),
                    ],
                  ) : InkWell(
                  onTap: (){

                    _controller = TextEditingController();

                    showAlertDialog(
                      context: context,
                      barrierDismissible: false,
                      dialog: Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              InputField(
                                attribute: 'cupom_desconto',
                                label: 'Qual é o seu Cupom de Desconto?',
                                autofocus: true,
                                controller: _controller,
                                initialValue: null,
                                maxLines: 1,
                                textInputAction: TextInputAction.done,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  FlatButton(
                                    child: Text('Fechar'),
                                    onPressed: (){
                                      Navigator.pop(context);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('Aplicar'),
                                    textColor: Colors.green,
                                    onPressed: () async {
                                      if(_controller.text == '') return;

                                      showLoading(context);
                                      Map res = await _apiBloc.getCupomDesconto(_controller.text, widget.bloc.valorTotalProdutos);
                                      hideLoading(context);

                                      if(res['code'] == '010'){
                                        widget.bloc.processaCupomDesconto(widget.empresaId, res['data']);
                                        Navigator.pop(context);
                                      }else{
                                        await alert(
                                          context: context,
                                          title: 'Ops',
                                          message: res['message'],
                                        );
                                      }
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ));

                  },
                  child: Row(
                    children: <Widget>[
                      Icon(FontAwesomeIcons.tag, size: 14, color: Colors.green,),
                      SizedBox(width: 10,),
                      Text(
                        'Tenho e vou informar agora',
                        style: TextStyle(
                          color: Colors.green
                        ),
                      ),
                    ],
                  ),
                ),
              );

            }
          ),
        ],
      ),
    );
  }
}
