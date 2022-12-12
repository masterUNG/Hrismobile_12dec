import 'dart:convert' as convert;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//import 'package:imei_plugin/imei_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:platform_device_id/platform_device_id.dart';
import '../confirm/confirm.dart';
import '../about/about.dart';
import 'package:http/http.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String? _imeiNumber = "";
  String _error = "";

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
    }
    on PlatformException {
      //imeiNumber = await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
    }
    if (!mounted) return;
    setState(() {
      _imeiNumber = imeiNumber;
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String imeiNumber = "";
  TextEditingController mail = TextEditingController();
  TextEditingController person_id = TextEditingController();
  TextEditingController user_id = TextEditingController();

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
              /*
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage("lib/assets/images/BG.jpg"),
                  fit: BoxFit.cover,
                )),*/
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
                        "กรุณาบันทึก อีเมล์ หมายเลขบัตรประชาชน และ ชื่อผู้ใช้งาน เพื่อลงทะเบียนการใช้งาน",
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _gap(),
                    TextField(
                      readOnly: true,
                      enabled: false,
                      controller: TextEditingController(text: _imeiNumber),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Ref. อุปกรณ์',
                      ),
                      maxLines: 5,
                      // <-- SEE HERE
                      minLines: 1, // <-- SEE HERE
                    ),
                    _gap(),
                    TextFormField(
                      controller: mail,
                      validator: (value) {
                        // add email validation
                        if (value == null || value.isEmpty) {
                          return 'กรุณาระบุ Email';
                        }

                        bool _emailValid = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value);
                        if (!_emailValid) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    _gap(),
                    TextFormField(
                      controller: person_id,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณาระบุ หมายเลขบัตรประชาชน';
                        }
                        if (value.length != 13) {
                          return 'หมายเลขบัตรประชานต้องมี 13 หลัก';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Person_Id',
                        hintText: 'Enter Person_Id',
                        prefixIcon: Icon(Icons.account_box_sharp),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    _gap(),
                    TextFormField(
                      controller: user_id,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณาระบุ User hris';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'User_Id',
                        hintText: 'Enter User_Id',
                        prefixIcon: Icon(Icons.account_circle),
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
                            'Register',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            showAlertDialog_Load(context);


                            http.Response response1 = await SERVER1P(
                                "Android/IOS",
                                _imeiNumber.toString(),
                                mail.text,
                                user_id.text,
                                person_id.text);
                            if (response1.statusCode == 200) {
                              Navigator.pop(context);
                              List list = convert.jsonDecode(response1.body);
                              print(list[0]);
                              if (list[0]["STATUS1"] == 'False') //ลงทะเบียนไม่ผ่าน
                              {
                                showAlertDialog(context, list[0]["STATUS2"]);
                              } else {
                                showAlertDialog_confirm(context);
                                print("Y");
                              }
                            }
                            else if (response1.statusCode == 404) {
                              http.Response response2 = await SERVER2P(
                                  "Android/IOS",
                                  _imeiNumber.toString(),
                                  mail.text,
                                  user_id.text,
                                  person_id.text);
                              if (response2.statusCode == 200) {
                                Navigator.pop(context);
                                List list = convert.jsonDecode(response2.body);
                                print(list[0]);
                                if (list[0]["STATUS1"] ==
                                    'False') //ลงทะเบียนไม่ผ่าน
                                    {
                                  showAlertDialog(context, list[0]["STATUS2"]);
                                } else {
                                  showAlertDialog_confirm(context);
                                  print("Y");
                                }
                                //showAlertDialog_connect(context);
                              } else if (response1.statusCode == 404) {
                                showAlertDialog_connect(context);
                              }
                            }
                          }
                          //
                        },
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
    //content: Text("ไม่สามารถลงทะเบียนได้เนื่องจากข้อมูลไม่ตรงกับระบบ"),
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
    content: Text(
        "ลงทะเบียนเสร็จ ขั้นตอนต่อไปแล้วให้นำ Token 8 หลักที่ได้จาก email มายืนยันตัวตนครับ"),
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
Future<http.Response> SERVER1P(String Channel, String IMEI, String MAIL,
    String USERID, String PER_CARDID) async {

  String url = 'https://recruit-person.rtaf.mi.th/Mobile_Api/api/Putdata';
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
    "IMEI": IMEI,
    "MAIL": MAIL,
    "USERID": USERID,
    "PER_CARDID": PER_CARDID
  };
  String requestBody = convert.jsonEncode(body);
  Response response = await _ioClient.post(Uri.parse(url),headers:headers, body : requestBody);
  return response;
}

Future<http.Response> SERVER2P(String Channel, String IMEI, String MAIL,
    String USERID, String PER_CARDID) async {
  return http.post(
    Uri.parse('http://hris.rtaf.mi.th/Mobile_Api/api/Putdata'),
    headers: <String, String>{
      'APIKEY': '0oBAu+z60h8stTDYRiMqOtusMGW2Zei3',
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: convert.jsonEncode(<String, String>{
      "Channel": Channel,
      "IMEI": IMEI,
      "MAIL": MAIL,
      "USERID": USERID,
      "PER_CARDID": PER_CARDID,
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



