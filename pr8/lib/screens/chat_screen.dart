
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/message.dart';
import '../models/operator.dart';
import '../services/chat_controller.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatService _service;
  late final ChatController _controller;
  late Future<List<Object>> _initialLoad;

  final TextEditingController _textController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  StreamSubscription<ChatMessage>? _listSubscription;
  StreamSubscription<ChatMessage>? _unreadSubscription;
  StreamSubscription<bool>? _typingSubscription;

  final List<ChatMessage> _visibleMessages = [];

  SupportOperator? _operator;
  bool _isTyping = false;
  bool _isLoading = true;
  String? _loadError;
  int _unreadCount = 1;

  @override
  void initState() {
    super.initState();

    _service = ChatService(failureRate: 0.2);
    _controller = ChatController(_service);

    // Два слухачі одного broadcast-потоку:
    // перший оновлює список, другий — лічильник.
    _listSubscription = _controller.messageStream.listen((message) {
      if (!mounted) return;

      setState(() {
        final index = _visibleMessages.indexWhere(
          (item) => item.id == message.id,
        );

        if (index == -1) {
          _visibleMessages.add(message);
        } else {
          _visibleMessages[index] = message;
        }

        if (message.isFromOperator) {
          _isTyping = false;
        }
      });

      _scrollToBottom();
    });

    _unreadSubscription =
    _controller.messageStream.listen((message) {
      if (!mounted || !message.isFromOperator) return;
      setState(() {
        _unreadCount++;
      });
    });

    _typingSubscription = _controller.typingStream.listen((isTyping) {
      if (!mounted) return;

      setState(() {
        _isTyping = isTyping;
      });
    });

    _initialLoad = _loadInitialData();
  }

  Future<List<Object>> _loadInitialData() async {
    try {
      final results = await Future.wait<Object>([
        _service.loadMessages(),
        _service.loadOperator(),
      ]).timeout(const Duration(seconds: 5));

      if (!mounted) return results;

      final messages = results[0] as List<ChatMessage>;
      _operator = results[1] as SupportOperator;

      _controller.addInitialMessages(messages);

      setState(() {
        _visibleMessages
          ..clear()
          ..addAll(messages);
        _isLoading = false;
        _loadError = null;
      });

      return results;
    } on Exception catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = error.toString();
        });
      }

      rethrow;
    }
  }

  Future<void> _retryLoading() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    final future = _loadInitialData();

    setState(() {
      _initialLoad = future;
    });

    try {
      await future;
    } on Exception {
      // Помилка вже відображається через _loadError.
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();

    if (text.isEmpty) return;

    _textController.clear();

    try {
      await _controller.sendMessage(text);
    } on Exception {
      if (!mounted) return;

      setState(() {
        _isTyping = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _listSubscription?.cancel();
    _unreadSubscription?.cancel();
    _typingSubscription?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_operator?.name ?? 'Чат підтримки'),
            Text(
              _operator?.isOnline == true
                  ? 'Онлайн'
                  : 'Фахівець підтримки',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Badge(
                label: Text('$_unreadCount'),
                isLabelVisible: _unreadCount > 0,
                child: const Icon(Icons.mark_chat_unread_outlined),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Object>>(
        future: _initialLoad,
        builder: (context, snapshot) {
          if (_isLoading && !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_loadError != null && _visibleMessages.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Не вдалося завантажити чат.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _retryLoading,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Повторити'),
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: StreamBuilder<List<ChatMessage>>(
                  stream: _controller.messagesListStream,
                  initialData: _controller.messages,
                  builder: (context, snapshot) {
                    final messages = snapshot.data ?? [];

                    if (messages.isEmpty) {
                      return const Center(
                        child: Text(
                          'Історія порожня. Напишіть перше повідомлення!',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessage(messages[index]);
                      },
                    );
                  },
                ),
              ),
              if (_isTyping)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Оператор набирає повідомлення…',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              _buildComposer(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isOperator = message.isFromOperator;

    return Align(
      alignment:
          isOperator ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isOperator
              ? Colors.grey.shade200
              : Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.text),
            const SizedBox(height: 4),
            if (!isOperator)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    switch (message.status) {
                      MessageStatus.sending => 'Надсилання…',
                      MessageStatus.delivered => 'Доставлено',
                      MessageStatus.failed => 'Не доставлено',
                    },
                    style: const TextStyle(fontSize: 11),
                  ),
                  if (message.status == MessageStatus.failed)
                    TextButton(
                      onPressed: () =>
                          _controller.retryMessage(message.id),
                      child: const Text('Повторити'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Введіть повідомлення…',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send),
              tooltip: 'Надіслати',
            ),
          ],
        ),
      ),
    );
  }
}
