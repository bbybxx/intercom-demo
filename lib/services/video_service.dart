import 'package:flutter/foundation.dart';

class VideoService extends ChangeNotifier {
  // Test RTSP streams (publicly available for testing)
  static const String testRtspUrl1 = 'rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mp4';
  static const String testRtspUrl2 = 'rtsp://rtsp.stream/pattern';
  
  // For production, this would be the actual intercom camera URL
  static const String intercomCameraUrl = 'rtsp://192.168.1.100:554/stream1';

  String _currentStreamUrl = testRtspUrl1;
  bool _isPlaying = false;
  bool _isLoading = false;

  String get currentStreamUrl => _currentStreamUrl;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;

  void setStreamUrl(String url) {
    _currentStreamUrl = url;
    notifyListeners();
  }

  void setPlaying(bool playing) {
    _isPlaying = playing;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get list of available cameras
  List<Map<String, String>> getAvailableCameras() {
    return [
      {
        'name': 'Тестовая камера 1',
        'url': testRtspUrl1,
        'location': 'Главный вход',
      },
      {
        'name': 'Тестовая камера 2',
        'url': testRtspUrl2,
        'location': 'Двор',
      },
    ];
  }

  // Simulate camera connection check
  Future<bool> checkCameraConnection(String url) async {
    try {
      // In production, this would actually test the RTSP connection
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      debugPrint('Camera connection error: $e');
      return false;
    }
  }
}
