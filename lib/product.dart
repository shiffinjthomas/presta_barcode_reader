// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
//import 'package:xml/xml.dart';
import 'main.dart';
//import 'package:async/async.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class Product extends StatefulWidget {
  final url;
  final ref;
  Product(this.url, this.ref);
  @override
  createState() => _ProductState(this.url, this.ref);
}

class _ProductState extends State<Product> {
  @override
  void initState() {
    super.initState();
  }

  // ignore: prefer_typing_uninitialized_variables
  late final _url;
  late final _ref;
  var connectionStatus = false;
  String _scanBarcode = 'Unknown';
  bool result = false;
  _ProductState(this._url, this._ref);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController ifactiveController = TextEditingController();
  TextEditingController referencenumberController = TextEditingController();
  TextEditingController qtyonhandController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController isbnController = TextEditingController();
  TextEditingController refController = TextEditingController();
  late bool _switchValue = false;
  late bool _exicuted = false;
  // final _site = "https://shiffin.gofenice.in/tutpre/api";
  // final _key = "ws_key=4PD3IN6G9WT6TYE67J54F7SCIF99MFC1";
  final _site = "https://trendz.gofenice.in/api";
  final _key = "ws_key=QCZIYHRUY39FQZU1MSNSM76QLX1RRIFP	";
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

