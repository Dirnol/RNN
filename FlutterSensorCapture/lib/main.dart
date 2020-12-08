import 'package:RNNSensorCapture/screens/capture_screen.dart';
import 'package:RNNSensorCapture/screens/settings_screen.dart';
import 'package:flutter/material.dart';

enum DEVICE_TYPE { phone, watch }
void main() {
  runApp(SensorCaptureApp());
}

class SensorCaptureApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: CaptureScreen.routeName,
      routes: {
        CaptureScreen.routeName: (context) => CaptureScreen(),
        SettingsScreen.routeName: (context) => SettingsScreen(),
      },
    );
  }
}
