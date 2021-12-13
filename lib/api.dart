import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BarcodeAPI {
  static String url = "link";

  String apiLink(String endPoint) {
    return '$url/$endPoint';
  }

  Future<dynamic> getAsync(String endPoint) async {
    var response = await http.get(Uri.parse(apiLink(endPoint)));
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  static String getMedia(String endPoint) {
    return "${url + endPoint}";
  }
}
