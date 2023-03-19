import 'package:flutter/material.dart';
import 'package:sga_scanner_2/db_helper.dart';

class ResultsScreen extends StatelessWidget{
  late final String? material;
  late final String? nome;
  late final String? PC;
  late final String? CJ;
  late final String? CX;
  ResultsScreen(this.material, this.nome, this.PC, this.CJ, this.CX);
  final dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Resultados")),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue[100],
        child: Text('Desenvolvido por: Thiago Carvalho\n Versão: 2.10',textAlign: TextAlign.center),
        elevation: 0,
      ),
      body: Container(
        alignment: Alignment.center,
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage('assets/sga_logo.png')),
            Text("                  \n    ", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue,fontSize: 28)),
            Text("Nome:", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue,fontSize: 32), textAlign: TextAlign.center,),
            Text("$nome",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),
            Text("Material:", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue,fontSize: 32)),
            Text("$material",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),),
            Text("Peça:", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue,fontSize: 32)),
            Text("$PC",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),),
            Text("Conjunto:", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue,fontSize: 32)),
            Text("$CJ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),),
            Text("Pacote / Caixa:", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue,fontSize: 32)),
            Text("$CX",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),),
          ],
        ),
      ),
    );
  }
}