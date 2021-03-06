import 'dart:io';

//
typedef ListenerConnectionStateChangedCallback = void Function(String address);

//
typedef PlugConnectedCallback = void Function(String address);

//
typedef ConnectionErrorCallback = void Function(String address, dynamic error);

//
typedef PlugEventCallback = void Function(String address, int code);

class Listener {
  ///
  /// Plug
  ///

  /// Ping event is used to get life-signal from plugs. These events
  // are not handled by the api, but the loss if the ping event results
  // device disconnect event. Plug sends ping events in 1 sec period.
  // this event is ignored by the API by default
  static const eventPing = 255;

  // request for fw update detected
  static const eventUpdate = 11;

  ///
  /// Socket
  ///

  // plug removed from socket
  static const eventSocketRemoved = 20;

  // plug process socket content
  static const eventSocketConnecting = 21;

  // plug removed from socket
  static const eventSocketConnected = 22;

  // plug performed write event to socket
  static const eventSocketContentChanged = 23;

  /// Dio

  // state of the field pin changed
  static const eventFieldChanged = 40;

  // state of the input pin changed
  // TODO: add pin index, and new value for event data
  static const eventInputChanged = 41;

  // state of the output pin changed
  // TODO: add pin index, and new value for event data
  static const eventOutputChanged = 42;

  // edge trigger condition met on input pin 0
  // TODO:
  static const eventInput0Triggered = 43;

  // edge trigger condition met on input pin 1
  //
  static const eventInput1Triggered = 44;

  // edge trigger condition met on input pin 2
  //
  static const eventInput2Triggered = 45;

  // edge trigger condition met on input pin 3
  //
  static const eventInput3Triggered = 46;

  /// Ain

  //
  static const eventSamplingStarted = 60;

  //
  static const eventSamplingFinished = 61;

  /// decode event to String
  static String getName(int code) {
    switch (code) {
      case eventPing:
        return 'PLUG_PING';
      case eventUpdate:
        return 'PLUG_UPDATE';
      case eventSocketRemoved:
        return 'SOCKET_REMOVED';
      case eventSocketConnecting:
        return 'SOCKET_CONNECTING';
      case eventSocketConnected:
        return 'SOCKET_CONNECTED';
      case eventSocketContentChanged:
        return 'SOCKET_CONTENT_CHANGED';
      case eventFieldChanged:
        return 'DIO_FIELD_CHANGED';
      case eventInputChanged:
        return 'DIO_INPUT_CHANGED';
      case eventOutputChanged:
        return 'DIO_OUTPUT_CHANGED';
      case eventInput0Triggered:
        return 'DIO_INPUT_0_TRIGGERED';
      case eventInput1Triggered:
        return 'DIO_INPUT_1_TRIGGERED';
      case eventInput2Triggered:
        return 'DIO_INPUT_2_TRIGGERED';
      case eventInput3Triggered:
        return 'DIO_INPUT_3_TRIGGERED';
      default:
        return 'UNDEFINED';
    }
  }

  // size of the tcp packet
  static const packetSize = 64;

  // remote tcp port from where events originated
  static const eventPort = 6069;

  //
  final String address;

  //
  Socket? _socket;

  Listener(this.address);

  ///
  void connect(
    InternetAddress localAddress, {
    ListenerConnectionStateChangedCallback? onConnected,
    ListenerConnectionStateChangedCallback? onDisconnected,
    PlugEventCallback? onEvent,
    ConnectionErrorCallback? onError,
    Duration timeout = const Duration(seconds: 2),
    int port = 0,
  }) async {
    Socket.connect(
      InternetAddress(address, type: InternetAddressType.IPv4),
      eventPort,
      sourceAddress: localAddress,
      timeout: timeout,
    ).then((socket) {
      // fire connected event
      onConnected?.call(address);

      // set as local variable
      _socket = socket;

      // listen on incoming packets
      socket.timeout(timeout).listen(
        (packet) {
          // multipe events may arrive in one packet, so we need
          // search multiple events within one packet by slicing it
          var noEvents = packet.length ~/ packetSize;
          var offset = 0;
          for (var i = 0; i < noEvents; i++) {
            // get event and shift offset
            var event = packet.skip(offset).take(packetSize);

            // get event from msg
            int code = event.first;

            // handle events
            switch (code) {
              case eventPing:
                // ignore ping event
                break;
              default:
                // call event
                onEvent?.call(address, code);
            }

            //
            offset += packetSize;
          }
        },
        onError: (e, trace) {
          // close the socket
          socket.destroy();

          // create network error event
          onError?.call(address, e);
        },
        onDone: () {
          // create disconnected
          onDisconnected?.call(address);
        },
      );
    });
  }

  ///
  void close() {
    _socket?.destroy();
  }
}
