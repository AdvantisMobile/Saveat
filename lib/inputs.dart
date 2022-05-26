import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

import 'util.dart';

class InputTelefone extends StatefulWidget {

  final String attribute;
  final String label;
  final String initialValue;
  final bool required;
  final bool showAsterisk;

  InputTelefone({
    Key key,
    this.attribute,
    this.label,
    this.initialValue,
    this.required,
    this.showAsterisk,
  }): super(key: key);

  @override
  _InputTelefoneState createState() => _InputTelefoneState();
}

class _InputTelefoneState extends State<InputTelefone> {

  MaskedTextController _controllerTelefone;

  @override
  void initState() {

    if(widget.initialValue != null){
      if(widget.initialValue.toString()?.replaceAll(RegExp('[^0-9]'), '').toString().length > 10){
        _controllerTelefone = MaskedTextController(mask: '(00)00000-0000', text: widget.initialValue);
      }else{
        _controllerTelefone = MaskedTextController(mask: '(00)0000-0000', text: widget.initialValue);
      }
    }else {
      _controllerTelefone = MaskedTextController(mask: '(00)0000-0000');
    }

    _controllerTelefone.addListener((){

      var count = _controllerTelefone.text.length >= 1 ? _controllerTelefone.text.replaceAll(RegExp('[^0-9]'), '') : '';

      if(count.length > 10){
        _controllerTelefone.updateMask('(00)00000-0000');
      }else{
        _controllerTelefone.updateMask('(00)0000-00000');
      }

    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InputField(
      attribute: widget.attribute,
      label: widget.label,
      controller: _controllerTelefone,
      keyboardType: TextInputType.number,
      required: widget.required,
      showAsterisk: widget.showAsterisk,
      validators: [
        FormBuilderValidators.required(errorText: 'Este campo é obrigatório!'),
        FormBuilderValidators.minLength(13, errorText: 'Incorreto'),
      ],
    );
  }
}

class InputCPF extends StatefulWidget {

  final String attribute;
  final String label;
  final String initialValue;
  final bool required;
  final bool showAsterisk;
  final bool autofocus;

  InputCPF({
    Key key,
    this.attribute,
    this.label,
    this.initialValue,
    this.required,
    this.showAsterisk = true,
    this.autofocus = false,
  }): super(key: key);

  @override
  _InputCPFState createState() => _InputCPFState();
}

class _InputCPFState extends State<InputCPF> {

  MaskedTextController _controllerCPF;

  @override
  void initState() {

    _controllerCPF = MaskedTextController(mask: '000.000.000-00', text: widget.initialValue);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InputField(
      attribute: widget.attribute,
      label: widget.label,
      controller: _controllerCPF,
      keyboardType: TextInputType.number,
      required: widget.required,
      showAsterisk: widget.showAsterisk,
      autofocus: widget.autofocus,
      validators: [
        FormBuilderValidators.required(errorText: 'Este campo é obrigatório!'),
        FormBuilderValidators.minLength(14, errorText: 'Incorreto'),
      ],
    );
  }
}

class InputData extends StatefulWidget {

  final String attribute;
  final String label;
  final String initialValue;
  final bool required;

  InputData({
    Key key,
    this.attribute,
    this.label,
    this.initialValue,
    this.required,
  }): super(key: key);

  @override
  _InputDataState createState() => _InputDataState();
}

class _InputDataState extends State<InputData> {

  MaskedTextController _controllerData;

  @override
  void initState() {

    _controllerData = MaskedTextController(mask: '00/00/0000', text: widget.initialValue);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InputField(
      attribute: widget.attribute,
      label: widget.label,
      controller: _controllerData,
      keyboardType: TextInputType.number,
      required: widget.required,
      validators: [
        FormBuilderValidators.required(errorText: 'Este campo é obrigatório!'),
      ],
    );
  }
}


class InputField extends StatelessWidget {

  final String attribute;
  final String label;
  final String hintText;
  final String initialValue;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final validators;
  final dynamic controller;
  final bool required;
  final bool obscureText;
  final bool uppercase;
  final bool showAsterisk;
  final bool autofocus;
  final int maxLines;
  final Function onChanged;
  final FocusNode focusNode;
  final InputDecoration decoration;
  final EdgeInsetsGeometry margin;

  InputField({
    Key key,
    this.attribute,
    this.label,
    this.hintText = '',
    this.initialValue = '',
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.validators,
    this.controller,
    this.required = false,
    this.obscureText = false,
    this.uppercase = false,
    this.showAsterisk = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.onChanged,
    this.focusNode,
    this.decoration,
    this.margin,
  }): super (key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.only(bottom: 16),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              FormBuilderTextField(
                attribute: attribute,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                initialValue: initialValue,
                obscureText: obscureText,
                onChanged: onChanged,
                textCapitalization: uppercase ? TextCapitalization.characters : TextCapitalization.none,
                autofocus: autofocus,
                focusNode: focusNode,
                style: TextStyle(
                  fontFamily: 'Roboto',
                ),
                decoration: decoration ?? InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(
                    color: green
                  ),
                  isDense: true,
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 1,
                      color: green
                    )
                  ),
                ),
                maxLines: maxLines,
                controller: controller ?? null,
                validators: validators != null || (validators != null && required != null && required == true) ? validators : [],
              ),
              Visibility(
                visible: required == true && showAsterisk ? true : false,
                child: Positioned(
                  child: Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20
                    ),
                  ),
                  top: 4,
                  right: 7,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class DropdownField extends StatelessWidget {

  final List items;
  final String attribute;
  final String label;
  final String initialValue;
  final bool required;
  final Function onChanged;
  final String indexValue;
  final InputDecoration decoration;

  DropdownField({
    Key key,
    this.items,
    this.attribute,
    this.label,
    this.initialValue,
    this.required,
    this.onChanged,
    this.indexValue,
    this.decoration,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            DropdownButtonHideUnderline(
              child: FormBuilderDropdown<dynamic>(
                attribute: attribute,
                initialValue: initialValue,
                isDense: true,
                isExpanded: true,
                onChanged: (v){
                  if(onChanged != null){
                    onChanged(v);
                  }
                },
                decoration: decoration ?? InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(
                    color: green,
                    fontSize: 16
                  ),
                  isDense: true,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 1,
                      color: green
                    )
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red,
                      width: 1
                    )
                  )
                ),
                items: items == null ? [] : items.map<DropdownMenuItem>((v){
                  return DropdownMenuItem(
                    value: v['id'],
                    child: Text(v[indexValue].toString(), style: TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                validators: required != null && required == true ? [
                  FormBuilderValidators.pattern('[^0]', errorText: 'Este campo é obrigatório'),
                  FormBuilderValidators.required(errorText: 'Este campo é obrigatório!'),
                ] : [],
              ),
            ),
            Visibility(
              visible: required == true,
              child: Positioned(
                child: Text(
                  '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20
                  ),
                ),
                top: 4,
                right: 7,
              ),
            )
          ],
        ),
      ],
    );
  }
}

