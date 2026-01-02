class ChatOrder {
  final int orderId;
  final String name;
  final String? avatar;
  final String lastMessage;
  final String time;

  ChatOrder({
    required this.orderId,
    required this.name,
    this.avatar,
    required this.lastMessage,
    required this.time,
  });

  factory ChatOrder.fromJson(Map<String, dynamic> json) {
    return ChatOrder(
      orderId: json['order_id'],
      name: json['name'],
      avatar: json['avatar'],
      lastMessage: json['last_message'],
      time: json['time'],
    );
  }
}
