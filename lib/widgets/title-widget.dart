import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {

  const TitleWidget(this.text, {this.marginLeft: 16, this.marginTop: 16, this.marginBottom: 16, this.marginRight: 10, this.action});

  final String text;
  final double marginLeft;
  final double marginTop;
  final double marginBottom;
  final double marginRight;
  final Widget action;

  @override
  Widget build(BuildContext context) {

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.fromLTRB(marginLeft, marginTop, marginRight, marginBottom),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            action ?? Container()
          ],
        ),
      ),
    );
  }
}
