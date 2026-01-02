import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:laravel_echo/laravel_echo.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../models/chat_model.dart';
import '../../core/constants/api_constants.dart';

class ChatService {
  // Singleton pattern
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  late PusherChannelsFlutter pusher;
  late Echo echo;
  final Dio _dio = Dio();

  // Ambil Config dari ApiConstants
  final String _host = ApiConstants.serverIp; 
  final int _port = 8080; 
  final String _appKey = 'biji_coffee_key_anda'; 
  String get _baseUrl => ApiConstants.baseUrl; 

  bool _isInitialized = false;

  /// Inisialisasi Pusher/Echo untuk Realtime
  Future<void> initPusher(String authToken) async {
    if (_isInitialized) return;

    pusher = PusherChannelsFlutter.getInstance();
    
    try {
      await pusher.init(
        apiKey: _appKey,
        cluster: 'mt1',
        useTLS: false,
        wsHost: _host,
        wsPort: _port,
        wssPort: _port,
        forceTLS: false,
        // Penting: Authorizer untuk Private Channel
        onAuthorizer: (String channelName, String socketId, dynamic options) async {
          try {
            final response = await _dio.post(
              '$_baseUrl/broadcasting/auth',
              data: {
                'socket_id': socketId,
                'channel_name': channelName,
              },
              options: Options(
                headers: {
                  'Authorization': 'Bearer $authToken',
                  'Accept': 'application/json',
                },
              ),
            );
            return jsonEncode(response.data);
          } catch (e) {
            print("Auth Error: $e");
            return null;
          }
        },
      );

      echo = Echo(
        broadcaster: EchoBroadcasterType.Pusher,
        client: pusher,
      );

      await pusher.connect();
      _isInitialized = true;
      print("ChatService: Pusher Connected to $_host:$_port");
    } catch (e) {
      print("ChatService Error: $e");
    }
  }

  /// Subscribe ke channel order tertentu
  void listenToOrderChat(int orderId, Function(ChatModel) onMessageReceived) {
    if (!_isInitialized) {
      print("ChatService belum di-init!");
      return;
    }

    echo.private('order.chat.$orderId').listen('MessageSent', (e) {
      print("New Event: $e");
      if (e['message'] != null) {
        // Mapping data dari event ke Model
        final newMessage = ChatModel.fromJson(e['message']);
        onMessageReceived(newMessage);
      }
    });
  }

  /// Unsubscribe
  void leaveChat(int orderId) {
    if (_isInitialized) {
      echo.leave('order.chat.$orderId');
    }
  }

  /// Ambil history chat dari API
  Future<List<ChatModel>> getMessages(int orderId, String token) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/orders/$orderId/messages',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      final List data = response.data;
      // TODO: Pass currentUserId jika ada logic isSender
      return data.map((json) => ChatModel.fromJson(json)).toList();
    } catch (e) {
      print("Get Messages Error: $e");
      return [];
    }
  }

  /// Kirim pesan baru
  Future<bool> sendMessage(int orderId, String message, String token) async {
    try {
      await _dio.post(
        '$_baseUrl/orders/$orderId/messages',
        data: {'message': message},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      return true;
    } catch (e) {
      print("Send Message Error: $e");
      return false;
    }
  }
}
