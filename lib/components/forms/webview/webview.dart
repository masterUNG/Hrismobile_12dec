import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:hrismobile/components/forms/register/register.dart';
import '../about/about.dart';

void main() {
  runApp(
    const MaterialApp(
      home: WebViewApp(),
    ),
  );
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  // Add from here ...
  String? _imeiNumber = "";

  @override
  void initState() {
    if (Platform.isAndroid) {
      //initPlatformState();
      WebView.platform = SurfaceAndroidWebView();
    }
    super.initState();
  }

  Future<void> initPlatformState() async {
    String? imeiNumber = "";
    try {
      //imeiNumber = await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
      imeiNumber = await PlatformDeviceId.getDeviceId;
    } on PlatformException {}
    if (!mounted) return;
    setState(() {
      _imeiNumber = imeiNumber;
    });
    http.Response response =
        await Get_IMEI("Android/IOS", _imeiNumber.toString());
    if (response.statusCode == 200) {

    }
    else if (response.statusCode == 404)
    {
      showAlertDialog_connect(context);
    }
  }

  // ... to here.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const WebView(
        initialUrl:
            'https://hris.rtaf.mi.th/HRIS_Mobile/Program/Login?hash=RSR5YQEujFywAQnBlvxav37kniri4aCs%2fqE6XE61x%2fM%3d',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}

Future<http.Response> Get_IMEI(String Channel, String IMEI) {
  return http.post(
    Uri.parse('https://recruit-person.rtaf.mi.th/Mobile_Api/api/Getdata'),
    headers: <String, String>{
      'APIKEY': '0oBAu+z60h8stTDYRiMqOtusMGW2Zei3',
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: convert.jsonEncode(<String, String>{
      "Channel": Channel,
      "IMEI": IMEI
    }),
  );
}

showAlertDialog_connect(BuildContext context) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => About()));
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("คำตือน!!!!!"),
    content: Text("กรุณาเชื่อมต่ออินเตอร์เนต / Please connect internet"),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
