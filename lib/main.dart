import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:presta_barcode_reader/product.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _scanBarcode = 'Unknown';

  bool result = false;

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes = 'Unknown';

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
      if (_scanBarcode != 'Failed to get platform version.' ||
          _scanBarcode != 'Unknown') {
        result = true;
      } else {
        result = false;
      }
    });
  }

  static const MaterialColor primaryBlack = MaterialColor(
    _blackPrimaryValue,
    <int, Color>{
      50: Color(0xFFEF8344),
      100: Color(0xFFEF8344),
      200: Color(0xFFEF8344),
      300: Color(0xFFEF8344),
      400: Color(0xFFEF8344),
      500: Color(_blackPrimaryValue),
      600: Color(0xFFffbe98),
      700: Color(0xFFEF8344),
      800: Color(0xFFEF8344),
      900: Color(0xFFEF8344),
    },
  );
  static const int _blackPrimaryValue = 0xFFEF8344;
  TextEditingController refController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: primaryBlack,
            fontFamily: "Arial",
            textTheme: const TextTheme(
              button: TextStyle(color: Colors.white, fontSize: 20.0),
            )),
        home: Scaffold(
            appBar: AppBar(title: const Text('Barcode scan')),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                  color: primaryBlack[600],
                  border: Border.all(
                    color: primaryBlack,
                  )),
              child: Text('Devoloped by :Gofenice Tecnologies',
                  style: new TextStyle(
                    fontSize: 18.0,
                  )),
            ),
            body: Builder(builder: (BuildContext context) {
              return ListView(
                padding: const EdgeInsets.all(8),
                children: <Widget>[
                  SizedBox(
                    height: 100.0,
                  ),
                  Row(
                    children: <Widget>[
                      new Flexible(
                        child: new TextField(
                            style: new TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                            controller: refController,
                            decoration: InputDecoration(
                                labelText: "Reference No",
                                hintText: "Reference No")),
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              //    fixedSize: const Size(40, 40)
                              ),
                          // onPressed: () => scanBarcodeNormal(),
                          onPressed: () async {
                            //  print(refController.text);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Product(null, refController.text)));
                          },
                          child: Text('Go')),
                    ],
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  Center(
                    child: Text('OR',
                        style: new TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  Container(
                      alignment: Alignment.center,
                      child: Flex(
                          direction: Axis.vertical,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    fixedSize: const Size(240, 80)),
                                // onPressed: () => scanBarcodeNormal(),
                                onPressed: () async {
                                  await scanBarcodeNormal();
                                  // print(_scanBarcode);
                                  if (result) {
                                    if (_scanBarcode != '' ||
                                        _scanBarcode !=
                                            'Failed to get platform version.' ||
                                        _scanBarcode != 'Unknown') {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Product(_scanBarcode, null)));
                                    }
                                  }
                                },
                                child: Text('Scan')),
                          ])),
                ],
              );
            })));
  }
}
