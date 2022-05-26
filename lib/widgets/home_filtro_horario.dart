import 'package:flutter/material.dart';
import 'package:saveat/provider/offer_provider.dart';
import 'package:saveat/util.dart';
import 'package:saveat/widgets/title-widget.dart';

class HomeFiltroHorario extends StatefulWidget {

  HomeFiltroHorario(this.providerOfertas);

  final OfertasProvider providerOfertas;

  @override
  _HomeFiltroHorarioState createState() => _HomeFiltroHorarioState();
}

class _HomeFiltroHorarioState extends State<HomeFiltroHorario> {

  double _lowerValue = 0;
  double _upperValue = 24;
  String _lowerLabel = '00:00';
  String _upperLabel = '24:00';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 20,),
        Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            SliderTheme(
              child: RangeSlider(
                min: 0,
                max: 24,
                values: RangeValues(_lowerValue, _upperValue),
                divisions: 48,
                labels: RangeLabels(_lowerLabel, _upperLabel),
                onChanged: (RangeValues v){
                  setState(() {
                    _lowerValue = v.start;
                    _upperValue = v.end;

                    _lowerLabel = timeConvert((_lowerValue * 60).toInt());
                    _upperLabel = timeConvert((_upperValue * 60).toInt());
                  });
                },
                onChangeEnd: (RangeValues v){
                  String horaInicio = timeConvert((v.start * 60).toInt());
                  String horaTermino = timeConvert((v.end * 60).toInt());

                  if(horaInicio != widget.providerOfertas.horaInicio || widget.providerOfertas.horaTermino != horaTermino) {
                    widget.providerOfertas.horaInicio = horaInicio;
                    widget.providerOfertas.horaTermino = horaTermino;
                    widget.providerOfertas.clearOfertasHome();
                    widget.providerOfertas.getHome(context);
                  }

                },
              ),
              data: SliderThemeData(
                trackHeight: 1,
                inactiveTrackColor: Colors.grey[100],
              ),
            ),
            Positioned(
              top: -16,
              left: 16,
              child: TitleWidget(
                'Horário de salvamento',
                marginTop: 0,
                marginLeft: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
