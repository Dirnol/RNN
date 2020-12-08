import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class OutputController {
  Socket socket;

  static Future<void> writeToFile({String filePath, String fileString}) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    File file = File(filePath);

    bool exists = await file.exists();
    if (!exists) {
      file = await file.create(recursive: true);
    }

    await file.writeAsString(fileString);
  }

  Future<void> connectToSocket({String host, int port}) async {
    socket = await Socket.connect(host, port);
    print('Connected to: '
        '${socket.address}:${socket.port}');
    print('Connected to: '
        '${socket.remoteAddress.address}:${socket.remotePort}');
  }

  Future<void> closeSocket() async {
    if (socket != null) await socket.close();
  }

  Future<void> writeToSocket({String data}) {
    if (socket != null) {
      socket.write(data);
    }
  }
}
