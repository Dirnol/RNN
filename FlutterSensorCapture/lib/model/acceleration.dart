class Acceleration {
  double x, y, z;
  int timeStamp;
  Acceleration(this.x, this.y, this.z, this.timeStamp);

  @override
  String toString() {
    return '$x,$y,$z,$timeStamp';
  }
}
