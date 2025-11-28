import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import '../services/video_service.dart';

class VideoStreamScreen extends StatefulWidget {
  final String streamUrl;
  final String cameraName;

  const VideoStreamScreen({
    super.key,
    required this.streamUrl,
    this.cameraName = 'Камера',
  });

  @override
  State<VideoStreamScreen> createState() => _VideoStreamScreenState();
}

class _VideoStreamScreenState extends State<VideoStreamScreen> {
  late VlcPlayerController _videoPlayerController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VlcPlayerController.network(
        widget.streamUrl,
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.networkCaching(2000),
          ]),
          rtp: VlcRtpOptions([
            '--rtsp-tcp',
          ]),
        ),
      );

      await _videoPlayerController.initialize();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Ошибка подключения: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cameraName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
              _initializePlayer();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Video Player
          Expanded(
            child: Container(
              color: Colors.black,
              child: Center(
                child: _isLoading
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Подключение к камере...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )
                    : _hasError
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  _errorMessage,
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _isLoading = true;
                                    _hasError = false;
                                  });
                                  _initializePlayer();
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Повторить'),
                              ),
                            ],
                          )
                        : VlcPlayer(
                            controller: _videoPlayerController,
                            aspectRatio: 16 / 9,
                            placeholder: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
              ),
            ),
          ),
          
          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Play/Pause Button
                IconButton(
                  icon: Icon(
                    _videoPlayerController.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 48,
                  ),
                  onPressed: _hasError
                      ? null
                      : () {
                          if (_videoPlayerController.value.isPlaying) {
                            _videoPlayerController.pause();
                          } else {
                            _videoPlayerController.play();
                          }
                          setState(() {});
                        },
                ),
                
                // Stop Button
                IconButton(
                  icon: const Icon(Icons.stop_circle, size: 48),
                  onPressed: _hasError
                      ? null
                      : () {
                          _videoPlayerController.stop();
                          setState(() {});
                        },
                ),
                
                // Volume Control
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 48),
                  onPressed: () {
                    // Volume control can be added here
                  },
                ),
              ],
            ),
          ),
          
          // Stream Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'URL потока:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.streamUrl,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
