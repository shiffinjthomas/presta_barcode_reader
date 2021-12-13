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
    print(idController.text);
  }

  var _url;
  final _key = UniqueKey();
  var connectionStatus = false;
  _ProductState(this._url);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController idController = TextEditingController();
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
                        controller: idController,
                        decoration: InputDecoration(
                            labelText:
                                "Id :${snapshot.data['products'][0]['id'].toString()}",
                            hintText: "id")),
                    ElevatedButton(
                        // onPressed: () => scanBarcodeNormal(),
                        onPressed: () {
                          if (nameController.text == '') {
                            nameController.text =
                                snapshot.data['products'][0]['name'].toString();
                          }
                          if (idController.text == '') {
                            idController.text =
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
