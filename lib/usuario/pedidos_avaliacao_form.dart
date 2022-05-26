import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saveat/inputs.dart';
import 'package:saveat/provider/usuario_provider.dart';
import 'package:saveat/util.dart';

class PedidosAvaliacaoFormPage extends StatefulWidget {

  final Map pedido;

  PedidosAvaliacaoFormPage(this.pedido);

  @override
  _PedidosAvaliacaoFormPageState createState() => _PedidosAvaliacaoFormPageState();
}

class _PedidosAvaliacaoFormPageState extends State<PedidosAvaliacaoFormPage> {

  Map votos = {
    'comida': 0,
    'atendimento': 0,
  };

  double _media = 0;
  String _acao = 'post';

  TextEditingController _controllerComentario = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();



    if(widget.pedido['avaliacao'] != ''){

      Map avaliacao = widget.pedido['avaliacao'];

      votos = {
        'comida': double.tryParse(avaliacao['comida']),
        'atendimento': double.tryParse(avaliacao['atendimento']),
      };

      _media = (votos['comida'] + votos['atendimento']) / 2;

      _controllerComentario = TextEditingController(text: avaliacao['comentario']);
      _acao = 'put';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Avalie a forma como você se sentiu sobre o estabelecimento na compra deste pedido.'),
              SizedBox(height: 10),
              Text('Em relação a comida'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _estrelas('comida'),
              ),
              SizedBox(height: 10),
              Text('Em relação ao atendimento'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _estrelas('atendimento'),
              ),
              SizedBox(height: 5),
              Center(
                child: Container(
                  width: 100,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(3)
                  ),
                  child: Column(
                    children: <Widget>[
                      Text('média', style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12
                      ),),
                      SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.star, size: 22, color: Colors.yellow[800]),
                          SizedBox(width: 5,),
                          Text(_media.toString(), style: TextStyle(fontSize: 18),),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              InputField(
                attribute: 'comentario',
                label: 'Comentário (opcional)',
                controller: _controllerComentario,
                hintText: 'Opcional',
                maxLines: null,
                textInputAction: TextInputAction.newline,
              ),
              SizedBox(height: 10),
              RaisedButton(
                child: Text('SALVAR AVALIAÇÃO'),
                color: green,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
                ),
                onPressed: (){
                  Provider.of<UsuarioProvider>(context, listen: false).salvarAvaliacao(
                    context, votos, _controllerComentario.text, widget.pedido['empresa']['id'], widget.pedido['avaliacao'] != '' ? widget.pedido['avaliacao']['id'] : '', _acao
                  );
                },
              ),
              FlatButton(
                child: Text('Cancelar'),
                onPressed: (){
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _estrelas(String tipo){
    List<Widget> out = List<Widget>();
    for(int i = 1; i <= 5; i++){
      out.add(
        IconButton(
          icon: Icon(Icons.star, size: 20, color: votos[tipo] >= i ? Colors.yellow[800] : Colors.grey,),
          onPressed: (){
            setState(() {
              votos[tipo] = i;
              _media = (votos['comida'] + votos['atendimento']) / 2;
            });
          },
        ),
      );
    }

    return out;
  }
}
