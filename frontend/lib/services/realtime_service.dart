import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:centria/services/api_service.dart';
import 'package:centria/services/auth_state.dart';

class RealtimeService {
  static final RealtimeService instance = RealtimeService._internal();
  RealtimeService._internal();

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  String? _currentCompanyId;

  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);
  String? neonRealtimeUrl;
  String? neonRealtimeToken;

  // Broadcast stream controllers
  final StreamController<Map<String, dynamic>> _tasksController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _approvalsController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _notificationsController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _dashboardController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _githubController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _allEventsController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get tasksStream => _tasksController.stream;
  Stream<Map<String, dynamic>> get approvalsStream => _approvalsController.stream;
  Stream<Map<String, dynamic>> get notificationsStream => _notificationsController.stream;
  Stream<Map<String, dynamic>> get dashboardStream => _dashboardController.stream;
  Stream<Map<String, dynamic>> get githubStream => _githubController.stream;
  Stream<Map<String, dynamic>> get allEventsStream => _allEventsController.stream;

  /// Connects to the workspace WebSocket channel.
  Future<void> connect() async {
    final auth = AuthState();
    final companyId = auth.companyId;
    if (companyId == null || companyId.isEmpty) {
      debugPrint('[Realtime] No active companyId to connect.');
      return;
    }

    if (isConnected.value && _currentCompanyId == companyId) {
      return; // Already connected to this company
    }

    _currentCompanyId = companyId;
    _disconnectInternal();

    if (_isConnecting) return;
    _isConnecting = true;

    try {
      final token = await ApiService.getToken();
      if (token == null || token.isEmpty) {
        _isConnecting = false;
        return;
      }

      // Fetch Neon Realtime configuration in background
      _fetchNeonConfig();

      final wsUrl = '${ApiService.wsBaseUrl}/ws/workspace/$companyId/?token=$token';
      debugPrint('[Realtime] Connecting to WebSocket: $wsUrl');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(
        (data) => _handleIncomingMessage(data),
        onDone: () {
          debugPrint('[Realtime] WebSocket closed.');
          isConnected.value = false;
          _isConnecting = false;
          _scheduleReconnect();
        },
        onError: (err) {
          debugPrint('[Realtime] WebSocket error: $err');
          isConnected.value = false;
          _isConnecting = false;
          _scheduleReconnect();
        },
        cancelOnError: false,
      );

      _startHeartbeat();
    } catch (e) {
      debugPrint('[Realtime] Exception during connection: $e');
      _isConnecting = false;
      isConnected.value = false;
      _scheduleReconnect();
    }
  }

  Future<void> _fetchNeonConfig() async {
    try {
      final config = await ApiService.getRealtimeConfig();
      if (config != null) {
        neonRealtimeUrl = config['realtime_url'];
        neonRealtimeToken = config['realtime_token'];
        debugPrint('[Realtime] Neon Realtime configured: $neonRealtimeUrl');
      }
    } catch (_) {}
  }

  void _handleIncomingMessage(dynamic raw) {
    try {
      final Map<String, dynamic> msg = jsonDecode(raw.toString());
      final type = msg['type'];

      if (type == 'connection_established') {
        isConnected.value = true;
        _isConnecting = false;
        if (msg['neon_realtime_url'] != null) {
          neonRealtimeUrl = msg['neon_realtime_url'];
        }
        debugPrint('[Realtime] Connected to Centria Workspace & Neon Realtime layer.');
        return;
      }

      if (type == 'pong') {
        return;
      }

      if (type == 'event') {
        final eventName = msg['event'] ?? '';
        final eventData = Map<String, dynamic>.from(msg['data'] ?? {});
        final fullPacket = {'event': eventName, 'data': eventData, 'timestamp': msg['timestamp']};

        _allEventsController.add(fullPacket);

        switch (eventName) {
          case 'task_created':
          case 'task_updated':
          case 'task_comment_created':
          case 'project_updated':
            _tasksController.add(fullPacket);
            break;
          case 'approval_created':
          case 'approval_updated':
            _approvalsController.add(fullPacket);
            break;
          case 'notification':
            _notificationsController.add(fullPacket);
            break;
          case 'dashboard_activity':
            _dashboardController.add(fullPacket);
            break;
          case 'github_sync':
            _githubController.add(fullPacket);
            break;
        }
      }
    } catch (e) {
      debugPrint('[Realtime] Parse error: $e for raw: $raw');
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (isConnected.value && _channel != null) {
        try {
          _channel!.sink.add(jsonEncode({'action': 'ping'}));
        } catch (_) {}
      }
    });
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 4), () {
      if (!isConnected.value && AuthState().isAuthenticated) {
        connect();
      }
    });
  }

  void _disconnectInternal() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    isConnected.value = false;
    _isConnecting = false;
  }

  void disconnect() {
    _disconnectInternal();
    _currentCompanyId = null;
  }

  /// Streams Gemini Assistant token responses in real-time.
  Stream<String> streamAiAssistant({
    required String prompt,
    String contextType = 'general',
    String? contextId,
    String? conversationId,
    Function(Map<String, dynamic> metadata)? onComplete,
  }) {
    final controller = StreamController<String>();

    () async {
      final token = await ApiService.getToken();
      if (token == null) {
        controller.addError('Authentication token missing.');
        controller.close();
        return;
      }

      final aiWsUrl = '${ApiService.wsBaseUrl}/ws/ai/stream/?token=$token';
      WebSocketChannel? aiChannel;

      try {
        aiChannel = WebSocketChannel.connect(Uri.parse(aiWsUrl));

        final sub = aiChannel.stream.listen(
          (raw) {
            try {
              final Map<String, dynamic> data = jsonDecode(raw.toString());
              final type = data['type'];

              if (type == 'ai_stream_ready') {
                // Send query payload
                aiChannel?.sink.add(jsonEncode({
                  'prompt': prompt,
                  'context_type': contextType,
                  'context_id': contextId ?? '',
                  'conversation_id': conversationId ?? '',
                }));
              } else if (type == 'token') {
                final chunk = data['chunk'] as String? ?? '';
                if (chunk.isNotEmpty) {
                  controller.add(chunk);
                }
              } else if (type == 'stream_done') {
                if (onComplete != null) {
                  onComplete(data);
                }
                controller.close();
                aiChannel?.sink.close();
              } else if (type == 'error') {
                controller.addError(data['message'] ?? 'AI generation failed');
                controller.close();
                aiChannel?.sink.close();
              }
            } catch (err) {
              controller.addError('Malformed stream chunk: $err');
              controller.close();
              aiChannel?.sink.close();
            }
          },
          onError: (err) {
            controller.addError(err);
            controller.close();
          },
          onDone: () {
            if (!controller.isClosed) {
              controller.close();
            }
          },
        );

        controller.onCancel = () {
          sub.cancel();
          aiChannel?.sink.close();
        };
      } catch (e) {
        controller.addError('AI WebSocket connection error: $e');
        controller.close();
      }
    }();

    return controller.stream;
  }
}
