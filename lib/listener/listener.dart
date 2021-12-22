import 'dart:io';

import 'package:plugs/listener/plug_event.dart';

//
typedef EventCallback = void Function(String address, int code);

//
typedef ConnectionStateChangedCallback = void Function(
    String address, bool isConnected);

//
typedef ConnectionErrorCallback = void Function(String address, dynamic error);

//
typedef PlugEventCallback = void Function(PlugEvent event);

class Listener {
  // remote tcp port from where events originated
  static const eventPort = 6069;

  //
  final String address;

  //
  Socket? _socket;

  Listener(this.address);

  ///
  void connect(
    InternetAddress sourceAddress, {
    PlugEventCallback? onEvent,
    ConnectionErrorCallback? onError,
    Duration timeout = const Duration(seconds: 2),
    int port = 0,
  }) async {
    Socket.connect(
      InternetAddress(address, type: InternetAddressType.IPv4),
      eventPort,
      sourceAddress: sourceAddress,
      timeout: timeout,
    ).then((socket) {
      // fire connected event
      onEvent?.call(PlugEvent(address, PlugEvent.connected));

      // set as local variable
      _socket = socket;

      // listen on incoming packets
      socket.timeout(timeout).listen(
        (packet) {
          // multipe events may arrive in one packet, so we need
          // search multiple events within one packet by slicing it
          var noEvents = packet.length ~/ PlugEvent.packetSize;
          var offset = 0;
          for (var i = 0; i < noEvents; i++) {
            // get event and shift offset
            var event = packet.skip(offset).take(PlugEvent.packetSize);

            // get event from msg
            int code = event.first;

            // handle events
            switch (code) {
              case PlugEvent.ping:
                // ignore ping event
                break;
              default:
                // call event
                onEvent?.call(PlugEvent(address, code));
            }

            //
            offset += PlugEvent.packetSize;
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
          onEvent?.call(PlugEvent(address, PlugEvent.removed));
        },
      );
    });
  }

  ///
  void close() {
    _socket?.destroy();
  }
}