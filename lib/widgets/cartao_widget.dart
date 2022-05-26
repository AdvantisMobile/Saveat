import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:saveat/inputs.dart';

class CartaoWidget extends StatefulWidget {

  final bool showCVV;

  CartaoWidget({this.showCVV: true});

  @override
  _CartaoWidgetState createState() => _CartaoWidgetState();
}

class _CartaoWidgetState extends State<CartaoWidget> {

  MaskedTextController _maskCartao;
  MaskedTextController _maskVencimento;

  @override
  void didChangeDependencies() {

    _maskCartao = MaskedTextController(mask: '0000 0000 0000 0000', text: '');
    _maskVencimento = MaskedTextController(mask: '00/0000', text: '');

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        InputField(
          attribute: 'numero',
          label: 'Número do cartão',
          controller: _maskCartao,
          autofocus: true,
          initialValue: null,
          required: true,
          validators: [
            FormBuilderValidators.required(errorText: 'Informe o número do cartão'),
            FormBuilderValidators.minLength(19, errorText: 'Mínimo 16 números'),
          ],
          showAsterisk: false,
          keyboardType: TextInputType.number,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: InputField(
                attribute: 'vencimento',
                label: 'Vencimento',
                hintText: 'Ex: 08/2022',
                controller: _maskVencimento,
                required: true,
                initialValue: null,
                validators: [
                  FormBuilderValidators.required(errorText: 'Quando vence?'),
                  FormBuilderValidators.minLength(7, errorText: 'Quando vence?'),
                ],
                showAsterisk: false,
                keyboardType: TextInputType.number,
              ),
            ),
            Visibility(
              visible: widget.showCVV ? true : false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 10),
                  Container(
                    width: 80,
                    child: InputField(
                      attribute: 'cvv',
                      label: 'CVV',
                      required: true,
                      showAsterisk: false,
                      validators: [
                        FormBuilderValidators.required(errorText: 'Obrigatório'),
                        FormBuilderValidators.minLength(3, errorText: 'Obrigatório'),
                      ],
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Image.asset('assets/images/cvv_icon.jpg', alignment: Alignment.bottomCenter,),
                  )
                ],
              ),
            )
          ],
        ),
        InputField(
          attribute: 'titular',
          label: 'Nome impresso no cartão',
          required: true,
          showAsterisk: false,
          validators: [
            FormBuilderValidators.required(errorText: 'Informe o nome da mesma forma que aparece no seu cartão'),
            FormBuilderValidators.minLength(6, errorText: 'Informe o nome da mesma forma que aparece no seu cartão'),
          ],
        ),
      ],
    );
  }
}
