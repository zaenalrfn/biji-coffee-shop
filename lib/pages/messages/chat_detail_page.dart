import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/chat_message_model.dart'; // Use the new model
import '../../data/services/chat_service.dart'; // Use the new service
import '../../data/services/auth_service.dart';
import '../../data/services/api_service.dart'; // Keep for getUser

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({super.key});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  int? _currentUserId;
  int? _orderId;
  String? _userName;
  String? _userAvatar;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve arguments
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Prevent re-initialization if arguments are the same (e.g. keyboard open/close)
    if (_orderId == args['orderId']) return;

    _orderId = args['orderId'];
    _userName = args['name'];
    _userAvatar = args['avatar'] ?? 'assets/images/profile1.jpg';

    if (_orderId != null) {
      _initChat();
    }
  }

  Future<void> _initChat() async {
    // 1. Get Current User ID
    try {
      final user = await _apiService.getUser();
      if (mounted) {
        setState(() {
          _currentUserId = user.id;
        });
        print("🔑 Current User ID: $_currentUserId");
        print("🔑 User Name: ${user.name}");
      }
    } catch (e) {
      print("Error getting user: $e");
    }

    // 2. Get Auth Token
    final token = await _authService.getToken();
    if (token == null) {
      // Handle unauthorized (e.g., logout)
      return;
    }

    // 2.5. Verify Order Access (DEBUGGING)
    try {
      final order = await _apiService.getOrderById(_orderId!);
      print("📦 ===== ORDER VERIFICATION =====");
      print("📦 Order ID: ${order.id}");
      print("📦 Order User ID: ${order.user?.id}");
      print("📦 Order Driver ID: ${order.driverId}");
      if (order.driver != null) {
        print("📦 Driver Name: ${order.driver!.name}");
        print("📦 Driver User ID: ${order.driver!.userId}");
      } else {
        print("⚠️  Driver belum di-assign!");
      }
      print("📦 Order Status: ${order.status}");
      print("📦 ================================");

      // Validasi akses
      if (order.user?.id != _currentUserId &&
          (order.driver == null || order.driver!.userId != _currentUserId)) {
        print("⛔ UNAUTHORIZED: User bukan customer dan bukan driver");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Anda tidak memiliki akses ke chat ini'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
        return;
      }

      // Cek driver assignment
      if (order.driverId == null) {
        print("⚠️  Chat belum tersedia - driver belum assigned");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chat belum tersedia. Driver sedang dicari.'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.pop(context);
        }
        return;
      }
    } catch (e) {
      print("❌ Failed to verify order: $e");
    }

    // 3. Initialize Pusher
    await _chatService.initPusher(token);

    // 4. Fetch Initial Messages
    await _fetchMessages(token);

    // 5. Subscribe to Realtime Events
    _chatService.listenToOrderChat(_orderId!, (newMessage) {
      if (mounted) {
        // Only add if I am NOT the sender (to avoid duplicate from optimistic update, though safer to allow duplicate here for simplicity if optimistic is complex)
        // Check if message already exists by ID to be safe
        bool exists = _messages.any((m) => m.id == newMessage.id);
        if (!exists) {
          setState(() {
            _messages.add(newMessage);
          });
          _scrollToBottom();
        }
      }
    });
  }

  Future<void> _fetchMessages(String token) async {
    try {
      final msgs = await _chatService.getMessages(_orderId!, token);
      if (mounted) {
        setState(() {
          _messages = msgs;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint("Gagal ambil chat: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty ||
        _orderId == null ||
        _currentUserId == null) return;
    String text = _controller.text;
    _controller.clear();

    // Optimistic Update
    final tempMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      senderId: _currentUserId!,
      message: text,
      senderName: "Me",
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(tempMsg);
    });
    _scrollToBottom();

    final token = await _authService.getToken();
    if (token != null) {
      try {
        print("📤 Sending message to order $_orderId: $text");
        final sentMsg = await _apiService.sendChatMessage(_orderId!, text);

        // Replace optimistic message with real message from server
        setState(() {
          final index = _messages.indexOf(tempMsg);
          if (index != -1) {
            _messages[index] = sentMsg;
          }
        });

        print("✅ Message sent successfully: ${sentMsg.id}");
      } catch (e) {
        print("❌ Send failed: $e");

        // Enhanced error logging
        final errorStr = e.toString();
        print("📥 Error String: $errorStr");
        if (errorStr.contains('403')) {
          print("⛔ 403 FORBIDDEN - Kemungkinan:");
          print("   1. User ID tidak match dengan order.user_id");
          print("   2. User ID tidak match dengan order.driver.user_id");
          print("   3. Driver belum di-assign");
        }

        // Revert optimistic update
        setState(() {
          _messages.remove(tempMsg);
        });

        // Show error to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getErrorMessage(e)),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Tutup',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } else {
      // No token - revert and show error
      setState(() {
        _messages.remove(tempMsg);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi Anda telah berakhir, silakan login kembali'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString();

    if (errorStr.contains('403') || errorStr.contains('Unauthorized')) {
      return 'Anda tidak memiliki akses ke chat ini';
    } else if (errorStr.contains('400') ||
        errorStr.contains('driver belum di-assign')) {
      return 'Chat belum tersedia (driver belum di-assign)';
    } else if (errorStr.contains('404')) {
      return 'Order tidak ditemukan';
    } else if (errorStr.contains('401')) {
      return 'Sesi Anda telah berakhir, silakan login kembali';
    } else if (errorStr.contains('500')) {
      return 'Terjadi kesalahan di server, coba lagi nanti';
    } else if (errorStr.contains('SocketException') ||
        errorStr.contains('NetworkException')) {
      return 'Tidak ada koneksi internet';
    }

    return 'Gagal mengirim pesan, coba lagi';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    if (_orderId != null) {
      _chatService.leaveChat(_orderId!);
    }
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      String timeString =
                          DateFormat('HH:mm').format(message.createdAt);
                      return _buildMessageBubble(message, timeString);
                    },
                  ),
                ),
                _buildChatInput(),
              ],
            ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage:
                _userAvatar != null && _userAvatar!.startsWith('http')
                    ? NetworkImage(_userAvatar!)
                    : AssetImage(_userAvatar ?? 'assets/images/profile1.jpg')
                        as ImageProvider,
          ),
          const SizedBox(width: 12),
          Text(_userName ?? "Chat",
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, String timeString) {
    final bool isMe = message.senderId == _currentUserId;

    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isMe ? const Color(0xFF4B3B47) : const Color(0xFFFDEFE7);
    final textColor = isMe ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(12)),
          child: Text(message.message,
              style: TextStyle(color: textColor, fontSize: 15)),
        ),
        Text(timeString,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Tulis pesan...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.send, color: Color(0xFF4B3B47)),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
