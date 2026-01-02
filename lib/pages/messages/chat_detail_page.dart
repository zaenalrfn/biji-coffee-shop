import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/chat_model.dart'; // Use the new model
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

  List<ChatModel> _messages = [];
  bool _isLoading = true;
  int? _currentUserId;
  int? _orderId;
  String? _userName;
  String? _userAvatar;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    
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
      _currentUserId = user.id;
    } catch (e) {
      print("Error getting user: $e");
    }

    // 2. Get Auth Token
    final token = await _authService.getToken();
    if (token == null) {
      // Handle unauthorized (e.g., logout)
      return;
    }

    // 3. Initialize Pusher
    await _chatService.initPusher(token);

    // 4. Fetch Initial Messages
    await _fetchMessages(token);

    // 5. Subscribe to Realtime Events
    _chatService.listenToOrderChat(_orderId!, (newMessage) {
      if (mounted) {
        // Fix isSender dynamically
        final processedMessage = newMessage.checkIsSender(_currentUserId ?? 0);
        
        // Don't add if I sent it (assumes optimistic update works)
        if (!processedMessage.isSender) {
           setState(() {
             _messages.add(processedMessage);
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
          _messages = msgs.map((m) {
             // Update isSender status based on our current user ID
             return m.checkIsSender(_currentUserId ?? 0);
          }).toList();
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint("Gagal ambil chat: $e");
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || _orderId == null) return;
    String text = _controller.text;
    _controller.clear();

    // Optimistic Update
    setState(() {
      _messages.add(ChatModel(
        id: DateTime.now().millisecondsSinceEpoch, // Temp ID (positive to avoid 0)
        orderId: _orderId!,
        message: text,
        senderName: "Me",
        senderId: _currentUserId ?? 0,
        createdAt: DateTime.now(),
        isSender: true,
      ));
    });
    _scrollToBottom();

    final token = await _authService.getToken();
    if (token != null) {
      await _chatService.sendMessage(_orderId!, text, token);
      // Ideally replace optimistic message with real one, but list refresh is okay too
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
                      // Fix isSender check dynamically if needed:
                      // bool isMe = message.senderId == _currentUserId; 
                      // (If we had senderId)
                      
                      String timeString = DateFormat('HH:mm').format(message.createdAt);
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
            backgroundImage: _userAvatar != null && _userAvatar!.startsWith('http')
              ? NetworkImage(_userAvatar!)
              : AssetImage(_userAvatar ?? 'assets/images/profile1.jpg') as ImageProvider,
          ),
          const SizedBox(width: 12),
          Text(_userName ?? "Chat", style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatModel message, String timeString) {
    // Check local isSender (from optimistic) OR try to deduce
    // Since we lost senderId in ChatModel, this is tricky. 
    // We will assume simpler logic: if name is "Me", it is sender.
    // Or we fix ChatModel in next step.
    
    final bool isMe = message.isSender; 
    
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isMe ? const Color(0xFF4B3B47) : const Color(0xFFFDEFE7);
    final textColor = isMe ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
          child: Text(message.message, style: TextStyle(color: textColor, fontSize: 15)),
        ),
        Text(timeString, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
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
