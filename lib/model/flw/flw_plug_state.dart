part of plugs;

class FlwPlugState {
  //
  final int delay;
  //
  final List<FlwSensorData> sensors;

  FlwPlugState(this.delay, this.sensors);

  Map<String, dynamic> toMap() {
    return {
      'delay': delay,
      'sensors': sensors.map((x) => x.toMap()).toList(),
    };
  }

  factory FlwPlugState.fromMap(Map<String, dynamic> map) {
    return FlwPlugState(
      map['delay']?.toInt() ?? 0,
      List<FlwSensorData>.from(
          map['sensors']?.map((x) => FlwSensorData.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory FlwPlugState.fromJson(String source) =>
      FlwPlugState.fromMap(json.decode(source));

  @override
  String toString() => 'FlwPlugState(delay: $delay, sensors: $sensors)';
}