import 'package:flutter/services.dart';

enum VpnStatus { disconnected, connecting, connected, disconnecting, error }

class VpnService {
  static const _methodChannel = MethodChannel('com.example.vpn/control');
  static const _eventChannel = EventChannel('com.example.vpn/status');

  Stream<VpnStatus> get statusStream {
    return _eventChannel
        .receiveBroadcastStream()
        .map((event) => _parseStatus(event as String));
  }

  Future<void> connect({required String configJson}) async {
    try {
      await _methodChannel.invokeMethod('connect', {'config': configJson});
    } on PlatformException catch (e) {
      throw VpnException('Connect failed: ${e.message}');
    }
  }

  Future<void> disconnect() async {
    try {
      await _methodChannel.invokeMethod('disconnect');
    } on PlatformException catch (e) {
      throw VpnException('Disconnect failed: ${e.message}');
    }
  }

  Future<VpnStatus> getCurrentStatus() async {
    try {
      final String? result =
          await _methodChannel.invokeMethod<String>('getStatus');
      return _parseStatus(result ?? 'disconnected');
    } on PlatformException catch (e) {
      throw VpnException('Status check failed: ${e.message}');
    }
  }

  VpnStatus _parseStatus(String raw) {
    return switch (raw) {
      'connected'     => VpnStatus.connected,
      'connecting'    => VpnStatus.connecting,
      'disconnecting' => VpnStatus.disconnecting,
      'error'         => VpnStatus.error,
      _               => VpnStatus.disconnected,
    };
  }
}

class VpnException implements Exception {
  final String message;
  const VpnException(this.message);

  @override
  String toString() => 'VpnException: $message';
}
