import 'dart:io';
import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrismobile/components/forms/link/link.dart';
import 'package:hrismobile/utility/app_constant.dart';
import 'package:hrismobile/widget/widget_image.dart';
import 'package:hrismobile/widget/widget_text.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:platform_device_id/platform_device_id.dart';


class AboutTablet extends StatefulWidget {
  const AboutTablet({Key? key}) : super(key: key);

  @override
  State<AboutTablet> createState() => _About();
}

class _About extends State<AboutTablet> {
  String? _imeiNumber = "";
  String? _server = "";
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String? imeiNumber = "";
    try {
      imeiNumber = await PlatformDeviceId.getDeviceId;
    } on PlatformException {
      showAlertDialog_alert(context);
    }
    if (!mounted) return;
    setState(() {
      _imeiNumber = imeiNumber;
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, BoxConstraints boxConstraints) {
        return Form(
          key: _formKey,
          child: Container(
            decoration: AppConstant().imageBox(path: AppConstant.pathImageHor),
            width: boxConstraints.maxWidth,
            height: boxConstraints.maxHeight,
            child: Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WidgetImage(width: 350,height: 350,),
                const SizedBox(width: 36,),
                Card(
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
                          // const WidgetImage(),
                          //const FlutterLogo(size: 100),
                          _gap(),
                          titleHead(context),
                          showDetail(context),
                          _gap(),
                          bottonExcept(context),
                          textVersion(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Text textVersion() => Text('v1.0(7)', textAlign: TextAlign.left);

  Widget bottonExcept(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            'ยอมรับการใช้งาน',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        onPressed: () async {
          if (_formKey.currentState?.validate() ?? false) {
            showAlertDialog_Load(context);
            //
            try {
              http.Response response1 =
                  await CHK_SERVER1("Android/IOS", _imeiNumber.toString());
              if (response1.statusCode == 200) {
                //
                Navigator.pop(context);
                showAlertDialog(
                    context, "ท่านจงเตรียมข้อมูลเพื่อที่จะต้องลงทะเบียน");
              } else if (response1.statusCode == 404) {
                Navigator.pop(context);
                http.Response response2 =
                    await CHK_SERVER2("Android/IOS", _imeiNumber.toString());
                if (response2.statusCode == 200) {
                  Navigator.pop(context);
                  showAlertDialog(
                      context, "ท่านจงเตรียมข้อมูลเพื่อที่จะต้องลงทะเบียน");
                }
              }
            } on Exception {
              Navigator.pop(context);
              http.Response response2 =
                  await CHK_SERVER2("Android/IOS", _imeiNumber.toString());
              if (response2.statusCode == 200) {
                showAlertDialog(
                    context, "ท่านจงเตรียมข้อมูลเพื่อที่จะต้องลงทะเบียน");
              }
              //showAlertDialog_connect(context);
            }
          }
          //
        },
      ),
    );
  }

  Padding showDetail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        "แอพพลิเคชั่นนี้จัดทำขึ้นเพื่อใช้ประโยชน์ในการบริหารงานด้านกำลังพล กองทัพอากาศ ผู้ที่จะเข้าถึงการใช้งาน แอพพลิเคชั่น นี้"
        "ต้องเป็น 'บุคลาการที่ทำงานด้านกำลังพล' โดยการเข้าใช้งานนั้น ระบบต้องการข้อมูลจากผู้ใช้งาน ดังนี้ [อีเมล(ของกองทัพอากาศ), "
        "หมายเลขบัตรประชาชน, ชื่อเข้าใช้งาน และ หมายเลขอุปกรณ์ที่ติดตั้ง แอพพลิเคชั่น]"
        " ในการลงทะเบียนขอใช้งาน แอพพลิเคชั่น เมื่อลงทะเบียนเสร็จเรียบร้อยและระบบได้ตรวจสอบข้อมูลเมื่อถูกต้องระบบจะส่ง รหัสยืนยันตัวตนไปยัง อีเมล(ของกองทัพอากาศ) "
        "ที่ลงทะเบียนไว้ข้างต้น ซึ่งบุคนทั่วไปไม่สามารถใช้งานได้",
        style: Theme.of(context).textTheme.caption,
        textAlign: TextAlign.center,
      ),
    );
  }

  Padding titleHead(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: WidgetText(
        text: "ข้อกำหนดการใช้งาน",
        textStyle: AppConstant().h1Style(context: context),
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
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => Link()));
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

//ตรวตสอบ server
Future<http.Response> CHK_SERVER1(String Channel, String IMEI) async {
  //cer rtaf3.pfx หมดอายุ Wednesday, July 12, 2023 at 6:59:59 AM

  String url = 'https://recruit-person.rtaf.mi.th/Mobile_Api/api/Getdata';
  HttpClient _client = new HttpClient(context: await s1);
  _client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => false;
  final _ioClient = new IOClient(_client);
  _ioClient.post(Uri.parse(url)).timeout(const Duration(seconds: 10));

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

//แจ้งเตือน หาหมายเลข
showAlertDialog_alert(BuildContext context) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => AboutTablet()));
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("คำตือน!!!!!"),
    content: Text("ไม่สามารถดูหมายเลขประจำอุปกรณ์นี้ได้"),
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

//load
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

//connect
showAlertDialog_connect(BuildContext context) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => AboutTablet()));
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
