import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'api.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'main.dart';

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
  late bool _switchValue;

  Future check() async {
    try {
      var response = await http.get(Uri.parse(
          'https://shiffin.gofenice.in/tutpre/api/products?filter[reference]=$_url&display=full&language=1&output_format=JSON&ws_key=4PD3IN6G9WT6TYE67J54F7SCIF99MFC1'));
      var data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data != null) {
        connectionStatus = true;
        print("connected $connectionStatus");
      }
      if (data['products'][0]['active'].toString() == '1') {
        _switchValue = true;
      } else {
        _switchValue = false;
      }
      //print(data);
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
                    // CupertinoSwitch(
                    //   value: _switchValue,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _switchValue = value;
                    //     });
                    //   },
                    // ),
                    TextField(
                        controller: ifactiveController,
                        decoration: InputDecoration(
                            labelText:
                                "Active :${snapshot.data['products'][0]['active'].toString()}",
                            hintText: "Active")),
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
<active>${ifactiveController.text}</active>
<name>${nameController.text} </name>
</product>

</prestashop>''';
                          final http.Response result = await http.put(
                            Uri.parse(
                                'https://shiffin.gofenice.in/tutpre/api/products?ws_key=4PD3IN6G9WT6TYE67J54F7SCIF99MFC1&schema=blank'),
                            headers: <String, String>{
                              'Content-Type': 'text/xml; charset=UTF-8',
                            },
                            body: userXml,
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
