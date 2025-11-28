import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/door_service.dart';
import '../services/video_service.dart';
import 'video_stream_screen.dart';
import 'login_screen.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final DoorService _doorService = DoorService();
  final VideoService _videoService = VideoService();
  bool _isOpeningDoor = false;
  List<Map<String, dynamic>> _doorLogs = [];

  @override
  void initState() {
    super.initState();
    _loadDoorLogs();
  }

  Future<void> _loadDoorLogs() async {
    final client = GraphQLProvider.of(context).value;
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (authService.userId != null) {
      final logs = await _doorService.getDoorLogs(client, authService.userId!);
      setState(() {
        _doorLogs = logs;
      });
    }
  }

  Future<void> _handleOpenDoor() async {
    setState(() {
      _isOpeningDoor = true;
    });

    final client = GraphQLProvider.of(context).value;
    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка: пользователь не авторизован'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isOpeningDoor = false;
      });
      return;
    }

    final result = await _doorService.openDoor(client, authService.userId!);

    setState(() {
      _isOpeningDoor = false;
    });

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(result['message']),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
      _loadDoorLogs(); // Refresh logs
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final cameras = _videoService.getAvailableCameras();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDoorLogs,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Info Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Квартира ${authService.apartmentNumber ?? "N/A"}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  authService.phone ?? '',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Door Control Section
              Text(
                'Управление дверью',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Open Door Button
              Card(
                elevation: 4,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: InkWell(
                  onTap: _isOpeningDoor ? null : _handleOpenDoor,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.door_front_door_rounded,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        _isOpeningDoor
                            ? const CircularProgressIndicator()
                            : Text(
                                'ОТКРЫТЬ ДВЕРЬ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Cameras Section
              Text(
                'Видеонаблюдение',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              ...cameras.map((camera) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.videocam, size: 32),
                  title: Text(camera['name']!),
                  subtitle: Text(camera['location']!),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoStreamScreen(
                          streamUrl: camera['url']!,
                          cameraName: camera['name']!,
                        ),
                      ),
                    );
                  },
                ),
              )),
              
              const SizedBox(height: 24),
              
              // Door Logs Section
              Text(
                'История действий',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              if (_doorLogs.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'История пуста',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                )
              else
                ..._doorLogs.take(5).map((log) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(log['action'] ?? 'Неизвестное действие'),
                    subtitle: Text(log['timestamp'] ?? ''),
                    dense: true,
                  ),
                )),
            ],
          ),
        ),
      ),
    );
  }
}
