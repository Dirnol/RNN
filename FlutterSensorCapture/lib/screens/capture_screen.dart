import 'dart:async';
import 'dart:io';

import 'package:RNNSensorCapture/controller/outputcontroller.dart';
import 'package:RNNSensorCapture/model/acceleration.dart';
import 'package:RNNSensorCapture/model/settings.dart';
import 'package:RNNSensorCapture/screens/settings_screen.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:permission_handler/permission_handler.dart';

class CaptureScreen extends StatefulWidget {
  static const routeName = '\captureScreen';
  @override
  State<StatefulWidget> createState() {
    return _CaptureState();
  }
}

class _CaptureState extends State<CaptureScreen> {
  Controller con;
  Settings settings;
  OutputController outputController;
  @override
  void initState() {
    super.initState();
    con = Controller(this);
    outputController = OutputController();
    if (settings == null) {
      settings = Settings(outputType: OUTPUT_TYPE.file);
    }
  }

  void render(fn) => this.setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          con.recording
              ? Center(
                  child: RaisedButton(
                    child: Text(
                      'Stop Recording',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    onPressed: con.stop,
                  ),
                )
              : Center(
                  child: RaisedButton(
                    child: Text(
                      'Start Recording',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    onPressed: con.start,
                  ),
                ),
          Center(
            child: IconButton(
              icon: Icon(Icons.settings),
              onPressed: con.openSettings,
            ),
          ),
        ],
      ),
    );
  }
}

class Controller {
  _CaptureState _state;
  List<Acceleration> accelerations;
  StreamSubscription streamSubscription;
  bool recording = false;

  Controller(this._state);

  void start() async {
    recording = true;
    accelerations = List<Acceleration>();
    final stream = await SensorManager().sensorUpdates(
        sensorId: Sensors.LINEAR_ACCELERATION,
        interval: Sensors.SENSOR_DELAY_FASTEST);
    streamSubscription = stream.listen((event) {
      accelerations.add(Acceleration(event.data[0], event.data[1],
          event.data[2], DateTime.now().millisecondsSinceEpoch));
    });
    if (_state.settings.outputType == OUTPUT_TYPE.port) {
      _state.outputController.connectToSocket(
          host: _state.settings.ip, port: _state.settings.port);
    }
    _state.render(() {});
  }

  void socketThread() {}

  void stop() async {
    streamSubscription.cancel();
    print('Accelerations: ${accelerations.length}');
    recording = false;
    _state.render(() {});
    print(accelerations.length);
    if (_state.settings.outputType == OUTPUT_TYPE.port) {
      await writeAccelerationsToSocket(accelerations);
    } else {
      await writeAccelerationsToFile(accelerations);
    }
  }

  void openSettings() async {
    await Navigator.pushNamed(_state.context, SettingsScreen.routeName,
        arguments: {'settings': _state.settings});
    _state.render(() {
      print(_state.settings.toString());
    });
  }

  Future<void> writeAccelerationsToSocket(
      List<Acceleration> accelerations) async {
    String fileString = '';
    for (Acceleration a in accelerations) {
      fileString += a.toString() + '\n';
    }
    await _state.outputController.writeToSocket(data: fileString);
  }

  Future<void> writeAccelerationsToFile(
      List<Acceleration> accelerations) async {
    final docDir = await DownloadsPathProvider.downloadsDirectory;
    String fileName =
        '${docDir.path}/accelerations/${DateTime.now().toIso8601String()}.csv';

    String fileString = '';
    for (Acceleration a in accelerations) {
      fileString += a.toString() + '\n';
    }
    await OutputController.writeToFile(
        filePath: fileName, fileString: fileString);
  }
}
