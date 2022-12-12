import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hrismobile/components/forms/register/register.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../confirm/confirm.dart';
import '../about/about.dart';
import 'package:platform_device_id/platform_device_id.dart';

import '../login/login.dart';
import '../webview/webview.dart';

class Link extends StatefulWidget {
  const Link({Key? key}) : super(key: key);

  @override
  State<Link> createState() => _Link();
}

class _Link extends State<Link> {
  String? _imeiNumber = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String? imeiNumber = "";
    try {
      //imeiNumber = await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
      imeiNumber = await PlatformDeviceId.getDeviceId;
    } on PlatformException {
      //imeiNumber = await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
    }
    if (!mounted) return;
    setState(() {
      _imeiNumber = imeiNumber;
    });
    //http.Response response = await Get_IMEI("Android/IOS", _imeiNumber.toString());

    http.Response response1 = await CHK_SERVER1(
        "Android/IOS", _imeiNumber.toString());
    try {
      if (response1.statusCode == 200) {
        //
        print(response1.body);
        List list = convert.jsonDecode(response1.body);
        print(_imeiNumber);
        if (list[0]["IMEI"] == "0" &&
            list[0]["USERID"] == "0" &&
            list[0]["STATUS"] == 'false' &&
            list[0]["RESULT"] == 'false') {
          print("register");
          showAlertDialog_register(context);
        } else if (list[0]["IMEI"] != "0" &&
            list[0]["USERID"] != "0" &&
            (list[0]["STATUS"] == null || list[0]["STATUS"] == 'false') &&
            list[0]["RESULT"] == 'true') {
          print("comfirm");
          showAlertDialog_confirm(context);
        } else if (list[0]["IMEI"] != "0" &&
            list[0]["USERID"] != "0" &&
            list[0]["STATUS"] == 'true' &&
            list[0]["RESULT"] == 'true') {
          print("เข้าใช้งาน");
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => Login()));
        }
        //
      } else if (response1.statusCode == 404) {
        http.Response response2 = await CHK_SERVER2(
            "Android/IOS", _imeiNumber.toString());
        if (response2.statusCode == 200) {
          //
          print(response2.body);
          List list = convert.jsonDecode(response2.body);
          print(_imeiNumber);
          if (list[0]["IMEI"] == "0" &&
              list[0]["USERID"] == "0" &&
              list[0]["STATUS"] == 'false' &&
              list[0]["RESULT"] == 'false') {
            print("register");
            showAlertDialog_register(context);
          } else if (list[0]["IMEI"] != "0" &&
              list[0]["USERID"] != "0" &&
              (list[0]["STATUS"] == null || list[0]["STATUS"] == 'false') &&
              list[0]["RESULT"] == 'true') {
            print("comfirm");
            showAlertDialog_confirm(context);
          } else if (list[0]["IMEI"] != "0" &&
              list[0]["USERID"] != "0" &&
              list[0]["STATUS"] == 'true' &&
              list[0]["RESULT"] == 'true') {
            print("เข้าใช้งาน");
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => Login()));
          }
          //
        }
      }
    } on SocketException catch (e) {
      showAlertDialog_connect(context);
    }
  }


final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
TextEditingController token = TextEditingController();
String imeiNumber = "";

@override
Widget build(BuildContext context) {
  return Scaffold();
}

Widget _gap() => const SizedBox(height: 16);}


showAlertDialog_register(BuildContext context) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => Register()));
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("คำตือน!!!!!"),
    content: Text("อุปกรณ์นี้ยังไม่ได้ลงทะเบียนกรุณาลงทะเบียนก่อนครับ"),
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

showAlertDialog_confirm(BuildContext context) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => Confirm()));
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("คำตือน!!!!!"),
    content: Text("อุปกรณ์นี้ยังไม่ได้ยืนยันตัวตนกรุณายืนยันตัวตนก่อนครับ"),
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


//ตรวตสอบ server
Future<http.Response> CHK_SERVER1(String Channel, String IMEI) async {
  //cer rtaf3.pfx หมดอายุ Wednesday, July 12, 2023 at 6:59:59 AM
  String url = 'https://recruit-person.rtaf.mi.th/Mobile_Api/api/Getdata';
  HttpClient _client = new HttpClient(context: await s1);
  _client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => false;
  final _ioClient = new IOClient(_client);
  _ioClient.post(Uri.parse(url));

  Map<String, String> headers = {
    "APIKEY": "0oBAu+z60h8stTDYRiMqOtusMGW2Zei3",
    "Content-Type": "application/json; charset=UTF-8"
  };

  Map<String, String> body = {"Channel": Channel, "IMEI": IMEI};
  String requestBody = convert.jsonEncode(body);
  Response response =
  await _ioClient.post(Uri.parse(url), headers: headers, body: requestBody);
  return response;
}

Future<http.Response> CHK_SERVER2(String Channel, String IMEI) async {
  return http.post(
    Uri.parse('http://hris.rtaf.mi.th/Mobile_Api/api/Getdata'),
    headers: <String, String>{
      'APIKEY': '0oBAu+z60h8stTDYRiMqOtusMGW2Zei3',
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body:
    convert.jsonEncode(<String, String>{"Channel": Channel, "IMEI": IMEI}),
  );
}

Future<SecurityContext> get s1 async {
  // Note: Not allowed to load the same certificate
  final sslCert1 = await rootBundle.load('lib/assets/cert/rtaf3.pfx');
  SecurityContext sc = new SecurityContext(withTrustedRoots: false);
  //sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
  sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List(),
      password: '522231-rtaf.mi.th');
  return sc;
}
