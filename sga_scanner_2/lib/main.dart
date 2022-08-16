import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:sga_scanner_2/dbHelper.dart';
import 'package:sga_scanner_2/resultsScreen.dart';


void main() {
  runApp(MyTest());
}

class MyTest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>
      MainActivity();
}

class MainActivity extends State<MyTest> {
  String _scanBarcode = "";
  // var sqliteDB = DbHelper().Dbbbb();


  final dbHelper = DatabaseHelper.instance;
  final dbWindows = DatabaseHelper.instance;
  @override
  void initState(){
    super.initState();
  }

//EM IMPLANTAÇÃO, ESTA FUNÇÃO IRÁ VERIFICAR SE O CÓDIGO ESTÁ CORRETO, SEM PUXAR AS INFORMAÇÕES PARA A TELA
  Future<void> startBarcodeScanStream() async{
    FlutterBarcodeScanner.getBarcodeStreamReceiver('#ff6666', "Cancelar", true, ScanMode.BARCODE)!.listen((barcode) => print(barcode));
    // sqliteDB;
  }

//ESTA FUNÇÃO PUXA AS INFORMAÇÕES DO PRODUTO ESCANEADO PARA CONFERÊNCIA.

  Future<void> scanBarcodeNormal(BuildContext context) async {
    String barcodeScan;
    // sqliteDB;
    try {
      barcodeScan = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancelar', true, ScanMode.BARCODE);

      String barcodeScanRes = (await _qtdRows(barcodeScan.trim()) != 0) ? barcodeScan.trim() : barcodeScan.substring(1).trim();
      carregarDados(context, barcodeScanRes.trim());

    } on PlatformException {
      barcodeScan = 'Um erro ocorreu.';
    }
    if (!mounted) return;
    setState(() {
      //_scanBarcode = barcodeScan;
    }
    );

  }
  Future<void> carregarDados(BuildContext context,String barcodeScanRes) async {
    try {
      final db = (Platform.isWindows || Platform.isLinux) ? await dbWindows
          .database : await dbHelper.database;
      var result_mat = (await db?.rawQuery(
          'SELECT * FROM "$TABLE_NAME" WHERE "$col_MATERIAL" = "$barcodeScanRes" or "$col_CODIGO" = "$barcodeScanRes" '));
      var material = result_mat?.elementAt(0)["material"] as String;
      print("teste4 material");

      var rawPC = await db?.rawQuery(
          'SELECT "codigo","cod_set",(SELECT COUNT(*) FROM "$TABLE_NAME" WHERE "$col_MATERIAL" = "$material" and "$col_SET" = "PC") as "qtd" FROM "$TABLE_NAME" WHERE "$col_MATERIAL" = "$material" and "$col_SET" = "PC"');
      var rawCJ = await db?.rawQuery(
          'SELECT "codigo","cod_set",(SELECT COUNT(*) FROM "$TABLE_NAME" WHERE "$col_MATERIAL" = "$material" and "$col_SET" = "SET") as "qtd" FROM "$TABLE_NAME" WHERE "$col_MATERIAL" = "$material" and "$col_SET" = "SET"');
      var rawCX = await db?.rawQuery(
          'SELECT "codigo","cod_set",(SELECT COUNT(*) FROM "$TABLE_NAME" WHERE "$col_MATERIAL" = "$material" and "$col_SET" != "PC" AND "$col_SET" != "SET") as "qtd" FROM "$TABLE_NAME" WHERE "$col_MATERIAL" = "$material" and "$col_SET" != "PC" AND "$col_SET" != "SET"');
      print("teste5 raw");

      List<List<Object>> values = [];
      List<Object> peca = [
        (rawPC!.isNotEmpty) ? "${rawPC.elementAt(0)["cod_set"]} ${rawPC
            .elementAt(0)["codigo"]}" : "-",
        (rawPC.isNotEmpty) ? rawPC.elementAt(0)["qtd"].toString() : "0"
      ];
      List<Object> conj = [
        (rawCJ!.isNotEmpty) ? "${rawCJ.elementAt(0)["cod_set"]} ${rawCJ
            .elementAt(0)["codigo"]}" : "-",
        (rawCJ.isNotEmpty) ? rawCJ.elementAt(0)["qtd"].toString() : "0"
      ];
      List<Object> caix = [
        (rawCX!.isNotEmpty) ? "${rawCX.elementAt(0)["cod_set"]} ${rawCX
            .elementAt(0)["codigo"]}" : "-",
        (rawCX.isNotEmpty) ? rawCX.elementAt(0)["qtd"].toString() : "0"
      ];
      values.add(peca);
      values.add(conj);
      values.add(caix);

      print(values);
      String PC = (int.tryParse(values[0][1].toString())! < 2) ? values[0][0]
          .toString() : "Inconclusivo, solicite correção";
      String CJ = (int.tryParse(values[1][1].toString())! < 2) ? values[1][0]
          .toString() : "Inconclusivo, solicite correção";
      String CX = (int.tryParse(values[2][1].toString())! < 2) ? values[2][0]
          .toString() : "Inconclusivo, solicite correção";

      var boolin = await _qtdRows(barcodeScanRes);
      if (boolin != 0) {
        print("teste7 boolean");
        var material = result_mat?.elementAt(0)["material"] as String;
        var nome = result_mat?.elementAt(0)["nome"] as String;
        novaTela(context, material, nome, PC, CJ, CX);
        result_mat?.forEach((row) => print(row));
      } else {
        ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text(
            "Não existe no banco de dados")));
      }
    }on RangeError{
      carregarDados(context, barcodeScanRes.substring(1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: const Text('SGA Scanner')),
    bottomNavigationBar: BottomAppBar(
      color: Colors.blue[100],
      child: Text('Desenvolvido por: Thiago Carvalho\n Versão: 2.10',textAlign: TextAlign.center),
      elevation: 0,
    ),
            body: Builder(builder: (BuildContext context) {
              return Container(
                  alignment: Alignment.center,
                  child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image(image: AssetImage('assets/sga_logo.png')),
                        Text("                      ", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue,fontSize: 52)),
                        ElevatedButton(
                          onPressed: () => scanBarcodeNormal(context),
                          child: Text('Iniciar Scanner', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 42)),
                        ),
                        TextField(autofocus: true,textAlign: TextAlign.center,maxLines: 1, onSubmitted: (value) => carregarDados(context, value)),
                        // ElevatedButton(
                        //     onPressed: () => startBarcodeScanStream(),
                        //     child: Text('Testar códigos')),
                        Text('', style: TextStyle(fontSize: 20))
                      ]
                  )
              );
            }
            )
        )
    );
  }

  novaTela(BuildContext context, String material, String nome, PC, CJ, CX) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ResultsScreen(material, nome, PC, CJ, CX)),);
  }

  Future<int?> _qtdRows(String codigo) async {
    var db = await dbHelper;
    // List<Map>? result = await db.queryAllRows();
    int? result1 = await db.queryRowCount(codigo);
    int? result2 = await db.queryRowCount(codigo.substring(1));
    var result = (result1 != 0) ? result1 : result2;
    // print("RESULLLLTAAAAADO1 $result1");
    // print("RESULLLLTAAAAADO2 $result2");
    return result;
  }


}
