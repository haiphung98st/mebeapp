import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/chat_models.dart';

class AiChatException implements Exception {
  const AiChatException(this.code, [this.message]);
  final String code;
  final String? message;

  @override
  String toString() => 'AiChatException($code${message != null ? ': $message' : ''})';
}

class ChatService {
  ChatService._()
      : _functions = FirebaseFunctions.instanceFor(region: 'asia-southeast1');

  static final instance = ChatService._();

  final FirebaseFunctions _functions;
  final _firestore = FirebaseFirestore.instance;

  Future<({String reply, String conversationId})> sendMessage({
    required String userId,
    required String message,
    String? conversationId,
  }) async {
    try {
      final callable = _functions.httpsCallable('aiChat');
      final result = await callable.call<Map<String, dynamic>>({
        'message': message,
        if (conversationId != null) 'conversationId': conversationId,
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      return (
        reply: data['reply'] as String,
        conversationId: data['conversationId'] as String,
      );
    } on FirebaseFunctionsException catch (e) {
      if (e.message == 'LOGIN_REQUIRED') throw const AiChatException('LOGIN_REQUIRED');
      if (e.message == 'PREMIUM_REQUIRED') throw const AiChatException('PREMIUM_REQUIRED');
      throw AiChatException('UNKNOWN', e.message);
    } catch (e) {
      throw AiChatException('UNKNOWN', e.toString());
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      final callable = _functions.httpsCallable('deleteChatConversation');
      await callable.call({'conversationId': conversationId});
    } on FirebaseFunctionsException catch (e) {
      throw AiChatException('UNKNOWN', e.message);
    } catch (e) {
      throw AiChatException('UNKNOWN', e.toString());
    }
  }

  Stream<List<ChatConversation>> watchConversations(String userId) {
    return _firestore
        .collection('users/$userId/aiChats')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ChatConversation.fromFirestore).toList());
  }

  Stream<List<ChatMessage>> watchMessages(String userId, String conversationId) {
    return _firestore
        .collection('users/$userId/aiChats/$conversationId/messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snap) => snap.docs.map(ChatMessage.fromFirestore).toList());
  }
}

final chatServiceProvider = Provider<ChatService>((ref) => ChatService.instance);
