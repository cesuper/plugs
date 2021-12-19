class Event {
  //
  static const ping = 255;

  //
  static const online = 1;

  //
  static const offline = 2;

  //
  static const error = 3;

  //
  final DateTime ts;

  //
  final String host;

  //
  final int code;

  const Event(this.ts, this.host, this.code);

  @override
  String toString() => 'Event(ts: $ts, host: $host, code: $code)';
}
