import 'package:flutter/foundation.dart';
import '../services/vpn_service.dart';

class VpnProvider extends ChangeNotifier {
  final VpnService _service = VpnService();

  VpnStatus _status = VpnStatus.disconnected;
  String? _errorMessage;
  Duration _sessionDuration = Duration.zero;
  DateTime? _connectedAt;

  VpnStatus get status => _status;
  String? get errorMessage => _errorMessage;
  Duration get sessionDuration => _sessionDuration;
  bool get isConnected => _status == VpnStatus.connected;

  String get statusLabel => switch (_status) {
        VpnStatus.connected     => 'Connected',
        VpnStatus.connecting    => 'Connecting...',
        VpnStatus.disconnecting => 'Disconnecting...',
        VpnStatus.error         => 'Error',
        _                       => 'Disconnected',
      };

  VpnProvider() {
    _init();
  }

  Future<void> _init() async {
    _status = await _service.getCurrentStatus();
    notifyListeners();

    _service.statusStream.listen((newStatus) {
      _status = newStatus;
      _errorMessage = null;

      if (newStatus == VpnStatus.connected) {
        _connectedAt = DateTime.now();
        _startSessionTimer();
      } else {
        _connectedAt = null;
        _sessionDuration = Duration.zero;
      }

      notifyListeners();
    }, onError: (e) {
      _status = VpnStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    });
  }

  Future<void> toggleConnection() async {
    try {
      if (_status == VpnStatus.connected || _status == VpnStatus.connecting) {
        await _service.disconnect();
      } else {
        const exampleConfig = '{"log":{"level":"info"},"inbounds":[],"outbounds":[]}';
        await _service.connect(configJson: exampleConfig);
      }
    } on VpnException catch (e) {
      _errorMessage = e.message;
      _status = VpnStatus.error;
      notifyListeners();
    }
  }

  void _startSessionTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_status != VpnStatus.connected || _connectedAt == null) return false;
      _sessionDuration = DateTime.now().difference(_connectedAt!);
      notifyListeners();
      return true;
    });
  }

  String get sessionDurationFormatted {
    final h = _sessionDuration.inHours.toString().padLeft(2, '0');
    final m = (_sessionDuration.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_sessionDuration.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
