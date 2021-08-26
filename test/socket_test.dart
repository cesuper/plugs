import 'package:plugs/plug/Plug.dart';
import 'package:plugs/socket/SocketDeviceConnectData.dart';
import 'package:test/test.dart';

import 'models/CpChannelSocketData.dart';
import 'models/CpSocketData.dart';

void main() async {
  var plug = Plug('192.168.100.111:8080');
  var socket = plug.socket;

  test('Socket', () async {
    // here we expect only response
    await socket.addresses();
  });

  group('DS28EC20', () {
    test('DS28EC20 - Basic R/W', () async {
      // remove the socket
      await socket.remove();

      // create simulated device
      var connectData = <SocketDeviceConnectData>[
        SocketDeviceConnectData('43F4704001000008', 'MyOriginalData'),
        SocketDeviceConnectData('43F4704001000009', '123'),
        SocketDeviceConnectData('43F4704001000010', '12312321321'),
      ];

      // connect simulated devices
      expect(await socket.connect(connectData), 200);

      // get all ds28ec20 addresses
      var devices = await socket.addresses(family: '43');

      // read back the data
      var content = await socket.h43Data(devices);

      expect(content.map((e) => e.content),
          equals(connectData.map((e) => e.content)));

      // remove socket
      await socket.remove();
    });

    test('CpSocketData', () async {
      // remove the socket
      await socket.remove();

      // channels to be serialized
      var channels = <CpChannelSocketData>[
        CpChannelSocketData('sn#1', 12.3, 'Channel 1', 1, 0),
        CpChannelSocketData('sn#2', 7.5, 'Channel 2', 1, 0),
      ];

      // cpData to be serialized
      var socketData = CpSocketData(channels);

      // create simulated device
      var connectData = <SocketDeviceConnectData>[
        SocketDeviceConnectData('43F4704001000008', socketData.toJson()),
      ];

      // connect simulated devices
      expect(await socket.connect(connectData), 200);

      // get all ds28ec20 addresses
      var devices = await socket.addresses(family: '43');

      // read back the data
      var content = await socket.h43Data(devices);

      expect(content.map((e) => e.content),
          equals(connectData.map((e) => e.content)));

      // deserialize

      // remove socket
      //await socket.remove();
    });
  });
}
