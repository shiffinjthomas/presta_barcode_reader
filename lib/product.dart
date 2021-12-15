import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'api.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'main.dart';
import 'package:async/async.dart';

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

  var _url;
  final _key = UniqueKey();
  var connectionStatus = false;
  _ProductState(this._url);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController ifactiveController = TextEditingController();
  TextEditingController referencenumberController = TextEditingController();
  TextEditingController qtyonhandController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  late bool _switchValue = false;
  late bool _exicuted = false;

  Future check() async {
    try {
      var response = await http.get(Uri.parse(
          'https://shiffin.gofenice.in/tutpre/api/products?filter[reference]=$_url&display=full&language=1&output_format=JSON&ws_key=4PD3IN6G9WT6TYE67J54F7SCIF99MFC1'));
      var data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data != null) {
        connectionStatus = true;
        print("connected $connectionStatus");
      }
      if (!_exicuted) {
        if (data['products'][0]['active'].toString() == '1') {
          _switchValue = true;
        }
      }

      print(_switchValue);
      return data;
    } on SocketException catch (_) {
      connectionStatus = false;
      print("not connected $connectionStatus");
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
                // print(snapshot.data);
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
                        decoration: InputDecoration(
                            labelText:
                                "Quantity :${snapshot.data['products'][0]['quantity'].toString()}",
                            hintText: "Quantity")),
                    TextField(
                        controller: priceController,
                        decoration: InputDecoration(
                            labelText:
                                "Price :${snapshot.data['products'][0]['price'].toString()}",
                            hintText: "Price")),
                    TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                            labelText:
                                "Location :${snapshot.data['products'][0]['location'].toString()}",
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
                            qtyonhandController.text = snapshot.data['products']
                                    [0]['quantity']
                                .toString();
                          }
                          if (priceController.text == '') {
                            priceController.text = snapshot.data['products'][0]
                                    ['price']
                                .toString();
                          }
                          if (locationController.text == '') {
                            locationController.text = snapshot.data['products']
                                    [0]['location']
                                .toString();
                          }

                          final userXml =
                              '''<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">
<product>
<id>${snapshot.data['products'][0]['id'].toString()}</id>
<reference>${referencenumberController.text} </reference>
<location>${locationController.text}</location>
<price>${priceController.text}</price>
<active>${active}</active>
<name>${nameController.text} </name>
</product>
</prestashop>''';
                          final userXml2 =
                              '''<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">
<stock_availables>
<id>${snapshot.data['products'][0]['associations']['stock_availables'][0]['id'].toString()}</id>
<id_product >${snapshot.data['products'][0]['id'].toString()}</id_product>
<id_product_attribute>${snapshot.data['products'][0]['associations']['stock_availables'][0]['id_product_attribute'].toString()}</id_product_attribute>
<quantity>${qtyonhandController.text}</quantity>
 <depends_on_stock>0</depends_on_stock>
<out_of_stock>0</out_of_stock>
</stock_available>
</prestashop>''';
                          // final http.Response result = await http.put(
                          //   Uri.parse(
                          //       'https://shiffin.gofenice.in/tutpre/api/products?ws_key=4PD3IN6G9WT6TYE67J54F7SCIF99MFC1&schema=blank'),
                          //   headers: <String, String>{
                          //     'Content-Type': 'text/xml; charset=UTF-8',
                          //   },
                          //   body: userXml,
                          // );
                          print(userXml);
                          final http.Response result = await http.put(
                            Uri.parse(
                                'https://shiffin.gofenice.in/tutpre/api/stock_availables?ws_key=4PD3IN6G9WT6TYE67J54F7SCIF99MFC1&schema=blank'),
                            headers: <String, String>{
                              'Content-Type': 'text/xml; charset=UTF-8',
                            },
                            body: userXml2,
                          );
                          if (result.statusCode == 200) {
                            print('Sucess');
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyApp()));
                          } else {
                            print('Fail');
                          }
                        },
                        child: Text('Submit Data')),
                  ],
                ));
              } else {
                //If internet is not connected
                return SafeArea(
                    child: Column(
                  children: [
                    Container(
                        padding: EdgeInsets.all(20.0),
                        child: Text('loading please wait')),
                  ],
                ));
              }
            }));
  }
}

void _showSnackBar(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(' Update Quantity'),
      content: Column(
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
