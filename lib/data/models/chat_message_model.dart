class ChatMessage {
  final int id;
  final int senderId;
  final String message;
  final String? senderName;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.message,
    this.senderName,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['sender_id'],
      message: json['message'],
      senderName: json['sender']?['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
