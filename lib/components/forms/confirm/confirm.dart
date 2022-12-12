import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hrismobile/components/forms/login/login.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

//import 'package:imei_plugin/imei_plugin.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import '../webview/webview.dart';
import '../about/about.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:http/http.dart';
class Confirm extends StatefulWidget {
  const Confirm({Key? key}) : super(key: key);

  @override
  State<Confirm> createState() => _Confirm();
}

class _Confirm extends State<Confirm> {
  String? _imeiNumber = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String? imeiNumber = "";
    try {
      imeiNumber = await PlatformDeviceId.getDeviceId;
      //imeiNumber = await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
    } on PlatformException {
      //imeiNumber = await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
    }
    if (!mounted) return;
    setState(() {
      _imeiNumber = imeiNumber;
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController token = TextEditingController();
  String imeiNumber = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: Card(
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(32.0),
              constraints: const BoxConstraints(maxWidth: 350),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('lib/assets/images/logo22.png'),
                    //const FlutterLogo(size: 100),
                    _gap(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "HRIS Mobile",
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "กรุณานำ Token ที่ระบบได้ส่งไปให้ตาม Email ที่ได้ลงทะเบียนไว้ เพื่อยืนยันตัวตนอีกครั้ง",
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    _gap(),
                    _gap(),
                    TextField(
                      enabled: false,
                      controller: TextEditingController(text: _imeiNumber),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Ref. อุปกรณ์',
                      ),
                      maxLines: 5,
                      // <-- SEE HERE
                      minLines: 1, // <-- SEE HERE
                    ),

                    _gap(),
                    TextFormField(
                      controller: token,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณาระบุ Token ที่ได้จาก Email';
                        }
                        if (value.length != 8) {
                          return 'Token ต้องมี 8 หลัก';
                        }
                        return null;
                      },
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Token',
                        hintText: 'Enter Token',
                        prefixIcon: Icon(Icons.add_card_sharp),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    _gap(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              'Confirm',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              showAlertDialog_Load(context);
                              http.Response response1 = await SERVER1C(
                                  "Android/IOS",
                                  token.text,
                                  _imeiNumber.toString());
                              if (response1.statusCode == 200) {
                                Navigator.pop(context);
                                //print(response.body);
                                List list = convert.jsonDecode(response1.body);
                                if (list[0]["STATUS1"] == 'false') //ยืนยัน
                                {
                                  showAlertDialog(context, list[0]["STATUS2"]);
                                } else
                                {
                                  showAlertDialog_success(context, list[0]["STATUS2"]);
                                }
                              }
                              else if (response1.statusCode == 404) {
                                http.Response response2 = await SERVER2C(
                                    "Android/IOS",
                                    token.text,
                                    _imeiNumber.toString());
                                if (response2.statusCode == 200) {
                                  Navigator.pop(context);
                                  //print(response.body);
                                  List list = convert.jsonDecode(
                                      response2.body);
                                  if (list[0]["STATUS1"] == 'false') //ยืนยัน
                                      {
                                    showAlertDialog(
                                        context, list[0]["STATUS2"]);
                                  } else {
                                    showAlertDialog_success(
                                        context, list[0]["STATUS2"]);
                                  }
                                }
                                else if (response2.statusCode == 404) {
                                  showAlertDialog_connect(context);
                                }
                              }
                            }
                          }
                          //
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}

showAlertDialog(BuildContext context, String error) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("คำตือน!!!!!"),
    content: Text(error),
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

showAlertDialog_success(BuildContext context, String error) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => Login()));
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("คำตือน!!!!!"),
    content: Text(error),
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

showAlertDialog_Load(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: new Row(
      children: [
        CircularProgressIndicator(),
        Container(margin: EdgeInsets.only(left: 5), child: Text("Loading...")),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Future<SecurityContext> get globalContext async {
  // Note: Not allowed to load the same certificate
  final sslCert1 = await
  rootBundle.load('lib/assets/cert/rtaf3.pfx');
  SecurityContext sc = new SecurityContext(withTrustedRoots: false);
  //sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
  sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List(), password: '522231-rtaf.mi.th');
  return sc;
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

//
Future<http.Response> SERVER1C(String Channel, String TOKEN, String IMEI) async {

  String url = 'https://recruit-person.rtaf.mi.th/Mobile_Api/api/Verified';
  HttpClient _client = new HttpClient( context: await globalContext);
  _client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => false;
  final _ioClient = new IOClient(_client);
  _ioClient.post(Uri.parse(url));

  Map<String, String> headers = {
    "APIKEY": "0oBAu+z60h8stTDYRiMqOtusMGW2Zei3",
    "Content-Type": "application/json; charset=UTF-8"
  };

  Map <String, String> body = {
    "Channel": Channel,
    "TOKEN": TOKEN,
    "IMEI": IMEI
  };
  String requestBody = convert.jsonEncode(body);
  Response response = await _ioClient.post(Uri.parse(url),headers:headers, body : requestBody);

  return response;
}

Future<http.Response> SERVER2C(String Channel, String TOKEN, String IMEI) async {
  return http.post(
    Uri.parse('http://hris.rtaf.mi.th/Mobile_Api/api/Verified'),
    headers: <String, String>{
      'APIKEY': '0oBAu+z60h8stTDYRiMqOtusMGW2Zei3',
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: convert.jsonEncode(<String, String>{
      "Channel": Channel,
      "TOKEN": TOKEN,
      "IMEI": IMEI,
    }),
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
//