class InputCPFCNPJ extends StatefulWidget {

  final String attribute;
  final String label;
  final String initialValue;
  final bool required;

  InputCPFCNPJ({
    Key key,
    this.attribute,
    this.label,
    this.initialValue,
    this.required,
  }): super(key: key);

  @override
  _InputCPFCNPJState createState() => _InputCPFCNPJState();
}

class _InputCPFCNPJState extends State<InputCPFCNPJ> {

  MaskedTextController _controller;

  @override
  void initState() {

    if(widget.initialValue != null){
      if(widget.initialValue.toString()?.replaceAll(RegExp('[^0-9]'), '').toString().length > 11){
        _controller = MaskedTextController(mask: '00.000.000/0000-00', text: widget.initialValue);
      }else{
        _controller = MaskedTextController(mask: '000.000.000-000000', text: widget.initialValue);
      }
    }else {
      _controller = MaskedTextController(mask: '000.000.000-000000');
    }

    _controller.addListener((){

      var count = _controller.text.length >= 1 ? _controller.text.replaceAll(RegExp('[^0-9]'), '') : '';

      if(count.length > 11){
        _controller.updateMask('00.000.000/0000-00');
      }else{
        _controller.updateMask('000.000.000-000000');
      }

    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InputField(
      attribute: widget.attribute,
      label: widget.label,
      controller: _controller,
      keyboardType: TextInputType.number,
      required: widget.required,
      validators: [
        FormBuilderValidators.required(errorText: 'Este campo é obrigatório!'),
      ],
    );
  }
}
