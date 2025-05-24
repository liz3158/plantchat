import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get chat messages stream
  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
    });
  }

  // Send a message
  Future<void> sendMessage(String chatId, String content, {String? replyToMessageId, String? replyToContent}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: user.uid,
      content: content,
      timestamp: DateTime.now(),
      replyToMessageId: replyToMessageId,
      replyToContent: replyToContent,
    );

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());
  }

  // Mark message as read
  Future<void> markMessageAsRead(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});
  }

  // Add reaction to message
  Future<void> addReaction(String chatId, String messageId, String emoji) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    final messageDoc = await messageRef.get();
    final message = Message.fromFirestore(messageDoc);

    final reactions = Map<String, List<String>>.from(message.reactions);
    if (!reactions.containsKey(emoji)) {
      reactions[emoji] = [];
    }
    if (!reactions[emoji]!.contains(user.uid)) {
      reactions[emoji]!.add(user.uid);
    }

    await messageRef.update({'reactions': reactions});
  }

  // Remove reaction from message
  Future<void> removeReaction(String chatId, String messageId, String emoji) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    final messageDoc = await messageRef.get();
    final message = Message.fromFirestore(messageDoc);

    final reactions = Map<String, List<String>>.from(message.reactions);
    if (reactions.containsKey(emoji)) {
      reactions[emoji]!.remove(user.uid);
      if (reactions[emoji]!.isEmpty) {
        reactions.remove(emoji);
      }
    }

    await messageRef.update({'reactions': reactions});
  }

  // Edit message
  Future<void> editMessage(String chatId, String messageId, String newContent) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'content': newContent,
      'isEdited': true,
    });
  }

  // Delete message
  Future<void> deleteMessage(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  // Update typing status
  Future<void> updateTypingStatus(String chatId, bool isTyping) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('typing')
        .doc(user.uid)
        .set({
      'isTyping': isTyping,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get typing status stream
  Stream<Map<String, bool>> getTypingStatus(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('typing')
        .snapshots()
        .map((snapshot) {
      final typingStatus = <String, bool>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp?;
        if (timestamp != null) {
          // Only consider typing status from the last 5 seconds
          final isRecent = DateTime.now().difference(timestamp.toDate()).inSeconds < 5;
          typingStatus[doc.id] = isRecent && (data['isTyping'] as bool);
        }
      }
      return typingStatus;
    });
  }
} 