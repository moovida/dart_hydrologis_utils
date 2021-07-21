part of dart_hydrologis_utils;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a BSD 3 license that can be
 * found in the LICENSE file.
 */

/// Network related utilities
class NetworkUtilities {
  static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Get the first ip address found in the [NetworkInterface.list()].
  static Future<String?> getFirstIpAddress() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        return addr.address;
      }
    }
    return null;
  }
}

/// A simple websocket service client class
///
abstract class HyServerSocketService {
  final bool _isConnected = false;

  late WebSocket webSocket;
  String? _host;
  final String _port;

  /// Create the object ad connect using [_host] and [_port].
  /// If _host is not set, the ipaddress of the device is guessed.
  HyServerSocketService(this._port, [this._host]) {
    checkConnection();
  }

  void checkConnection() {
    if (!_isConnected) {
      print("Connecting to socket service.");
      connect();
      print("Connected to socket service: $_isConnected");
    }
  }

  Future<void> connect() async {
    _host ??= await NetworkUtilities.getFirstIpAddress();
    webSocket = await WebSocket.connect('ws://$_host:$_port');
    webSocket.listen((data) {
      onMessage(data);
    });
  }

  Future<void> onMessage(data);
}
