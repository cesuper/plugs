import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:plugs/socket/Socket.dart';

import 'Info.dart';

const PLUG_API = '/api/plug.cgi';
const PLUG_API_RESTART = '/api/plug/restart.cgi';
const PLUG_API_CONFIG = '/api/plug/config.cgi';
const PLUG_API_EEPROM = '/api/plug/eeprom.cgi';

class Plug {
  // plug network address with port
  final String address;

  final Socket socket;

  Plug(this.address) : socket = Socket(address);

  /// Read Info
  Future<Info> info({int timeout = 1000}) async {
    var uri = Uri.http('$address', PLUG_API);
    var r = await http.get(uri).timeout(Duration(milliseconds: timeout));
    return Info.fromJson(r.body);
  }

  /// Restarts the plug
  Future<int> restart({bool bootloader = false}) async {
    var body = bootloader ? {'bootloader': true} : {};

    var uri = Uri.http('$address', PLUG_API_RESTART);
    var r = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return r.statusCode;
  }

  /// Read EEPROM
  Future<String> readEEPROM() async {
    var uri = Uri.http('$address', PLUG_API_EEPROM);
    var r = await http.get(uri);
    return r.body;
  }

  /// Write EEPROM
  Future<int> writeEEPROM(String content) async {
    var uri = Uri.http('$address', PLUG_API_EEPROM);
    var r = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: content,
    );
    return r.statusCode;
  }
}
