part of dart_hydrologis_utils;

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
  static Future<String> getFirstIpAddress() async {
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
  Logger log = Logger();
  final bool _isConnected = false;

  WebSocket webSocket;
  String _host;
  final String _port;

  /// Create the object ad connect using [_host] and [_port].
  /// If _host is not set, the ipaddress of the device is guessed.
  HyServerSocketService(this._port, [this._host]) {
    assert(_port != null);

    checkConnection();
  }

  void checkConnection() {
    if (!_isConnected) {
      log.i("Connecting to socket service.");
      connect();
      log.i("Connected to socket service: $_isConnected");
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

