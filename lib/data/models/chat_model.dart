class ChatModel {
  final int id;
  final int orderId;
  final String message;
  final String senderName;
  final int senderId; // Added senderId
  final String? senderAvatar;
  final DateTime createdAt;
  final bool isSender; // Helper to check if it's 'my' message

  ChatModel({
    required this.id,
    required this.orderId,
    required this.message,
    required this.senderName,
    required this.senderId,
    this.senderAvatar,
    required this.createdAt,
    this.isSender = false,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json, {int? currentUserId}) {
    // Check if the message sender is the current user
    bool isMe = false;
    if (currentUserId != null && json['sender_id'] != null) {
      isMe = json['sender_id'] == currentUserId;
    }

    return ChatModel(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      message: json['message'] ?? '',
      senderName: json['sender']?['name'] ?? 'Unknown',
      senderId: json['sender_id'] ?? 0, // Capture sender_id
      senderAvatar: json['sender']?['profile_photo_url'], 
      createdAt: DateTime.parse(json['created_at']),
      isSender: isMe,
    );
  }

  // Helper helper to update isSender if we didn't have currentUserId before
  ChatModel checkIsSender(int currentUserId) {
    return ChatModel(
      id: id,
      orderId: orderId,
      message: message,
      senderName: senderName,
      senderId: senderId,
      senderAvatar: senderAvatar,
      createdAt: createdAt,
      isSender: senderId == currentUserId,
    );
  }
}
