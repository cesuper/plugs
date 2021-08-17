import 'dart:convert';

import '../plug/Snapshot.dart';
import 'SmpSensorData.dart';

class SmpSnapshot extends Snapshot {
  final List<String> socket;
  final List<SmpSensorData> sensors;

  SmpSnapshot(this.socket, this.sensors);

  Map<String, dynamic> toMap() {
    return {
      'socket': socket,
      'sensors': sensors.map((x) => x.toMap()).toList(),
    };
  }

  factory SmpSnapshot.fromMap(Map<String, dynamic> map) {
    return SmpSnapshot(
      List<String>.from(map['socket']),
      List<SmpSensorData>.from(
          map['sensors']?.map((x) => SmpSensorData.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory SmpSnapshot.fromJson(String source) =>
      SmpSnapshot.fromMap(json.decode(source));
}
