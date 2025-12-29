import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/message_data.dart'; // Tetap pakai model ChatMessage
import '../../data/services/api_service.dart';
import '../../data/services/auth_service.dart';
import 'dart:async';

class ChatDetailPage extends StatefulWidget {
  // Kita sesuaikan agar bisa menerima argumen dari tracker page
  const ChatDetailPage({super.key});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  Timer? _pollingTimer;
  int? _currentUserId;

  // Data dari halaman sebelumnya
  int? _orderId;
  String? _userName;
  String? _userAvatar;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mengambil data (arguments) yang dikirim dari DeliveryTrackerPage
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _orderId = args['orderId'];
    _userName = args['name'];
    _userAvatar = args['avatar'] ?? 'assets/images/profile1.jpg';

    if (_orderId != null && _messages.isEmpty) {
      _initChat();
    }
  }

  Future<void> _initChat() async {
    // 1. Ambil ID kita sendiri dulu agar tahu mana pesan "kiriman kita" (isSender)
    final user = await _apiService.getUser();
    _currentUserId = user.id;

    // 2. Ambil pesan pertama kali
    await _fetchMessages();

    // 3. Set timer untuk nge-cek pesan baru setiap 3 detik (Polling)
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchMessages();
    });
  }

  Future<void> _fetchMessages() async {
    if (_orderId == null) return;

    try {
      final List<dynamic> data = await _apiService.getChatMessages(_orderId!);
      
      if (mounted) {
        setState(() {
          _messages = data.map((json) {
            return ChatMessage(
              text: json['message'],
              timestamp: DateTime.parse(json['created_at']),
              // Jika sender_id di database sama dengan ID kita, berarti isSender = true
              isSender: json['sender_id'] == _currentUserId,
            );
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Gagal ambil chat: $e");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || _orderId == null) return;

    String text = _controller.text;
    _controller.clear();

    try {
      // Kirim ke API Laravel
      await _apiService.sendChatMessage(_orderId!, text);
      // Refresh list pesan
      await _fetchMessages();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengirim: $e")),
      );
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // Berhenti cek pesan kalau halaman ditutup
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
                      String timeString = DateFormat('HH:mm').format(message.timestamp);
                      return _buildMessageBubble(message, timeString);
                    },
                  ),
                ),
                _buildChatInput(),
              ],
            ),
    );
  }

  // --- UI WIDGETS (Sama dengan desain lama kamu, cuma datanya yang ganti) ---

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
            backgroundImage: AssetImage(_userAvatar ?? 'assets/images/profile1.jpg'),
          ),
          const SizedBox(width: 12),
          Text(_userName ?? "Chat", style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, String timeString) {
    final align = message.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = message.isSender ? const Color(0xFF4B3B47) : const Color(0xFFFDEFE7);
    final textColor = message.isSender ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
          child: Text(message.text, style: TextStyle(color: textColor, fontSize: 15)),
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