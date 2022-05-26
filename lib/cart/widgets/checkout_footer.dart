import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:saveat/blocs/api_bloc.dart';
import 'package:saveat/blocs/cart_bloc.dart';
import 'package:saveat/inputs.dart';
import 'package:saveat/model/carrinho/carrinho_model.dart';
import 'package:saveat/provider/acesso_provider.dart';
import 'package:saveat/provider/offer_provider.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/endereco_form.dart';

class CheckoutFooter extends StatelessWidget {
  const CheckoutFooter(this.empresaId, this.bloc);

  final String empresaId;
  final CartBloc bloc;

  static bool _usuarioLiberado = false;
  static ApiBloc apiBloc;

  @override
  Widget build(BuildContext context) {
    apiBloc = Provider.of<ApiBloc>(context, listen: false);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: green, boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 5)]),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Total do pedido'),
                  SizedBox(
                    height: 5,
                  ),
                  StreamBuilder<Object>(
                      stream: bloc.outValorCompra,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Container();

                        return Text(
                          maskValor(snapshot.data.toString()),
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                ],
              ),
            ),
            Expanded(
              child: Container(
                height: 50,
                child: StreamBuilder<bool>(
                    initialData: false,
                    stream: bloc.outLiberaPagamento,
                    builder: (context, snapshot) {
                      bool _libera = snapshot.data;

                      return RaisedButton(
                        onPressed: () {
                          if (_libera) {
                            _processarPagamento(context);
                          }
                        },
                        color: Colors.white,
                        child: Text('PEDIR'),
                        disabledColor: Colors.white54,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processarPagamento(BuildContext context) async {
    if (!_usuarioLiberado) {
      showLoading(context, text: 'Analisando pendências no cadastro...');
      Map pendencias = await apiBloc.getPendencias();
      hideLoading(context);

      if (!pendencias['liberado']) {
        return _regularizarPendencias(context, pendencias);
      }

      _usuarioLiberado = true;
    }

    showLoading(context, text: 'Finalizando o pedido...');
    CarrinhoModel carrinho = bloc.getCarrinhoDaEmpresa(empresaId);

    print(carrinho.toJsonEnvioServidor());

    Map res = await apiBloc.postPedido(carrinho.toJson());
    hideLoading(context);

    print('_processarPagamento');
    print(res);

    if (res['code'] == '011') {
      return await alert(
        context: context,
        title: 'Pedido não realizado',
        message: res['message'],
      );
    }

    if (res['code'] == '015') {
      bloc.processaCupomDesconto(empresaId, null);
      return await alert(
        context: context,
        title: 'Ops',
        message: res['message'],
      );
    }

    if (res['code'] != '010') {
      return await alert(
        context: context,
        title: 'Ops',
        message: res['message'],
      );
    }

    _usuarioLiberado = false;

    // limpa os carrinhos
    bloc.clearCarrinhos(empresaId);

    // atualiza as ofertas
    Provider.of<OfertasProvider>(context, listen: false).getHome(context);

    // atualiza o saldo do usuario
    Provider.of<AcessoProvider>(context, listen: false).saldoRefresh();

    // redireciona para a tela de agradecimento
    Navigator.pushNamedAndRemoveUntil(context, '/agradecimento', ModalRoute.withName('/'), arguments: {
      'pedidoId': res['itens']['pedidoId'].toString(),
    });
  }

  void _regularizarPendencias(BuildContext context, Map pendencias) async {
    var _fbKey;
    double width = MediaQuery.of(context).size.width;

    if (pendencias['endereco'] == false) {
      _fbKey = GlobalKey<FormBuilderState>();

      showSimpleDialog(context: context, titulo: 'Qual o seu endereço?', barrierDismissible: false, children: [
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
                      var form = _fbKey.currentState;

                      FocusScope.of(context).requestFocus(new FocusNode());

                      if (form.validate()) {
                        form.save();

                        Map params = form.value;

                        showLoading(context);
                        Map res = await apiBloc.postClientAddress(empresaId, params);
                        hideLoading(context);

                        if (res['code'] == '010') {
                          Navigator.pop(context);
                          _processarPagamento(context);
                        } else {
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    child: Text('SALVAR DADOS'),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  width: width,
                  child: FlatButton(
                    child: Text('Cancelar'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                )
              ],
            ),
          ),
        )
      ]);

      return;
    }

    if (pendencias['cpf_telefone'] == false) {
      _fbKey = GlobalKey<FormBuilderState>();

      showSimpleDialog(context: context, barrierDismissible: false, titulo: 'Atualize seus dados', children: [
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
                      var form = _fbKey.currentState;

                      FocusScope.of(context).requestFocus(new FocusNode());

                      if (form.validate()) {
                        form.save();

                        Map params = form.value;

                        showLoading(context);
                        Map res = await apiBloc.atualizaCPFTelefone(params);
                        hideLoading(context);

                        if (res['code'] == '010') {
                          Navigator.pop(context);
                          _usuarioLiberado = true;
                          _processarPagamento(context);
                        } else {
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
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text('SALVAR DADOS'),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  width: width,
                  child: FlatButton(
                    child: Text('Cancelar'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ]);
    }
  }
}
