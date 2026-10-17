
enum MessageStatus {
  sending,
  delivered,
  failed,
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.isFromOperator,
    required this.sentAt,
    this.status = MessageStatus.delivered,
  });

  final String id;
  final String text;
  final bool isFromOperator;
  final DateTime sentAt;
  final MessageStatus status;

  ChatMessage copyWith({
    String? text,
    bool? isFromOperator,
    DateTime? sentAt,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id,
      text: text ?? this.text,
      isFromOperator: isFromOperator ?? this.isFromOperator,
      sentAt: sentAt ?? this.sentAt,
      status: status ?? this.status,
    );
  }
}
