import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/auth_provider.dart';
import '../domain/models/chat_models.dart';
import 'chat_service.dart';

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._service, this._userId) : super(const ChatState());

  final ChatService _service;
  final String _userId;
  StreamSubscription<List<ChatMessage>>? _messagesSub;

  @override
  void dispose() {
    _messagesSub?.cancel();
    super.dispose();
  }

  void startNewConversation() {
    _messagesSub?.cancel();
    _messagesSub = null;
    state = const ChatState();
  }

  void loadConversation(String conversationId) {
    if (state.currentConversationId == conversationId) return;
    _messagesSub?.cancel();
    state = state.copyWith(currentConversationId: conversationId);
    _listenToMessages(conversationId);
  }

  void _listenToMessages(String conversationId) {
    _messagesSub?.cancel();
    _messagesSub = _service.watchMessages(_userId, conversationId).listen((messages) {
      if (!state.isStreaming) {
        state = state.copyWith(messages: messages);
      }
    });
  }

  Future<void> sendMessage(String message) async {
    if (state.isLoading || state.isStreaming || message.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: message.trim(),
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      clearError: true,
    );

    try {
      final result = await _service.sendMessage(
        userId: _userId,
        message: message.trim(),
        conversationId: state.currentConversationId,
      );

      final convId = result.conversationId;
      if (state.currentConversationId == null) {
        state = state.copyWith(currentConversationId: convId);
        _listenToMessages(convId);
      }

      state = state.copyWith(isLoading: false);
      await _simulateStreaming(result.reply);
    } on AiChatException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.code,
        clearStreamingText: true,
      );
    }
  }

  Future<void> _simulateStreaming(String fullText) async {
    state = state.copyWith(streamingText: '');
    final buffer = StringBuffer();
    const chunkSize = 3;
    for (var i = 0; i < fullText.length; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, fullText.length);
      buffer.write(fullText.substring(i, end));
      state = state.copyWith(streamingText: buffer.toString());
      await Future.delayed(const Duration(milliseconds: 20));
      if (!mounted) return;
    }
    final aiMsg = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_ai',
      role: 'assistant',
      content: fullText,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      clearStreamingText: true,
    );
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final chatProvider =
    StateNotifierProvider.autoDispose<ChatNotifier, ChatState>((ref) {
  final userId = ref.watch(currentUserProvider)?.uid ?? '';
  return ChatNotifier(ref.read(chatServiceProvider), userId);
});
