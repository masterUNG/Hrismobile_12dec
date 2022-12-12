import 'package:flutter/material.dart';
import 'package:hrismobile/components/forms/about/about.dart';
import 'package:hrismobile/state_tablet/about_tablet.dart';
import 'package:hrismobile/widget/widget_text.dart';
import 'package:responsive_builder/responsive_builder.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBuilder(
          builder: (context, SizingInformation sizingInformation) {
        if (sizingInformation.deviceScreenType == DeviceScreenType.mobile) {
          return const About();
        }

        if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
          return const AboutTablet();
        }
        return WidgetText(text: 'Not Work on Your Device');
      }),
    );
  }
}
