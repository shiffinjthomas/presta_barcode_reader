// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
//import 'package:xml/xml.dart';
import 'main.dart';
//import 'package:async/async.dart';
import 'package:delayed_display/delayed_display.dart';

class Product extends StatefulWidget {
  final url;
  Product(this.url);
  @override
  createState() => _ProductState(this.url);
}

class _ProductState extends State<Product> {
  @override
  void initState() {
    super.initState();
  }

  // ignore: prefer_typing_uninitialized_variables
  late final _url;
  var connectionStatus = false;
  _ProductState(this._url);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController ifactiveController = TextEditingController();
  TextEditingController referencenumberController = TextEditingController();
  TextEditingController qtyonhandController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  late bool _switchValue = false;
  late bool _exicuted = false;
  // final _site = "https://shiffin.gofenice.in/tutpre/api";
  // final _key = "ws_key=4PD3IN6G9WT6TYE67J54F7SCIF99MFC1";
  final _site = "https://trendz.gofenice.in/api";
  final _key = "ws_key=QCZIYHRUY39FQZU1MSNSM76QLX1RRIFP	";
  Future check() async {
    try {
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
                    TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                            labelText:
                                "Name :${snapshot.data['products'][0]['name'].toString()}",
                            hintText: snapshot.data['products'][0]['name']
                                .toString())),
                    Row(
                      children: [
                        Text('Active'),
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
                        controller: referencenumberController,
                        decoration: InputDecoration(
                            labelText:
                                "Reference :${snapshot.data['products'][0]['reference'].toString()}",
                            hintText: "Reference")),
                    TextField(
                        controller: qtyonhandController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText:
                                "Quantity :${snapshot.data['stock']['quantity'].toString()}",
                            hintText: "Quantity")),
                    TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText:
                                "Price :${snapshot.data['products'][0]['price'].toString()}",
                            hintText: "Price")),
                    TextField(
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
<reference>${referencenumberController.text.trim()}</reference>
<location>${locationController.text.trim()}</location>
<price>${priceController.text.trim()}</price>
<active>$active</active>
<ean13>${referencenumberController.text.trim()}</ean13>
<name>${nameController.text.trim()} </name>
</product>
</prestashop>''';
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
                          // print(userXml);
                          // print(userXml2);
                          final http.Response result = await http.put(
                            Uri.parse('$_site/products?$_key'),
                            headers: <String, String>{
                              'Content-Type': 'text/xml; charset=UTF-8',
                            },
                            body: userXml,
                          );
                          // print(userXml2);
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
                        child: Text('Submit Data')),
                  ],
                ));
              } else {
                //If internet is not connected
                return SafeArea(
                    child: Center(
                  child: DelayedDisplay(
                    delay: Duration(seconds: 5),
                    child: Text(
                      "Product not found. Try again later",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
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
