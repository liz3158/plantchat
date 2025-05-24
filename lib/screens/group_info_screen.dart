import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupInfoScreen extends StatelessWidget {
  final Group group;
  const GroupInfoScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final isAdmin = FirebaseAuth.instance.currentUser?.uid == group.adminId;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Rename Group',
                    onPressed: () async {
                      final controller = TextEditingController(text: group.name);
                      final newName = await showDialog<String>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Rename Group'),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(labelText: 'Group Name'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, controller.text.trim()),
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                      if (newName != null && newName.isNotEmpty && newName != group.name) {
                        await FirebaseFirestore.instance.collection('groups').doc(group.id).update({'name': newName});
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Group name updated.')));
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Members', style: Theme.of(context).textTheme.titleMedium),
                if (isAdmin)
                  TextButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Members'),
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance.collection('groups').doc(group.id).snapshots(),
                          builder: (context, groupSnapshot) {
                            if (!groupSnapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final groupData = groupSnapshot.data!.data() as Map<String, dynamic>;
                            final currentMembers = List<String>.from(groupData['members'] ?? []);
                            List<String> selectedUserIds = [];
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return FutureBuilder<QuerySnapshot>(
                                  future: FirebaseFirestore.instance.collection('users').get(),
                                  builder: (context, userSnapshot) {
                                    if (!userSnapshot.hasData) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    final allUsers = userSnapshot.data!.docs.where((u) => !currentMembers.contains(u.id)).toList();
                                    return AlertDialog(
                                      title: const Text('Add Members'),
                                      content: SizedBox(
                                        width: 350,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: allUsers.length,
                                          itemBuilder: (context, index) {
                                            final user = allUsers[index];
                                            final data = user.data() as Map<String, dynamic>;
                                            return CheckboxListTile(
                                              value: selectedUserIds.contains(user.id),
                                              onChanged: (selected) {
                                                setState(() {
                                                  if (selected == true) {
                                                    selectedUserIds.add(user.id);
                                                  } else {
                                                    selectedUserIds.remove(user.id);
                                                  }
                                                });
                                              },
                                              title: Text(data['displayName'] ?? 'Unknown'),
                                              subtitle: Text(data['email'] ?? ''),
                                            );
                                          },
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            if (selectedUserIds.isNotEmpty) {
                                              await FirebaseFirestore.instance.collection('groups').doc(group.id).update({
                                                'members': FieldValue.arrayUnion(selectedUserIds),
                                              });
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Members added.')));
                                            }
                                          },
                                          child: const Text('Add'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('groups').doc(group.id).snapshots(),
                builder: (context, groupSnapshot) {
                  if (!groupSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final groupData = groupSnapshot.data!.data() as Map<String, dynamic>;
                  final members = List<String>.from(groupData['members'] ?? []);
                  if (members.isEmpty) {
                    return const Center(child: Text('No members.'));
                  }
                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .where(FieldPath.documentId, whereIn: members)
                        .get(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final users = userSnapshot.data!.docs;
                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final data = user.data() as Map<String, dynamic>;
                          final isGroupAdmin = user.id == group.adminId;
                          return ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(data['displayName'] ?? 'Unknown'),
                            subtitle: Text(data['email'] ?? ''),
                            trailing: isGroupAdmin
                                ? const Text('Admin', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))
                                : isAdmin
                                    ? IconButton(
                                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                                        tooltip: 'Remove Member',
                                        onPressed: () async {
                                          await FirebaseFirestore.instance.collection('groups').doc(group.id).update({
                                            'members': FieldValue.arrayRemove([user.id]),
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member removed.')));
                                        },
                                      )
                                    : null,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 