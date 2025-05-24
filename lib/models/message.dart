import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, List<String>> reactions; // Map of emoji to list of user IDs
  final bool isEdited;
  final String? replyToMessageId;
  final String? replyToContent;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.reactions = const {},
    this.isEdited = false,
    this.replyToMessageId,
    this.replyToContent,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      reactions: Map<String, List<String>>.from(data['reactions'] ?? {}),
      isEdited: data['isEdited'] ?? false,
      replyToMessageId: data['replyToMessageId'],
      replyToContent: data['replyToContent'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'reactions': reactions,
      'isEdited': isEdited,
      'replyToMessageId': replyToMessageId,
      'replyToContent': replyToContent,
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    Map<String, List<String>>? reactions,
    bool? isEdited,
    String? replyToMessageId,
    String? replyToContent,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      reactions: reactions ?? this.reactions,
      isEdited: isEdited ?? this.isEdited,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToContent: replyToContent ?? this.replyToContent,
    );
  }
} 