  Future check() async {
    try {
      if (_url != null && _ref == null) {
        if (_url.length == 8 || _url.length == 13) {
          // print(
          //     '$_site/products?filter[reference]=${_url.substring(0, _url.length - 1)}&display=full&output_format=JSON&$_key');
          var response = await http.get(Uri.parse(
              '$_site/products?filter[reference]=${_url.substring(0, _url.length - 1)}&display=full&output_format=JSON&$_key'));
          var data = jsonDecode(utf8.decode(response.bodyBytes));

          var response2 = await http.get(Uri.parse(
              '$_site/stock_availables?filter[id_product]=${data['products'][0]['id']}&display=full&output_format=JSON&$_key'));
          var data2 = jsonDecode(utf8.decode(response2.bodyBytes));
          data['stock'] = data2['stock_availables'][0];
          // print(data);
          if (data != null) {
            connectionStatus = true;
            //  print("connected $connectionStatus");
          }

          if (!_exicuted) {
            if (data['products'][0]['active'].toString() == '1') {
              _switchValue = true;
            }
          }

          return data;
        }
      }
      if (_url == null && _ref != null) {
        var response = await http.get(Uri.parse(
            '$_site/products?filter[reference]=$_ref&display=full&output_format=JSON&$_key'));
        var data = jsonDecode(utf8.decode(response.bodyBytes));

        var response2 = await http.get(Uri.parse(
            '$_site/stock_availables?filter[id_product]=${data['products'][0]['id']}&display=full&output_format=JSON&$_key'));
        var data2 = jsonDecode(utf8.decode(response2.bodyBytes));
        data['stock'] = data2['stock_availables'][0];
        // print(data);
        if (data != null) {
          connectionStatus = true;
          //  print("connected $connectionStatus");
        }

        if (!_exicuted) {
          if (data['products'][0]['active'].toString() == '1') {
            _switchValue = true;
          }
        }

        return data;
      }
    } on SocketException catch (_) {
      connectionStatus = false;
      // print("not connected $connectionStatus");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
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
        body: FutureBuilder(
            future: check(), // a previously-obtained Future or null
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.data != null) {
                //if Internet is connected
                // print(snapshot.data['stock']['id']);
                return SafeArea(
                    child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: <Widget>[
                    Container(
                      padding: new EdgeInsets.only(right: 13.0),
                      child: new Text(
                        '${snapshot.data['products'][0]['name'].toString()}',
                        overflow: TextOverflow.fade,
                        style: new TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    TextField(
                        style: new TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        controller: nameController,
                        decoration: InputDecoration(
                            labelText:
                                "Name :${snapshot.data['products'][0]['name'].toString()}",
                            hintText: snapshot.data['products'][0]['name']
                                .toString())),
                    Row(
                      children: [
                        Text('Active',
                            style: new TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            )),
                        Switch(
                          value: _switchValue,
                          onChanged: (value) {
                            setState(() {
                              _switchValue = value;
                              _exicuted = true;
                            });
                          },
                          activeTrackColor: Colors.lightGreenAccent,
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                    // ElevatedButton(
                    //   child: Text(' Update Quantity'),
                    //   style: ElevatedButton.styleFrom(
                    //     primary: Colors.red, // background
                    //     onPrimary: Colors.white, // foreground
                    //   ),
                    //   onPressed: () async {
                    //     _showSnackBar(context, 'Wrong Username or password');
                    //   },
                    // ),
                    // TextField(
                    //     controller: ifactiveController,
                    //     keyboardType: TextInputType.number,
                    //     decoration: InputDecoration(
                    //         labelText:
                    //             "Active :${snapshot.data['products'][0]['active'].toString()}",
                    //         hintText: "Active")),
                    TextField(
                        style: new TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        controller: referencenumberController,
                        decoration: InputDecoration(
                            labelText:
                                "Reference :${snapshot.data['products'][0]['reference'].toString()}",
                            hintText: "Reference")),
                    TextField(
                        style: new TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        controller: isbnController,
                        decoration: InputDecoration(
                            labelText:
                                "ISBN :${snapshot.data['products'][0]['isbn'].toString()}",
                            hintText: "ISBN")),
                    TextField(
                        style: new TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        controller: qtyonhandController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText:
                                "Quantity :${snapshot.data['stock']['quantity'].toString()}",
                            hintText: "Quantity")),
                    TextField(
                        style: new TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText:
                                "Price :${snapshot.data['products'][0]['price'].toString()}",
                            hintText: "Price")),
                    TextField(
                        style: new TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        controller: locationController,
                        decoration: InputDecoration(
                            labelText:
                                "Location :${snapshot.data['stock']['location'].toString()}",
                            hintText: "Location")),
                    ElevatedButton(
                        // onPressed: () => scanBarcodeNormal(),
                        onPressed: () async {
                          if (nameController.text == '') {
                            nameController.text =
                                snapshot.data['products'][0]['name'].toString();
                          }
                          if (ifactiveController.text == '') {
                            ifactiveController.text = snapshot.data['products']
                                    [0]['active']
                                .toString();
                          }
                          var active = _switchValue ? '1' : '0';
                          if (referencenumberController.text == '') {
                            referencenumberController.text = snapshot
                                .data['products'][0]['reference']
                                .toString();
                          }
                          if (isbnController.text == '') {
                            isbnController.text =
                                snapshot.data['products'][0]['isbn'].toString();
                          }
                          if (qtyonhandController.text == '') {
                            qtyonhandController.text =
                                snapshot.data['stock']['quantity'].toString();
                          }
                          if (priceController.text == '') {
                            priceController.text = snapshot.data['products'][0]
                                    ['price']
                                .toString();
                          }
                          if (locationController.text == '') {
                            locationController.text =
                                snapshot.data['stock']['location'].toString();
                          }

                          final userXml =
                              '''<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">
  <product>
    <id>${snapshot.data['products'][0]['id'].toString().trim()}</id>
    <id_manufacturer>${snapshot.data['products'][0]['id_manufacturer']}</id_manufacturer>
    <id_supplier>${snapshot.data['products'][0]['id_supplier']}</id_supplier>
    <id_category_default>${snapshot.data['products'][0]['id_category_default']}</id_category_default>
    <new>${snapshot.data['products'][0]['new']}</new>
    <cache_default_attribute>${snapshot.data['products'][0]['cache_default_attribute']}</cache_default_attribute>
     <id_tax_rules_group>${snapshot.data['products'][0]['id_tax_rules_group']}</id_tax_rules_group>
      <id_shop_default>${snapshot.data['products'][0]['id_shop_default']}</id_shop_default>
    <reference>${referencenumberController.text.trim()}</reference>
    <supplier_reference>${snapshot.data['products'][0]['supplier_reference']}</supplier_reference>
    <location>${locationController.text.trim()}</location>
   <ean13>${referencenumberController.text.trim()}</ean13>
   <isbn>${isbnController.text.trim()}</isbn>
    <price>${priceController.text.trim()}</price>
    <wholesale_price>${snapshot.data['products'][0]['wholesale_price']}</wholesale_price>
    <unity>${snapshot.data['products'][0]['unity']}</unity>
    <unit_price_ratio>${snapshot.data['products'][0]['unit_price_ratio']}</unit_price_ratio>
    <active>$active</active>
   <show_price>${snapshot.data['products'][0]['show_price']}</show_price>
    <indexed>${snapshot.data['products'][0]['indexed']}</indexed>
    <visibility>${snapshot.data['products'][0]['visibility']}</visibility>
    <advanced_stock_management>${snapshot.data['products'][0]['advanced_stock_management']}</advanced_stock_management>
    <date_add>${snapshot.data['products'][0]['date_add']}</date_add>
    <date_upd>${snapshot.data['products'][0]['date_upd']}</date_upd>
    <pack_stock_type>${snapshot.data['products'][0]['pack_stock_type']}</pack_stock_type>
    <meta_description>${snapshot.data['products'][0]['meta_description']}</meta_description>
    <meta_keywords>${snapshot.data['products'][0]['meta_keywords']}</meta_keywords>
    <meta_title>${snapshot.data['products'][0]['meta_title']}</meta_title>
    <link_rewrite>${snapshot.data['products'][0]['link_rewrite']}</link_rewrite>
    <name>${nameController.text.trim()} </name>
    <description>${snapshot.data['products'][0]['description']}</description>
    <description_short>${snapshot.data['products'][0]['description_short']}</description_short>
    <available_now>${snapshot.data['products'][0]['available_now']} </available_now>
    <available_later>${snapshot.data['products'][0]['available_later']}</available_later>
</product>
</prestashop>''';
//                               '''<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">
// <product>
// <id>${snapshot.data['products'][0]['id'].toString().trim()}</id>
// <reference>${referencenumberController.text.trim()}</reference>
// <location>${locationController.text.trim()}</location>
// <price>${priceController.text.trim()}</price>
// <active>$active</active>
// <ean13>${referencenumberController.text.trim()}</ean13>
// <name>${nameController.text.trim()}</name>
// </product>
// </prestashop>''';
                          final userXml2 =
                              '''<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">
  <stock_available>
    <id>${snapshot.data['stock']['id'].toString().trim()}</id>
    <id_product>${snapshot.data['stock']['id_product'].toString().trim()}</id_product>
    <id_product_attribute>${snapshot.data['stock']['id_product_attribute'].toString().trim()}</id_product_attribute>
    <id_shop>${snapshot.data['stock']['id_shop'].toString().trim()}</id_shop>
    <id_shop_group>${snapshot.data['stock']['id_shop_group'].toString().trim()}</id_shop_group>
    <quantity>${qtyonhandController.text.trim()}</quantity>
    <depends_on_stock>${snapshot.data['stock']['depends_on_stock'].toString().trim()}</depends_on_stock>
    <out_of_stock>${snapshot.data['stock']['out_of_stock'].toString().trim()}</out_of_stock>
    <location>${locationController.text.trim()}</location>
  </stock_available>
</prestashop>''';
                          //print(userXml);
                          // print(userXml2);
                          final http.Response result = await http.put(
                            Uri.parse('$_site/products?$_key'),
                            headers: <String, String>{
                              'Content-Type': 'text/xml; charset=UTF-8',
                            },
                            body: userXml,
                          );
                          //  print(result.statusCode);
                          final http.Response result2 = await http.put(
                            Uri.parse('$_site/stock_availables?$_key'),
                            headers: <String, String>{
                              'Content-Type': 'text/xml; charset=UTF-8',
                            },
                            body: userXml2,
                          );
                          if (result.statusCode == 200 &&
                              result2.statusCode == 200) {
                            _showSnackBar(context, 'Updated Product');
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyApp()));
                          } else {
                            _showSnackBar(
                                context, 'Cannot Update Product Try Again');
                          }
                        },
                        child: Text('Submit Data',
                            style: new TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ))),
                  ],
                ));
              } else {
                //If internet is not connected
                return SafeArea(
                    child: Center(
                  child: DelayedDisplay(
                    delay: Duration(seconds: 5),
                    child: Container(
                        padding: new EdgeInsets.only(top: 100),
                        child: ListView(
                          padding: const EdgeInsets.all(8),
                          children: <Widget>[
                            Text(
                              "Product not found. Try again later",
                              style:
                                  TextStyle(color: Colors.red, fontSize: 20.0),
                            ),
                            SizedBox(
                              height: 40.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
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
                                                builder: (context) => Product(
                                                    null, refController.text)));
                                      },
                                      child: Text('Go')),
                                ],
                              ),
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
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(240, 80)),
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
                              child: Text('Scan Again'),
                            ),
                          ],
                        )),
                  ),
                ));
              }
            }));
  }
}

void _showSnackBar(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(message),
      content: Column(
        // ignore: prefer_const_literals_to_create_immutables
        children: [],
      ),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
