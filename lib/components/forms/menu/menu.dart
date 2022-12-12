import 'package:flutter/material.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _Menu();
}

class _Menu extends State<Menu> {
  String? _key = "";
  String? _token = "";
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
// Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    final String? key = prefs.getString('key');
    final String? token = prefs.getString('token');
    print(key);
    print(token);
    _key = key;
    _token = token;


  }


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController token = TextEditingController();
  String imeiNumber = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  Widget _gap() => const SizedBox(height: 16);}