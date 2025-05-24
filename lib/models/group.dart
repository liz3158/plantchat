import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String? avatarUrl;
  final List<String> members;
  final Timestamp createdAt;
  final String adminId;

  Group({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.members,
    required this.createdAt,
    required this.adminId,
  });

  factory Group.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Group(
      id: doc.id,
      name: data['name'] ?? '',
      avatarUrl: data['avatarUrl'],
      members: List<String>.from(data['members'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      adminId: data['adminId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatarUrl': avatarUrl,
      'members': members,
      'createdAt': createdAt,
      'adminId': adminId,
    };
  }
} 