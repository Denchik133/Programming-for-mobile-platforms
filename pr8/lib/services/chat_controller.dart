
import 'dart:async';

import '../models/message.dart';
import 'chat_service.dart';

class ChatController {
  ChatController(this._service);

  final ChatService _service;

  final StreamController<ChatMessage> _messageController =
      StreamController<ChatMessage>.broadcast();

  final StreamController<List<ChatMessage>> _messagesListController =
      StreamController<List<ChatMessage>>.broadcast();

  Stream<List<ChatMessage>> get messagesListStream =>
      _messagesListController.stream;

  void _publishMessages() {
    if (!_messagesListController.isClosed) {
      _messagesListController.add(
        List.unmodifiable(_messages.values),
      );
    }
  }

  final Map<String, ChatMessage> _messages = {};

  final StreamController<bool> _typingController =
      StreamController<bool>.broadcast();

  Stream<bool> get typingStream => _typingController.stream;

  Stream<ChatMessage> get messageStream =>
      _messageController.stream;

  List<ChatMessage> get messages =>
      List.unmodifiable(_messages.values);

  bool get isClosed => _messageController.isClosed;

  void addInitialMessages(List<ChatMessage> messages) {
    for (final message in messages) {
      _messages[message.id] = message;
    }
    _publishMessages();
  }

  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty || isClosed) {
      return;
    }

    final id = DateTime.now().microsecondsSinceEpoch.toString();

    final message = ChatMessage(
      id: id,
      text: trimmedText,
      isFromOperator: false,
      sentAt: DateTime.now(),
      status: MessageStatus.sending,
    );

    _messages[id] = message;
    _messageController.add(message);
    _publishMessages();

    try {
      await _service.sendMessage(trimmedText);

      if (isClosed) return;

      final delivered = message.copyWith(
        status: MessageStatus.delivered,
      );

      _messages[id] = delivered;
      _messageController.add(delivered);

      _receiveOperatorReply(trimmedText);
    } catch (error) {
      if (isClosed) return;

      final failed = message.copyWith(
        status: MessageStatus.failed,
      );

      _messages[id] = failed;
      _messageController.add(failed);
    }
  }

  Future<void> retryMessage(String id) async {
    final message = _messages[id];

    if (message == null ||
        message.status != MessageStatus.failed ||
        isClosed) {
      return;
    }

    final sending = message.copyWith(
      status: MessageStatus.sending,
    );

    _messages[id] = sending;
    _messageController.add(sending);

    try {
      await _service.sendMessage(message.text);

      if (isClosed) return;

      final delivered = sending.copyWith(
        status: MessageStatus.delivered,
      );

      _messages[id] = delivered;
      _messageController.add(delivered);

      _receiveOperatorReply(message.text);
    } catch (error) {
      if (isClosed) return;

      final failed = sending.copyWith(
        status: MessageStatus.failed,
      );

      _messages[id] = failed;
      _messageController.add(failed);
    }
  }
  
  Future<void> _receiveOperatorReply(String text) async {
    if (isClosed) return;

    _typingController.add(true);

    try {
      final reply = await _service.generateReply(text);

      if (isClosed) return;

      final message = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: reply,
        isFromOperator: true,
        sentAt: DateTime.now(),
      );

      _messages[message.id] = message;
      _messageController.add(message);
      _publishMessages();
    } catch (error) {
      // Помилка відповіді оператора не завершує роботу чату.
    } finally {
      if (!isClosed && !_typingController.isClosed) {
        _typingController.add(false);
      }
    }
  }


  Future<void> dispose() async {
    await _messageController.close();
    await _typingController.close();
    await _messagesListController.close();
  }
}
