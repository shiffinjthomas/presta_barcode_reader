import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'api.dart';
import 'package:http/http.dart' as http;

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

  submitdata() {
    print(nameController.text);
  }

  var _url;
  final _key = UniqueKey();
  var connectionStatus = false;
  _ProductState(this._url);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController if_activeController = TextEditingController();
  TextEditingController reference_numberController = TextEditingController();
  TextEditingController qty_on_handController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  Future check() async {
    try {
      var response = await http.get(Uri.parse(
          'https://shiffin.gofenice.in/tutpre/api/products?filter[reference]=$_url&display=full&language=1&output_format=JSON&ws_key=4PD3IN6G9WT6TYE67J54F7SCIF99MFC1'));
      var data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data != null) {
        connectionStatus = true;
        print("connected $connectionStatus");
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
                    TextField(
                        controller: if_activeController,
                        decoration: InputDecoration(
                            labelText:
                                "Active :${snapshot.data['products'][0]['id'].toString()}",
                            hintText: "Active")),
                    TextField(
                        controller: reference_numberController,
                        decoration: InputDecoration(
                            labelText:
                                "Reference :${snapshot.data['products'][0]['id'].toString()}",
                            hintText: "Reference")),
                    TextField(
                        controller: qty_on_handController,
                        decoration: InputDecoration(
                            labelText:
                                "Quantity :${snapshot.data['products'][0]['id'].toString()}",
                            hintText: "Quantity")),
                    TextField(
                        controller: priceController,
                        decoration: InputDecoration(
                            labelText:
                                "Price :${snapshot.data['products'][0]['id'].toString()}",
                            hintText: "Price")),
                    TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                            labelText:
                                "Location :${snapshot.data['products'][0]['id'].toString()}",
                            hintText: "Location")),
                    ElevatedButton(
                        // onPressed: () => scanBarcodeNormal(),
                        onPressed: () {
                          if (nameController.text == '') {
                            nameController.text =
                                snapshot.data['products'][0]['name'].toString();
                          }
                          if (if_activeController.text == '') {
                            if_activeController.text =
                                snapshot.data['products'][0]['id'].toString();
                          }
                          if (reference_numberController.text == '') {
                            if_activeController.text =
                                snapshot.data['products'][0]['id'].toString();
                          }
                          if (qty_on_handController.text == '') {
                            if_activeController.text =
                                snapshot.data['products'][0]['id'].toString();
                          }
                          if (priceController.text == '') {
                            if_activeController.text =
                                snapshot.data['products'][0]['id'].toString();
                          }
                          if (priceController.text == '') {
                            if_activeController.text =
                                snapshot.data['products'][0]['id'].toString();
                          }
                          if (locationController.text == '') {
                            if_activeController.text =
                                snapshot.data['products'][0]['id'].toString();
                          }
                          submitdata();
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
                        child: Text('Sorry No Internet')),
                  ],
                ));
              }
            }));
  }
}
