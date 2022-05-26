import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saveat/inputs.dart';
import 'package:saveat/provider/usuario_provider.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/endereco_form.dart';
import 'package:url_launcher/url_launcher.dart';

class SaldoRecargasWidget extends StatefulWidget {
  @override
  _SaldoRecargasWidgetState createState() => _SaldoRecargasWidgetState();
}

class _SaldoRecargasWidgetState extends State<SaldoRecargasWidget> with AutomaticKeepAliveClientMixin {

  MoneyMaskedTextController _controllerValue;
  bool _loaded = false;
  UsuarioProvider usuarioProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    usuarioProvider = Provider.of<UsuarioProvider>(context);

    if(!_loaded){
      _loaded = !_loaded;
      usuarioProvider.getBoletosSaldo(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: (){
        return usuarioProvider.getBoletosSaldo(context);
      },
      child: ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          FlatButton.icon(
            icon: Icon(FontAwesomeIcons.barcode),
            color: Colors.green,
            textColor: Colors.white,
            label: Text('Efetuar recarga com Boleto Bancário'),
            onPressed: (){
              _recarregar(context, _controllerValue);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)
            ),
          ),
          SizedBox(height: 20),
          Consumer<UsuarioProvider>(
            builder: (context, snapshot, _){

              if(snapshot.isLoading){
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if(snapshot.usuarioBoletos.length == 0){
                return emptyMessage(color: Colors.grey, icon: FontAwesomeIcons.wallet, title: 'nenhuma recarga efetuada');
              }

              return Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Vencimento',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Valor',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Boleto',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: snapshot.usuarioBoletos.map<Widget>((v){
                      return Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Text(
                                  data(v['vencimento']),
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  maskValor(v['valor']),
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  v['vencido'] == false && v['status']['id'] == '1' ? 'Boleto vencido' : v['status']['nome'],
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: IconButton(
                                  onPressed: v['vencido'] == false || v['status']['id'] == '3' ? null : () async {
                                    String url = v['paymentLink'];
                                    if(await canLaunch(url)){
                                      await launch(url);
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                  icon: Icon(FontAwesomeIcons.barcode),
                                ),
                              )
                            ],
                          )
                        ],
                      );
                    }).toList(),
                  ),
                ],
              );

            },
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

Future<Null> _recarregar(BuildContext context, MoneyMaskedTextController controllerValue) async {
  Map pendencias = await UsuarioProvider().getPendencias(context);

  if(!pendencias['liberado']){
    return _regularizarPendencias(context, pendencias, controllerValue);
  }

  controllerValue = MoneyMaskedTextController(leftSymbol: 'R\$ ');
  return _emitirBoleto(context, controllerValue);
}

void _regularizarPendencias(BuildContext context, Map pendencias, MoneyMaskedTextController controllerValue){

  var _fbKey;
  double width = MediaQuery.of(context).size.width;

  showSimpleDialog(
    context: context,
    titulo: 'Pendências',
    children: [
      Text('Para continuar clique abaixo para resolver as seguintes pendências com seu cadastro:'),
      SizedBox(height: 15),
      pendencias['cpf_telefone'] == true ? Container() : ListTile(
        leading: Icon(FontAwesomeIcons.idCard),
        title: Text('Dados cadastrais'),
        onTap: (){

          _fbKey = GlobalKey<FormBuilderState>();

          Navigator.pop(context);
          showSimpleDialog(
            context: context,
            barrierDismissible: false,
            titulo: 'Atualizar dados',
            children: [
              Container(
                width: width,
                child: FormBuilder(
                  key: _fbKey,
                  child: Column(
                    children: <Widget>[
                      InputField(
                        attribute: 'nome',
                        label: 'Nome completo',
                        required: true,
                        showAsterisk: false,
                        initialValue: pendencias['dados']['nome'],
                      ),
                      InputCPF(
                        attribute: 'cpf',
                        label: 'CPF',
                        required: true,
                        showAsterisk: false,
                        initialValue: pendencias['dados']['cpf'],
                      ),
                      InputTelefone(
                        attribute: 'telefone',
                        label: 'Telefone',
                        required: true,
                        showAsterisk: false,
                        initialValue: pendencias['dados']['telefone'],
                      ),
                      Container(
                        width: width,
                        height: 40,
                        child: RaisedButton(
                          onPressed: () async {
                            bool res = await UsuarioProvider().atualizaCPFTelefone(context, _fbKey);

                            if(res){
                              Navigator.pop(context);
                              _recarregar(context, controllerValue);
                            }
                          },
                          color: green,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)
                          ),
                          child: Text('SALVAR DADOS'),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        width: width,
                        child: FlatButton(
                          child: Text('Cancelar'),
                          onPressed: (){
                            Navigator.pop(context);
                            _regularizarPendencias(context, pendencias, controllerValue);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ]
          );
        },
      ),
      pendencias['endereco'] == true ? Container() : ListTile(
        leading: Icon(FontAwesomeIcons.mapSigns),
        title: Text('Seu endereço principal'),
        onTap: (){

          _fbKey = GlobalKey<FormBuilderState>();

          Navigator.pop(context);
          showSimpleDialog(
            context: context,
            titulo: 'Adicionar endereço',
            barrierDismissible: false,
            children: [
              Container(
                width: width,
                child: FormBuilder(
                  key: _fbKey,
                  child: Column(
                    children: <Widget>[
                      EnderecoWidget(botaoPreenchimento: 'Preencher'),
                      Container(
                        width: width,
                        height: 40,
                        child: RaisedButton(
                          onPressed: () async {
                            bool res = await UsuarioProvider().cadastrarNovoEndereco(context, _fbKey);

                            if(res){
                              Navigator.pop(context);
                              _recarregar(context, controllerValue);
                            }
                          },
                          color: green,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)
                          ),
                          child: Text('SALVAR DADOS'),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        width: width,
                        child: FlatButton(
                          child: Text('Cancelar'),
                          onPressed: (){
                            Navigator.pop(context);
                            _regularizarPendencias(context, pendencias, controllerValue);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ]
          );
        },
      ),
      Container(
        padding: EdgeInsets.only(top: 10),
        width: width,
        child: FlatButton(
          child: Text('Cancelar'),
          onPressed: (){
            Navigator.pop(context);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
          ),
        ),
      )
    ]
  );

}

void _emitirBoleto(BuildContext context, MoneyMaskedTextController _controllerValue){

  showSimpleDialog(
      context: context,
      barrierDismissible: false,
      titulo: 'Boleto bancário',
      children: [
        Text('O valor mínimo para adição de saldo é de R\$5,00. O boleto emitido pode levar até 3 dias úteis após o pagamento para ser compensado.'),
        SizedBox(height: 15),
        Text(
          'Para esta opção existe uma taxa de serviço no valor de R\$2,50 que será adicionado ao valor de pagamento.',
          style: TextStyle(
            color: Colors.red
          ),
        ),
        SizedBox(height: 15),
        InputField(
          attribute: 'valor',
          label: 'Qual o valor a adicionar?',
          controller: _controllerValue,
          autofocus: true,
          keyboardType: TextInputType.number,
        ),
        RaisedButton(
          child: Text('EMITIR BOLETO'),
          onPressed: () async {
            Provider.of<UsuarioProvider>(context, listen: false).saldoGerarBoleto(context, _controllerValue.text);
          },
          color: green,
          textColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
          ),
        ),
        FlatButton(
          child: Text('Cancelar'),
          onPressed: (){
            Navigator.pop(context);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
          ),
        )
      ]
  );

}