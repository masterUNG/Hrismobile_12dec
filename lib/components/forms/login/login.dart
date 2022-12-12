import 'dart:io';
import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../menu/menu.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool _isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
        body: Center(
            child: _isSmallScreen
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _Logo(),
                      _FormContent(),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.all(32.0),
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Row(
                      children: const [
                        Expanded(child: _Logo()),
                        Expanded(
                          child: Center(child: _FormContent()),
                        ),
                      ],
                    ),
                  )));
  }
}

class _Logo extends StatelessWidget {
  const _Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool _isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('lib/assets/images/logo.png'),
        //FlutterLogo(size: _isSmallScreen ? 100 : 200),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "ยินดีต้อนรับเข้าสู่ระบบ HRIS",
            textAlign: TextAlign.center,
            style: _isSmallScreen
                ? Theme.of(context).textTheme.headline5
                : Theme.of(context)
                    .textTheme
                    .headline4
                    ?.copyWith(color: Colors.black),
          ),
        )
      ],
    );
  }
}

class _FormContent extends StatefulWidget {
  const _FormContent({Key? key}) : super(key: key);

  @override
  State<_FormContent> createState() => __FormContentState();
}

class __FormContentState extends State<_FormContent> {
  bool _isPasswordVisible = false;
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
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController user = TextEditingController();
  TextEditingController pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: user,
              validator: (value) {
                // add email validation
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอก User hris';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'กรุณากรอก User hris',
                prefixIcon: Icon(Icons.account_box_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            _gap(),
            TextFormField(
              controller: pass,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอก Pass hris';
                }

                if (value.length < 2) {
                  return 'Password must be at least 1 characters';
                }
                return null;
              },
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )),
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
                    'เข้าสู่ระบบ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    showAlertDialog_Load(context);
                    http.Response response = await Get_Login("Android/IOS",
                        user.text, pass.text, _imeiNumber.toString());
                    if (response.statusCode == 200) {
                      Navigator.pop(context);
                      List list = convert.jsonDecode(response.body);
                      print(response.body);
                      if (list[0]["Status2"] == "false") {
                        showAlertDialog(context, list[0]["Status1"]);
                      } else {


                        final key = 'r0cKst@';
                        final claimSet = JwtClaim(
                            subject: 'Login',
                            issuer: list[0]["PERSON_PK"],
                            audience: <String>[
                              list[0]["ORG_PK"],
                              list[0]["FLAG"]
                            ],
                            otherClaims: <String, dynamic>{
                              'typ': 'authnresponse',
                              'pld': {'k': 'v'}
                            },
                            maxAge: const Duration(minutes: -10));
                            String token = issueJwtHS256(claimSet, key);
                            print(token);

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('key', key);
                        await prefs.setString('token', token);
                        showAlertDialog(context, "เข้าสู่ระบบสำเร็จ");
                      }
                    } else if (response.statusCode == 404) {
                      Navigator.pop(context);
                      showAlertDialog_connect(context);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}

//เช็ค login
Future<http.Response> Get_Login(
    String Channel, String user, String pass, String IMEI) async {
  String url = 'https://recruit-person.rtaf.mi.th/Mobile_Api/api/Login';
  HttpClient _client = new HttpClient(context: await globalContext);
  _client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => false;
  final _ioClient = new IOClient(_client);
  _ioClient.post(Uri.parse(url));

  Map<String, String> headers = {
    "APIKEY": "0oBAu+z60h8stTDYRiMqOtusMGW2Zei3",
    "Content-Type": "application/json; charset=UTF-8"
  };

  Map<String, String> body = {
    "Channel": Channel,
    "User": user,
    "Pass": pass,
    "IMEI": IMEI
  };
  String requestBody = convert.jsonEncode(body);
  Response response =
      await _ioClient.post(Uri.parse(url), headers: headers, body: requestBody);

  return response;
}

Future<SecurityContext> get globalContext async {
  // Note: Not allowed to load the same certificate
  final sslCert1 = await rootBundle.load('lib/assets/cert/rtaf3.pfx');
  SecurityContext sc = new SecurityContext(withTrustedRoots: false);
  //sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
  sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List(),
      password: '522231-rtaf.mi.th');
  return sc;
}

showAlertDialog(BuildContext context, String error) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => Menu()));
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

showAlertDialog_connect(BuildContext context) {
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
