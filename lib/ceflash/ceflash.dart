import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:logger/logger.dart';

import 'bootp_server.dart';
import 'magic_packet.dart';
import 'tftp_data_server.dart';
import 'tftp_server.dart';

class CeFlash {
  /// Function returns true when the provided filename has valid format
  /// Filename has valid format when the device and firmware version can be
  /// extracted from it.
  static bool checkFilenameFormat(String filename) {
    // check extension
    if (filename.split('.').last != 'bin') return false;

    // splist to  segments
    final segments = filename.split('-');

    // check segments length
    if (segments.length != 3) return false;

    // check family+model, must have at least 3 char
    if (segments[0].length < 3) return false;

    // check rev segments, starts with r
    if (!segments[1].startsWith('r')) return false;

    // check fw segment for major, minor, fix and file extension
    if (segments[2].split('.').length != 4) return false;

    return true;
  }

  ///
  /// [localAddress] local interface address selected for operation
  /// [remoteAddress] target ip address to be flashed - if the target is online, or
  /// the target temporary ip address to be used during the update
  /// [remoteMac] target device mac address
  /// [firmware] firmware binary to be flashed
  /// [timeout] operation timeout, default 5 sec
  /// [magicPacket] when true, a magic packet is sent to the [remoteAddress] to
  /// initiate bootloader mode on target to accept new firmware. When false no
  /// magic packet is sent aka. the target is expected to be in bootloader mode

  static Future<bool> update(
    InternetAddress localAddress,
    InternetAddress remoteAddress,
    List<int> remoteMac,
    Uint8List firmware, {
    bool magicPacket = true,
    Duration timeout = const Duration(seconds: 5),
    Level logLevel = Level.error,
  }) async {
    /// [bootpServerPort] is the port to bind on local machine where the bootp server
    /// should operate. By default this value equals to the original bootp server port
    /// [BootpServer.serverPort] but we can not bind to if dhcp server is running on
    /// the local machine. If the target bootloader uses different port to connect the
    /// bootpServer adjust this value to match with the target settings.
    int bootpServerPort = BootpServer.serverPort;

    /// [bootpClientPort] todo:
    int bootpClientPort = BootpServer.clientPort;

    //
    if (magicPacket) {
      // Sends a magic packet and wait for response. Not all devices send response
      // for magic packet
      await MagicPacket.send(localAddress, remoteAddress, logLevel: logLevel);
    }

    // check if client has entered into bootloader mode by waiting for its
    // valid bootp request
    if (await BootpServer.waitForBootpPacket(
        localAddress, remoteAddress, remoteMac, timeout,
        serverPort: bootpServerPort,
        clientPort: bootpClientPort,
        logLevel: logLevel)) {
      // check if valid TFTP RRQ arrived
      if (await TftpServer.waitForTftpRrq(
        localAddress,
        timeout,
        logLevel: logLevel,
      )) {
        // check if transfer completed
        if (await TftpDataServer.transfer(
          localAddress,
          remoteAddress,
          timeout,
          firmware,
          logLevel: logLevel,
        )) {
          return true;
        }
      }
    }

    return false;
  }
}
