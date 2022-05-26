import 'package:flutter/material.dart';

class LayoutDivisor extends StatelessWidget {

  LayoutDivisor({this.margin});

  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfff5f5f5),
      height: 10,
      margin: margin ?? EdgeInsets.symmetric(vertical: 15),
    );
  }
}
