import 'package:flutter/material.dart';

class AppConstant {

  static String pathImageVer = 'images/bgver.jpg';
  static String pathImageHor = 'images/bghor.jpg';

  BoxDecoration imageBox({required String path}) {
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage(path),fit: BoxFit.cover
      ),
    );
  }

  BoxDecoration colorBox({double? opacity}) {
    return BoxDecoration(
      color: const Color.fromARGB(255, 189, 230, 25).withOpacity(opacity ?? 1),
    );
  }

  TextStyle? h1Style({required BuildContext context}) {
    return Theme.of(context).textTheme.headline5;
  }
}
