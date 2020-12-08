enum OUTPUT_TYPE { file, port }

class Settings {
  OUTPUT_TYPE outputType;
  String ip;
  int port;

  Settings({this.outputType, this.ip, this.port});

  @override
  String toString() {
    return '$outputType $ip $port';
  }
}
