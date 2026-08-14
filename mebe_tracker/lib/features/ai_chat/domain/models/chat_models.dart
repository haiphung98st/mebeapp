import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_models.freezed.dart';
part 'chat_models.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String role,
    required String content,
    required DateTime timestamp,
  }) = _ChatMessage;

  const ChatMessage._();

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

  factory ChatMessage.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return ChatMessage.fromJson({
      ...data,
      'id': doc.id,
      'timestamp': (data['timestamp'] as Timestamp?)?.toDate().toIso8601String() ??
          DateTime.now().toIso8601String(),
    });
  }
}

class ChatConversation {
  const ChatConversation({
    required this.id,
    this.lastMessage,
    this.lastReply,
    required this.updatedAt,
    this.messageCount = 0,
  });

  final String id;
  final String? lastMessage;
  final String? lastReply;
  final DateTime updatedAt;
  final int messageCount;

  factory ChatConversation.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return ChatConversation(
      id: doc.id,
      lastMessage: data['lastMessage'] as String?,
      lastReply: data['lastReply'] as String?,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      messageCount: (data['messageCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class ChatState {
  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.currentConversationId,
    this.errorMessage,
    this.streamingText = '',
  });

  final List<ChatMessage> messages;
  final bool isLoading;
  final String? currentConversationId;
  final String? errorMessage;
  final String streamingText;

  bool get isStreaming => streamingText.isNotEmpty;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? currentConversationId,
    String? errorMessage,
    String? streamingText,
    bool clearError = false,
    bool clearStreamingText = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      currentConversationId: currentConversationId ?? this.currentConversationId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      streamingText: clearStreamingText ? '' : (streamingText ?? this.streamingText),
    );
  }
}
